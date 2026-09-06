@isTest
private class ReportControllerTest {

    @isTest
    static void testGetReportData() {
        Account fan = new Account(LastName = '테스트팬', Engagement_Level__c = '활동 팬');
        insert fan;

        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;

        Game__c game = new Game__c(Game_Date__c = Date.today(), Season__c = season.Id);
        insert game;

        Attendance_Record__c ar = new Attendance_Record__c(Fan__c = fan.Id);
        insert ar;

        insert new Admission__c(Fan__c = fan.Id, Game__c = game.Id, Attendance_Record__c = ar.Id,
            Admission_Time__c = DateTime.now());

        // Order.TotalAmount는 읽기 전용이라 직접 못 넣음 → OrderItem으로 자동 계산
        Order o = new Order(AccountId = fan.Id, Status = 'Draft', EffectiveDate = Date.today(),
            Order_Type__c = 'Goods Purchase', Purchase_Channel__c = 'Online',
            Pricebook2Id = Test.getStandardPricebookId());
        insert o;

        Product2 p = new Product2(Name = '테스트상품', IsActive = true);
        insert p;
        PricebookEntry stdPbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert stdPbe;

        insert new OrderItem(OrderId = o.Id, Product2Id = p.Id, PricebookEntryId = stdPbe.Id,
            Quantity = 1, UnitPrice = 10000);

        Campaign camp = new Campaign(Name = '테스트캠페인', Status = 'In Progress');
        insert camp;
        Contact testContact = new Contact(LastName = '테스트연락처');
        insert testContact;
        insert new CampaignMember(CampaignId = camp.Id, ContactId = testContact.Id, Status = 'Responded');

        Test.startTest();
        ReportController.ReportData data = ReportController.getReportData();
        Test.stopTest();

        System.assertNotEquals(null, data, 'ReportData가 반환되어야 함');
        System.assertNotEquals(null, data.onlineRevenue, '온라인 매출 카드가 있어야 함');
        System.assertNotEquals(null, data.segmentDistribution, '세그먼트 분포가 있어야 함');
        System.assertEquals(4, data.tierConversion.size(), '전환율 4단계 고정값이어야 함');
        System.assertEquals(5, data.funnel.size(), '퍼널 5단계여야 함');
    }
}
