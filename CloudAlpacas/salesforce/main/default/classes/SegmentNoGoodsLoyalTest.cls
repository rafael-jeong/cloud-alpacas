@isTest
private class SegmentNoGoodsLoyalTest {

    private static List<Game__c> createPastGames(Id seasonId, Integer count) {
        List<Game__c> games = new List<Game__c>();
        for (Integer i = 0; i < count; i++) {
            games.add(new Game__c(Game_Date__c = Date.today().addDays(-1 - i), Season__c = seasonId));
        }
        insert games;
        return games;
    }

    private static void insertAdmission(Id fanId, Id gameId) {
        Attendance_Record__c ar = new Attendance_Record__c(Fan__c = fanId);
        insert ar;
        insert new Admission__c(Fan__c = fanId, Game__c = gameId, Attendance_Record__c = ar.Id,
            Admission_Time__c = DateTime.now());
    }

    @isTest
    static void testLoyalNoGoodsFanCounted() {
        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;
        List<Game__c> games = createPastGames(season.Id, 10);

        Account fan = new Account(LastName = '충성무굿즈팬');
        insert fan;
        for (Integer i = 0; i < 5; i++) {
            insertAdmission(fan.Id, games[i].Id);
        }

        Test.startTest();
        Integer count = SegmentNoGoodsLoyal.getCount();
        List<SegmentFanListItem> fanListResult = SegmentNoGoodsLoyal.getFanList();
        Id repId = SegmentNoGoodsLoyal.getRepresentativeFanId();
        Test.stopTest();

        System.assertEquals(1, count, '관람 비율 40% 이상 + 굿즈 미구매 팬은 카운트되어야 함');
        System.assertEquals(1, fanListResult.size(), 'getFanList()도 동일하게 1건이어야 함');
        System.assertEquals(fan.Id, repId, '대표 팬 Id가 해당 팬이어야 함');
    }

    @isTest
    static void testLoyalWithGoodsExcluded() {
        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;
        List<Game__c> games = createPastGames(season.Id, 10);

        Account fan = new Account(LastName = '굿즈구매팬');
        insert fan;
        for (Integer i = 0; i < 5; i++) {
            insertAdmission(fan.Id, games[i].Id);
        }
        insert new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today(),
            Order_Type__c = 'Goods Purchase', Pricebook2Id = Test.getStandardPricebookId());

        Test.startTest();
        Integer count = SegmentNoGoodsLoyal.getCount();
        Test.stopTest();

        System.assertEquals(0, count, '굿즈를 구매한 팬은 제외되어야 함');
    }

    @isTest
    static void testLowAttendanceExcluded() {
        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;
        List<Game__c> games = createPastGames(season.Id, 10);

        Account fan = new Account(LastName = '저조관람팬');
        insert fan;
        insertAdmission(fan.Id, games[0].Id);

        Test.startTest();
        Integer count = SegmentNoGoodsLoyal.getCount();
        Test.stopTest();

        System.assertEquals(0, count, '관람 비율 40% 미만이면 제외되어야 함');
    }
}
