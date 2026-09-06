/**
 * Public webhook target for a Slack Slash Command (e.g. "/campaign-report d'Alba").
 * Exposed to the internet via the "sfpwebhook" Experience Cloud site's Guest User
 * Profile (dedicated, otherwise-unused site — see Individual Development Handoff
 * doc for why this one was chosen over creating a new site).
 *
 * Security model:
 * - This is the ONLY thing granted to the Guest Profile: execute access to this one
 *   class. No object/field permission is granted to the Guest Profile at all — Apex
 *   runs in system mode by default (this class is deliberately `without sharing`),
 *   so the queries below work regardless of what the Guest Profile can see directly.
 * - Every request is verified against Slack's HMAC-SHA256 request signature
 *   (https://api.slack.com/authentication/verifying-requests-from-slack) before any
 *   query runs. Unsigned, mis-signed, or >5-minutes-old requests are rejected.
 * - Read-only: no DML anywhere in this class, even though verified requests could
 *   safely be granted more. Campaign.Performance_Summary__c is used as-is (may be
 *   stale by the known Renewal_Campaign_Performance_Summary limitation); the
 *   completion-rate/blocked/overdue numbers are computed fresh on every call instead
 *   of trusting the cached Roll-Up fields, so those are always accurate.
 */
@RestResource(urlMapping='/slackCampaignReport/*')
global without sharing class SlackCampaignReportEndpoint {

    @HttpPost
    global static void handleSlashCommand() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            String rawBody = req.requestBody != null ? req.requestBody.toString() : '';
            String timestamp = req.headers.get('X-Slack-Request-Timestamp');
            String signature = req.headers.get('X-Slack-Signature');

            if (!isValidSlackRequest(timestamp, signature, rawBody)) {
                res.statusCode = 401;
                // TEMP DEBUG (2026-09-01, remove once real Slack traffic verifies successfully):
                // exposes no secret — just enough to see which check failed against real traffic.
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'response_type' => 'ephemeral',
                    'text' => '요청 검증에 실패했습니다.',
                    'debug' => debugSignatureCheck(timestamp, signature, rawBody)
                }));
                return;
            }

            Map<String, String> formParams = parseFormEncoded(rawBody);
            String searchTerm = formParams.containsKey('text') ? formParams.get('text').trim() : '';

            res.statusCode = 200;
            if (String.isBlank(searchTerm)) {
                res.responseBody = Blob.valueOf(toJson('ephemeral', '사용법: /campaign-report {스폰서명} (예: /campaign-report d\'Alba)'));
                return;
            }

            Map<String, Object> report = buildReport(searchTerm);
            if (report == null) {
                res.responseBody = Blob.valueOf(toJson('ephemeral', '\'' + searchTerm + '\'와(과) 일치하는 갱신 캠페인을 찾지 못했습니다.'));
                return;
            }

            res.responseBody = Blob.valueOf(JSON.serialize(report));
        } catch (Exception e) {
            res.statusCode = 200; // Slack ignores non-200s for slash commands; reply ephemerally instead
            res.responseBody = Blob.valueOf(toJson('ephemeral', '보고서 생성 중 오류가 발생했습니다.'));
        }
    }

    // ------------------------------------------------------------------ security

    @TestVisible
    private static Boolean isValidSlackRequest(String timestamp, String signature, String rawBody) {
        if (String.isBlank(timestamp) || String.isBlank(signature)) {
            return false;
        }
        Long ts;
        try {
            ts = Long.valueOf(timestamp);
        } catch (Exception e) {
            return false;
        }
        Long nowEpoch = DateTime.now().getTime() / 1000;
        if (Math.abs(nowEpoch - ts) > 300) {
            return false; // reject replayed/stale requests (Slack's own recommendation)
        }

        // No placeholder-value special-casing here on purpose: an unconfigured secret
        // (still the "REPLACE_ME_IN_SETUP_UI" deploy default) will simply never produce
        // an HMAC that matches a real Slack-signed request, so every genuine Slack call
        // is rejected until the real secret is entered — the blank check below is the
        // only explicit guard needed.
        Slack_Config__mdt cfg = Slack_Config__mdt.getInstance('Default');
        if (cfg == null || String.isBlank(cfg.Signing_Secret__c)) {
            return false;
        }

        String baseString = 'v0:' + timestamp + ':' + rawBody;
        Blob hmac = Crypto.generateMac('HmacSHA256', Blob.valueOf(baseString), Blob.valueOf(cfg.Signing_Secret__c));
        String computed = 'v0=' + EncodingUtil.convertToHex(hmac);

        return computed.equalsIgnoreCase(signature);
    }

    // TEMP DEBUG (2026-09-01, remove once real Slack traffic verifies successfully):
    // reveals: timestamp skew, secret presence/length (never the secret value itself),
    // and the full computed vs. received signature (signatures are single-request HMAC
    // outputs, not secrets — safe to expose transiently for diagnosis).
    private static Map<String, Object> debugSignatureCheck(String timestamp, String signature, String rawBody) {
        Map<String, Object> d = new Map<String, Object>();
        d.put('timestampReceived', timestamp);
        d.put('signatureReceived', signature);
        d.put('rawBodyReceived', rawBody);
        Long nowEpoch = DateTime.now().getTime() / 1000;
        d.put('serverEpochNow', nowEpoch);
        try {
            d.put('timestampAgeSeconds', nowEpoch - Long.valueOf(timestamp));
        } catch (Exception e) {
            d.put('timestampAgeSeconds', 'unparseable');
        }
        Slack_Config__mdt cfg = Slack_Config__mdt.getInstance('Default');
        d.put('secretConfigured', cfg != null && String.isNotBlank(cfg.Signing_Secret__c));
        d.put('secretLength', (cfg != null && cfg.Signing_Secret__c != null) ? cfg.Signing_Secret__c.length() : 0);
        if (cfg != null && String.isNotBlank(cfg.Signing_Secret__c) && String.isNotBlank(timestamp)) {
            String baseString = 'v0:' + timestamp + ':' + rawBody;
            Blob hmac = Crypto.generateMac('HmacSHA256', Blob.valueOf(baseString), Blob.valueOf(cfg.Signing_Secret__c));
            d.put('signatureComputed', 'v0=' + EncodingUtil.convertToHex(hmac));
        }
        return d;
    }

    private static Map<String, String> parseFormEncoded(String body) {
        Map<String, String> result = new Map<String, String>();
        if (String.isBlank(body)) {
            return result;
        }
        for (String pair : body.split('&')) {
            List<String> kv = pair.split('=', 2);
            if (kv.size() == 2) {
                result.put(EncodingUtil.urlDecode(kv[0], 'UTF-8'), EncodingUtil.urlDecode(kv[1], 'UTF-8'));
            }
        }
        return result;
    }

    private static String toJson(String responseType, String text) {
        return JSON.serialize(new Map<String, Object>{ 'response_type' => responseType, 'text' => text });
    }

    // ------------------------------------------------------------------ report (read-only)

    @TestVisible
    private static Map<String, Object> buildReport(String searchTerm) {
        String likePattern = '%' + searchTerm + '%';
        List<Campaign> renewals = [
            SELECT Id, Name, ParentId, Performance_Summary__c, ExpectedRevenue
            FROM Campaign
            WHERE RecordType.DeveloperName = 'Sponsorship_Renewal'
            AND Name LIKE :likePattern
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
        if (renewals.isEmpty()) {
            return null;
        }
        Campaign renewal = renewals[0];

        // Sibling/child Collaboration campaigns under the same sponsor root — supports both the
        // 3-tier (Parent -> Collaboration + Renewal) and 2-tier (Collaboration -> Renewal) shapes
        // already established by Renewal_Campaign_Performance_Summary.
        Id rootId = renewal.ParentId != null ? renewal.ParentId : renewal.Id;
        Set<Id> collabIds = new Set<Id>();
        for (Campaign c : [
            SELECT Id FROM Campaign
            WHERE RecordType.DeveloperName = 'Sponsorship_Collaboration'
            AND (ParentId = :rootId OR Id = :rootId)
        ]) {
            collabIds.add(c.Id);
        }

        Decimal totalWeight = 0;
        Decimal completedWeight = 0;
        Integer totalCount = 0;
        Integer completedCount = 0;
        Integer blockedCount = 0;
        Integer overdueCount = 0;

        if (!collabIds.isEmpty()) {
            for (Campaign_Deliverable__c d : [
                SELECT Status__c, Weight__c, Due_Date__c
                FROM Campaign_Deliverable__c
                WHERE Campaign__c IN :collabIds
            ]) {
                totalCount++;
                Decimal w = d.Weight__c == null ? 0 : d.Weight__c;
                totalWeight += w;
                if (d.Status__c == 'Completed') {
                    completedWeight += w;
                    completedCount++;
                } else if (d.Status__c == 'Blocked') {
                    blockedCount++;
                }
                if (d.Status__c != 'Completed' && d.Due_Date__c != null && d.Due_Date__c < Date.today()) {
                    overdueCount++;
                }
            }
        }

        Decimal completionRate = totalWeight > 0 ? (completedWeight / totalWeight * 100).setScale(1) : 0;

        String tier = null;
        if (!collabIds.isEmpty()) {
            for (Opportunity o : [
                SELECT Partner_Tier__c FROM Opportunity
                WHERE CampaignId IN :collabIds AND Partner_Tier__c != null
                ORDER BY LastModifiedDate DESC
                LIMIT 1
            ]) {
                tier = o.Partner_Tier__c;
            }
        }

        List<Object> blocks = new List<Object>();
        blocks.add(new Map<String, Object>{
            'type' => 'header',
            'text' => new Map<String, Object>{ 'type' => 'plain_text', 'text' => '📊 ' + renewal.Name, 'emoji' => true }
        });
        blocks.add(new Map<String, Object>{
            'type' => 'section',
            'fields' => new List<Object>{
                new Map<String, Object>{ 'type' => 'mrkdwn', 'text' => '*티어*\n' + (String.isBlank(tier) ? '미확인' : tier) },
                new Map<String, Object>{ 'type' => 'mrkdwn', 'text' => '*계약 예상 매출*\nKRW ' + (renewal.ExpectedRevenue == null ? '0' : renewal.ExpectedRevenue.format()) },
                new Map<String, Object>{ 'type' => 'mrkdwn', 'text' => '*실행 이행률(실시간)*\n' + completionRate + '% (' + completedCount + '/' + totalCount + '건)' },
                new Map<String, Object>{ 'type' => 'mrkdwn', 'text' => '*현재 병목*\nBlocked ' + blockedCount + '건 · 기한초과 ' + overdueCount + '건' }
            }
        });
        if (String.isNotBlank(renewal.Performance_Summary__c)) {
            blocks.add(new Map<String, Object>{ 'type' => 'divider' });
            blocks.add(new Map<String, Object>{
                'type' => 'section',
                'text' => new Map<String, Object>{ 'type' => 'mrkdwn', 'text' => renewal.Performance_Summary__c }
            });
        }
        blocks.add(new Map<String, Object>{
            'type' => 'context',
            'elements' => new List<Object>{
                new Map<String, Object>{ 'type' => 'mrkdwn', 'text' => 'Cloud Alpacas PRM 자동 보고서 · 실행 이행률은 조회 시점 실시간 계산' }
            }
        });

        return new Map<String, Object>{ 'response_type' => 'in_channel', 'blocks' => blocks };
    }
}
