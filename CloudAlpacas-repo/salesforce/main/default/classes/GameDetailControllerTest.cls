@isTest
private class GameDetailControllerTest {
    @isTest
    static void testGetGameDetail() {
        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;

        Game__c game = new Game__c(
            Game_Date__c = Date.today(),
            Opponent__c = '레드폭스',
            Home_Away__c = 'Home',
            Season__c = season.Id
        );
        insert game;

        Test.startTest();
        GameDetailController.GameDetail d = GameDetailController.getGameDetail(game.Id);
        Test.stopTest();

        System.assertNotEquals(null, d, 'GameDetail이 반환되어야 함');
        System.assert(d.matchup.contains('레드폭스'), '매치업에 상대팀이 포함되어야 함');
        System.assertEquals('Cloud Stadium', d.stadium, '홈경기는 Cloud Stadium이어야 함');
        System.assertNotEquals(null, d.ticketSales, '티켓 판매 값이 있어야 함');
    }
}
