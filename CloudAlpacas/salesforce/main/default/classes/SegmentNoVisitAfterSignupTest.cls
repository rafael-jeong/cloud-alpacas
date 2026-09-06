@isTest
private class SegmentNoVisitAfterSignupTest {

    @isTest
    static void testMatchingFanCounted() {
        Account fan = new Account(LastName = '미관람팬');
        insert fan;
        Test.setCreatedDate(fan.Id, DateTime.now().addDays(-30));

        insert new Engagement_Signal__c(Fan__c = fan.Id, Signal_Type__c = 'App Open',
            Signal_Date__c = DateTime.now().addDays(-5));

        Test.startTest();
        Integer count = SegmentNoVisitAfterSignup.getCount();
        List<SegmentFanListItem> fanListResult = SegmentNoVisitAfterSignup.getFanList();
        Id repId = SegmentNoVisitAfterSignup.getRepresentativeFanId();
        Test.stopTest();

        System.assertEquals(1, count, '조건을 만족하는 팬 1명이 카운트되어야 함');
        System.assertEquals(1, fanListResult.size(), 'getFanList()도 동일하게 1건이어야 함');
        System.assertEquals(fan.Id, repId, '대표 팬 Id가 해당 팬이어야 함');
    }

    @isTest
    static void testTicketPurchasedFanExcluded() {
        Account fan = new Account(LastName = '티켓구매팬');
        insert fan;
        Test.setCreatedDate(fan.Id, DateTime.now().addDays(-30));

        insert new Engagement_Signal__c(Fan__c = fan.Id, Signal_Type__c = 'App Open',
            Signal_Date__c = DateTime.now().addDays(-5));

        insert new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today(),
            Order_Type__c = 'Ticket Purchase', Pricebook2Id = Test.getStandardPricebookId());

        Test.startTest();
        Integer count = SegmentNoVisitAfterSignup.getCount();
        Test.stopTest();

        System.assertEquals(0, count, '티켓 구매한 팬은 제외되어야 함');
    }

    @isTest
    static void testRecentSignupExcluded() {
        Account fan = new Account(LastName = '최근가입팬');
        insert fan;

        insert new Engagement_Signal__c(Fan__c = fan.Id, Signal_Type__c = 'App Open',
            Signal_Date__c = DateTime.now());

        Test.startTest();
        Integer count = SegmentNoVisitAfterSignup.getCount();
        Test.stopTest();

        System.assertEquals(0, count, '가입 21일 미만 팬은 제외되어야 함');
    }

    @isTest
    static void testNoAppOpenExcluded() {
        Account fan = new Account(LastName = '무방문팬');
        insert fan;
        Test.setCreatedDate(fan.Id, DateTime.now().addDays(-30));

        Test.startTest();
        Integer count = SegmentNoVisitAfterSignup.getCount();
        Test.stopTest();

        System.assertEquals(0, count, '앱 방문 기록이 없는 팬은 제외되어야 함');
    }
}
