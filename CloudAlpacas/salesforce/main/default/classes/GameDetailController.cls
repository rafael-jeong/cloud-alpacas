/**
 * GameDetailController
 * 경기(Game__c) Record Page 우측 상세에 쓸 데이터를 조회한다.
 * - 매치업/날짜/구장/상태: 실제 Game__c 필드에서 조회 (실시간)
 * - 참석 팬/티켓 판매/좌석 현황: 지금은 고정값(시안 수치).
 *   데이터가 쌓이면 아래 TODO 부분을 실제 집계로 교체하면 실시간 반영됨.
 */
public with sharing class GameDetailController {

    @AuraEnabled(cacheable=true)
    public static GameDetail getGameDetail(Id gameId) {
        GameDetail d = new GameDetail();

        Game__c g = [
            SELECT Id, Name, Opponent__c, Game_Date__c, Home_Away__c, Status__c
            FROM Game__c WHERE Id = :gameId LIMIT 1
        ];

        // ── 실제 데이터 (실시간) ──
        d.opponent = g.Opponent__c != null ? g.Opponent__c : '상대팀 미정';
        d.matchup = 'Cloud Alpacas vs ' + d.opponent;
        d.stadium = g.Home_Away__c == 'Home' ? 'Cloud Stadium' : '원정 구장';
        d.gameDate = g.Game_Date__c != null ? g.Game_Date__c.date().format() : '';

        // ── 시안 고정값 (TODO: 데이터 쌓이면 실제 집계로 교체) ──
        // 티켓 판매량 = 이 경기의 OrderItem 수량 합
        //   → 교체 예시:
        //   AggregateResult ar = [SELECT SUM(Quantity) q FROM OrderItem
        //                         WHERE Order.Game__c = :gameId AND Order.Payment_Status__c='Paid'];
        d.ticketSales = '6,120매';

        // 참석 팬(예상) = 별도 로직/필드 필요 (현재 Game__c에 예상 참석 필드 없음)
        d.expectedAttendance = '8,240명 (예상)';

        // 좌석 현황(%) = 판매 좌석 / 총 좌석 (총 좌석 필드 필요)
        d.seatRate = 74;

        return d;
    }

    public class GameDetail {
        @AuraEnabled public String matchup;
        @AuraEnabled public String opponent;
        @AuraEnabled public String stadium;
        @AuraEnabled public String gameDate;
        @AuraEnabled public String ticketSales;
        @AuraEnabled public String expectedAttendance;
        @AuraEnabled public Integer seatRate;
    }
}
