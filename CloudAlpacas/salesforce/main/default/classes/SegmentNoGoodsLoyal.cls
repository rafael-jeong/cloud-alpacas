/**
 * SegmentNoGoodsLoyal
 * 세그먼트: 굿즈 미구매 충성 팬
 * 조건: 현재 시즌(가장 최근 시작된 Season__c) 기준으로, 지금까지 열린 경기 수 대비
 *       관람 비율이 40% 이상인 팬 AND 굿즈 구매(Order, Goods Purchase) 이력이 0건.
 */
public with sharing class SegmentNoGoodsLoyal {

    private static final Decimal THRESHOLD = 0.4;

    @AuraEnabled(cacheable=true)
    public static Integer getCount() {
        return getMatchingFans().size();
    }

    @AuraEnabled(cacheable=true)
    public static List<SegmentFanListItem> getFanList() {
        Map<Id, Decimal> matched = getMatchingFans(); // fanId -> 관람비율
        List<SegmentFanListItem> items = new List<SegmentFanListItem>();
        if (matched.isEmpty()) return items;

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :matched.keySet()]);
        for (Id fanId : matched.keySet()) {
            String name = accounts.containsKey(fanId) ? accounts.get(fanId).Name : '(이름 없음)';
            Integer pct = (matched.get(fanId) * 100).intValue();
            String detail = '이번 시즌 관람비율 ' + pct + '%';
            items.add(new SegmentFanListItem(fanId, name, detail));
        }
        return items;
    }

    @AuraEnabled(cacheable=true)
    public static Id getRepresentativeFanId() {
        Map<Id, Decimal> matched = getMatchingFans();
        for (Id fanId : matched.keySet()) {
            return fanId;
        }
        return null;
    }

    // 조건에 맞는 팬 Id -> 관람비율 맵
    private static Map<Id, Decimal> getMatchingFans() {
        Map<Id, Decimal> result = new Map<Id, Decimal>();

        List<Game__c> latestGames = [
            SELECT Season__c FROM Game__c WHERE Season__c != null ORDER BY Game_Date__c DESC LIMIT 1
        ];
        if (latestGames.isEmpty()) return result;
        Id currentSeasonId = latestGames[0].Season__c;

        Date today = Date.today();
        List<Game__c> pastGamesThisSeason = [
            SELECT Id FROM Game__c WHERE Season__c = :currentSeasonId AND Game_Date__c <= :today
        ];
        Integer totalGamesSoFar = pastGamesThisSeason.size();
        if (totalGamesSoFar == 0) return result;

        Set<Id> pastGameIds = new Set<Id>();
        for (Game__c g : pastGamesThisSeason) pastGameIds.add(g.Id);

        Map<Id, Integer> attendanceCount = new Map<Id, Integer>();
        for (Admission__c ad : [
            SELECT Fan__c FROM Admission__c WHERE Game__c IN :pastGameIds AND Fan__c != null
        ]) {
            attendanceCount.put(ad.Fan__c, (attendanceCount.containsKey(ad.Fan__c) ? attendanceCount.get(ad.Fan__c) : 0) + 1);
        }

        Set<Id> goodsFans = new Set<Id>();
        for (AggregateResult ar : [
            SELECT AccountId a FROM Order
            WHERE Order_Type__c = 'Goods Purchase' AND AccountId != null
            GROUP BY AccountId
        ]) {
            goodsFans.add((Id) ar.get('a'));
        }

        for (Id fanId : attendanceCount.keySet()) {
            if (goodsFans.contains(fanId)) continue;

            Decimal ratio = Decimal.valueOf(attendanceCount.get(fanId)) / totalGamesSoFar;
            if (ratio >= THRESHOLD) {
                result.put(fanId, ratio);
            }
        }
        return result;
    }
}
