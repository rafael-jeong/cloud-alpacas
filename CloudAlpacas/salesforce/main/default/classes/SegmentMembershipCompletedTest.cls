@isTest
private class SegmentMembershipCompletedTest {

    @isTest
    static void testValidSequence() {
        Account fan = new Account(LastName = '완주팬');
        insert fan;

        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;
        Game__c game = new Game__c(Game_Date__c = Date.today(), Season__c = season.Id);
        insert game;
        Attendance_Record__c ar = new Attendance_Record__c(Fan__c = fan.Id);
        insert ar;
        insert new Admission__c(Fan__c = fan.Id, Game__c = game.Id, Attendance_Record__c = ar.Id,
            Admission_Time__c = DateTime.now().addDays(1));

        insert new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today().addDays(2),
            Order_Type__c = 'Goods Purchase', Pricebook2Id = Test.getStandardPricebookId());

        insert new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today().addDays(3),
            Order_Type__c = 'Membership Enrollment', Pricebook2Id = Test.getStandardPricebookId());

        Test.startTest();
        Integer count = SegmentMembershipCompleted.getCount();
        List<SegmentFanListItem> fanListResult = SegmentMembershipCompleted.getFanList();
        Id repId = SegmentMembershipCompleted.getRepresentativeFanId();
        Test.stopTest();

        System.assertEquals(1, count, '가입 후 순서대로 완주한 팬은 카운트되어야 함');
        System.assertEquals(1, fanListResult.size(), 'getFanList()도 동일하게 1건이어야 함');
        System.assertEquals(fan.Id, fanListResult[0].fanId, '리스트의 팬 Id가 일치해야 함');
        System.assertEquals(fan.Id, repId, '대표 팬 Id가 해당 팬이어야 함');
    }

    @isTest
    static void testActivityBeforeSignupExcluded() {
        Account fan = new Account(LastName = '가입전활동팬');
        insert fan;

        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;
        Game__c game = new Game__c(Game_Date__c = Date.today(), Season__c = season.Id);
        insert game;
        Attendance_Record__c ar = new Attendance_Record__c(Fan__c = fan.Id);
        insert ar;
        insert new Admission__c(Fan__c = fan.Id, Game__c = game.Id, Attendance_Record__c = ar.Id,
            Admission_Time__c = DateTime.now().addDays(1));

        insert new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today().addDays(-30),
            Order_Type__c = 'Goods Purchase', Pricebook2Id = Test.getStandardPricebookId());

        insert new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today().addDays(3),
            Order_Type__c = 'Membership Enrollment', Pricebook2Id = Test.getStandardPricebookId());

        Test.startTest();
        Integer count = SegmentMembershipCompleted.getCount();
        Id repId = SegmentMembershipCompleted.getRepresentativeFanId();
        Test.stopTest();

        System.assertEquals(0, count, '가입 이전 활동은 제외되어야 함');
        System.assertEquals(null, repId, '조건 미충족 시 대표 팬은 null이어야 함');
    }

    @isTest
    static void testMembershipBeforeGoodsExcluded() {
        Account fan = new Account(LastName = '순서역전팬');
        insert fan;

        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;
        Game__c game = new Game__c(Game_Date__c = Date.today(), Season__c = season.Id);
        insert game;
        Attendance_Record__c ar = new Attendance_Record__c(Fan__c = fan.Id);
        insert ar;
        insert new Admission__c(Fan__c = fan.Id, Game__c = game.Id, Attendance_Record__c = ar.Id,
            Admission_Time__c = DateTime.now().addDays(1));

        insert new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today().addDays(2),
            Order_Type__c = 'Membership Enrollment', Pricebook2Id = Test.getStandardPricebookId());

        insert new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today().addDays(5),
            Order_Type__c = 'Goods Purchase', Pricebook2Id = Test.getStandardPricebookId());

        Test.startTest();
        Integer count = SegmentMembershipCompleted.getCount();
        Test.stopTest();

        System.assertEquals(0, count, '멤버십보다 나중에 굿즈 구매하면 제외되어야 함');
    }
}
