@isTest
private class CampaignControllerTest {

    @isTest
    static void testDemoFallback() {
        // Campaign 0건 → 데모 카드 반환
        Test.startTest();
        List<CampaignController.CampaignCard> cards = CampaignController.getCampaigns();
        Test.stopTest();

        System.assertNotEquals(null, cards, '카드가 반환되어야 함');
        System.assert(cards.size() >= 1, '데모 카드가 최소 1개 이상이어야 함');
    }

    @isTest
    static void testRealDataWithLiveMetrics() {
        Campaign camp = new Campaign(Name = 'Welcome Campaign', Status = 'In Progress',
            Description = 'New Fan');
        insert camp;

        // CampaignMember 4명: Sent 3명, Responded 1명 (Contact 필요)
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 4; i++) {
            contacts.add(new Contact(LastName = '테스트' + i));
        }
        insert contacts;

        insert new List<CampaignMember>{
            new CampaignMember(CampaignId = camp.Id, ContactId = contacts[0].Id, Status = 'Sent'),
            new CampaignMember(CampaignId = camp.Id, ContactId = contacts[1].Id, Status = 'Sent'),
            new CampaignMember(CampaignId = camp.Id, ContactId = contacts[2].Id, Status = 'Sent'),
            new CampaignMember(CampaignId = camp.Id, ContactId = contacts[3].Id, Status = 'Responded')
        };

        // Notification_Log 2건 발송
        Account fan = new Account(LastName = '테스트팬');
        insert fan;
        insert new List<Notification_Log__c>{
            new Notification_Log__c(Fan__c = fan.Id, Campaign__c = camp.Id, Content__c = '알림1',
                Sent_Date__c = DateTime.now()),
            new Notification_Log__c(Fan__c = fan.Id, Campaign__c = camp.Id, Content__c = '알림2',
                Sent_Date__c = DateTime.now())
        };

        Test.startTest();
        List<CampaignController.CampaignCard> cards = CampaignController.getCampaigns();
        Test.stopTest();

        System.assertEquals(1, cards.size(), '실제 캠페인 1건이 반환되어야 함');
        CampaignController.CampaignCard card = cards[0];
        System.assertEquals('Welcome Campaign', card.name);
        System.assertEquals(2, card.numberSent, '발송 수는 Notification_Log 건수(2)와 같아야 함');
        System.assertEquals(4, card.targetCount, '대상 인원은 CampaignMember 전체(4)와 같아야 함');
        System.assertEquals(50, card.progress, '진행률 = 발송2/대상4*100 = 50');
        System.assertEquals(25, card.clickRate, '클릭률 = 응답1/대상4*100 = 25');
    }
}
