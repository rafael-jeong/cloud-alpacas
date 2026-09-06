@isTest
private class SlackCampaignReportEndpointTest {

    private static String computeSignature(String timestamp, String rawBody) {
        Slack_Config__mdt cfg = Slack_Config__mdt.getInstance('Default');
        String baseString = 'v0:' + timestamp + ':' + rawBody;
        Blob hmac = Crypto.generateMac('HmacSHA256', Blob.valueOf(baseString), Blob.valueOf(cfg.Signing_Secret__c));
        return 'v0=' + EncodingUtil.convertToHex(hmac);
    }

    private static String nowTimestamp() {
        return String.valueOf(DateTime.now().getTime() / 1000);
    }

    @TestSetup
    static void setupData() {
        Id renewalRt = [SELECT Id FROM RecordType WHERE SObjectType = 'Campaign' AND DeveloperName = 'Sponsorship_Renewal' LIMIT 1].Id;
        Id collabRt = [SELECT Id FROM RecordType WHERE SObjectType = 'Campaign' AND DeveloperName = 'Sponsorship_Collaboration' LIMIT 1].Id;

        Campaign collab = new Campaign(Name = 'Acme Test Collaboration', RecordTypeId = collabRt, IsActive = true);
        insert collab;

        // Note: Performance_Summary__c is NOT set here on purpose — the real
        // Renewal_Campaign_Performance_Summary Before-Save Flow overwrites it on
        // insert anyway (with a stale 0%, since no Deliverables exist yet at this
        // point in setup) — which is itself a live demonstration of exactly why this
        // endpoint computes its own completion-rate fresh instead of trusting that
        // cached field.
        Campaign renewal = new Campaign(Name = 'Acme Test Renewal', RecordTypeId = renewalRt, ParentId = collab.Id,
            ExpectedRevenue = 100000000);
        insert renewal;

        insert new List<Campaign_Deliverable__c>{
            new Campaign_Deliverable__c(Campaign__c = collab.Id, Status__c = 'Completed', Weight__c = 40, Due_Date__c = Date.today().addDays(-5)),
            new Campaign_Deliverable__c(Campaign__c = collab.Id, Status__c = 'Blocked', Weight__c = 30, Due_Date__c = Date.today().addDays(5), Blocked_Reason__c = '기타'),
            new Campaign_Deliverable__c(Campaign__c = collab.Id, Status__c = 'Not Started', Weight__c = 30, Due_Date__c = Date.today().addDays(-1))
        };

        Account acc = new Account(Name = 'Acme Test Sponsor');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Acme Test Opp', AccountId = acc.Id, StageName = 'Closed Won',
            CloseDate = Date.today(), CampaignId = collab.Id, Partner_Tier__c = 'Gold');
        insert opp;
    }

    @isTest
    static void testSignature_validRequestPasses() {
        String ts = nowTimestamp();
        String body = 'text=Acme&command=%2Fcampaign-report';
        String sig = computeSignature(ts, body);

        Test.startTest();
        Boolean result = SlackCampaignReportEndpoint.isValidSlackRequest(ts, sig, body);
        Test.stopTest();

        System.assertEquals(true, result, 'A correctly-signed, fresh request should pass verification');
    }

    @isTest
    static void testSignature_wrongSecretFails() {
        String ts = nowTimestamp();
        String body = 'text=Acme';
        String baseString = 'v0:' + ts + ':' + body;
        Blob hmac = Crypto.generateMac('HmacSHA256', Blob.valueOf(baseString), Blob.valueOf('not-the-real-secret'));
        String badSig = 'v0=' + EncodingUtil.convertToHex(hmac);

        Boolean result = SlackCampaignReportEndpoint.isValidSlackRequest(ts, badSig, body);

        System.assertEquals(false, result, 'A signature computed with the wrong secret must be rejected');
    }

    @isTest
    static void testSignature_staleTimestampFails() {
        String staleTs = String.valueOf((DateTime.now().getTime() / 1000) - 600); // 10 minutes old
        String body = 'text=Acme';
        String sig = computeSignature(staleTs, body);

        Boolean result = SlackCampaignReportEndpoint.isValidSlackRequest(staleTs, sig, body);

        System.assertEquals(false, result, 'A request older than 5 minutes must be rejected (replay protection)');
    }

    @isTest
    static void testSignature_missingHeadersFail() {
        System.assertEquals(false, SlackCampaignReportEndpoint.isValidSlackRequest(null, 'v0=abc', 'text=x'));
        System.assertEquals(false, SlackCampaignReportEndpoint.isValidSlackRequest(nowTimestamp(), null, 'text=x'));
    }

    @isTest
    static void testBuildReport_foundReturnsBlocksWithComputedRate() {
        Test.startTest();
        Map<String, Object> report = SlackCampaignReportEndpoint.buildReport('Acme Test Renewal');
        Test.stopTest();

        System.assertNotEquals(null, report, 'A matching Renewal campaign should produce a report');
        System.assertEquals('in_channel', report.get('response_type'));
        List<Object> blocks = (List<Object>) report.get('blocks');
        System.assert(blocks.size() >= 2, 'Report should contain at least header + fields blocks');

        String serialized = JSON.serialize(report);
        System.assert(serialized.contains('40.0%'), 'Completion rate should be computed as 40/(40+30+30)=40.0% from live data, not a cached rollup: ' + serialized);
        System.assert(serialized.contains('Gold'), 'Tier should be pulled from the linked Opportunity');
        System.assert(serialized.contains('divider'), 'A non-blank Performance_Summary__c (populated by the real Renewal Flow on insert) should add a divider + narrative section: ' + serialized);
    }

    @isTest
    static void testBuildReport_notFoundReturnsNull() {
        Map<String, Object> report = SlackCampaignReportEndpoint.buildReport('NoSuchSponsorXYZ');
        System.assertEquals(null, report);
    }

    @isTest
    static void testHandleSlashCommand_endToEndValidRequest() {
        String ts = nowTimestamp();
        String body = 'text=Acme+Test+Renewal&command=%2Fcampaign-report';
        String sig = computeSignature(ts, body);

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/slackCampaignReport';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        req.addHeader('X-Slack-Request-Timestamp', ts);
        req.addHeader('X-Slack-Signature', sig);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        SlackCampaignReportEndpoint.handleSlashCommand();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        String responseText = RestContext.response.responseBody.toString();
        System.assert(responseText.contains('in_channel'), 'A valid, matched request should post visibly to the channel: ' + responseText);
    }

    @isTest
    static void testHandleSlashCommand_badSignatureReturns401() {
        String ts = nowTimestamp();
        String body = 'text=Acme';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/slackCampaignReport';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        req.addHeader('X-Slack-Request-Timestamp', ts);
        req.addHeader('X-Slack-Signature', 'v0=deadbeef');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        SlackCampaignReportEndpoint.handleSlashCommand();
        Test.stopTest();

        System.assertEquals(401, RestContext.response.statusCode);
    }

    @isTest
    static void testHandleSlashCommand_blankTextReturnsUsageHint() {
        String ts = nowTimestamp();
        String body = 'text=&command=%2Fcampaign-report';
        String sig = computeSignature(ts, body);

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/slackCampaignReport';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        req.addHeader('X-Slack-Request-Timestamp', ts);
        req.addHeader('X-Slack-Signature', sig);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        SlackCampaignReportEndpoint.handleSlashCommand();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('사용법'));
    }
}
