/**
 * SegmentNoVisitAfterSignup
 * 세그먼트: 가입 후 경기 미관람
 * 조건: 가입 후 21일 이상 경과 AND 앱 방문(Engagement_Signal__c, App Open) 1회 이상 있음
 *       AND 티켓 구매(Order, Ticket Purchase) 이력 0건
 */
public with sharing class SegmentNoVisitAfterSignup {

    @AuraEnabled(cacheable=true)
    public static Integer getCount() {
        return getMatchingFans().size();
    }

    @AuraEnabled(cacheable=true)
    public static List<SegmentFanListItem> getFanList() {
        Map<Id, Integer> matched = getMatchingFans();
        List<SegmentFanListItem> items = new List<SegmentFanListItem>();
        if (matched.isEmpty()) return items;

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name, CreatedDate FROM Account WHERE Id IN :matched.keySet()]);
        for (Id fanId : matched.keySet()) {
            String name = accounts.containsKey(fanId) ? accounts.get(fanId).Name : '(이름 없음)';
            Integer daysAgo = accounts.containsKey(fanId)
                ? accounts.get(fanId).CreatedDate.date().daysBetween(Date.today()) : 0;
            String detail = '가입 ' + daysAgo + '일 경과 · 앱 방문 ' + matched.get(fanId) + '회';
            items.add(new SegmentFanListItem(fanId, name, detail));
        }
        return items;
    }

    @AuraEnabled(cacheable=true)
    public static Id getRepresentativeFanId() {
        Map<Id, Integer> matched = getMatchingFans();
        for (Id fanId : matched.keySet()) {
            return fanId;
        }
        return null;
    }

    // 조건에 맞는 팬 Id -> 앱 방문(App Open) 횟수 맵
    private static Map<Id, Integer> getMatchingFans() {
        DateTime cutoff = DateTime.now().addDays(-21);

        Set<Id> eligibleBySignupAge = new Set<Id>();
        for (Account a : [SELECT Id FROM Account WHERE CreatedDate <= :cutoff]) {
            eligibleBySignupAge.add(a.Id);
        }

        Map<Id, Integer> appOpenCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Fan__c f, COUNT(Id) cnt FROM Engagement_Signal__c
            WHERE Signal_Type__c = 'App Open' AND Fan__c != null
            GROUP BY Fan__c
        ]) {
            appOpenCounts.put((Id) ar.get('f'), (Integer) ar.get('cnt'));
        }

        Set<Id> ticketPurchasedFans = new Set<Id>();
        for (AggregateResult ar : [
            SELECT AccountId a FROM Order
            WHERE Order_Type__c = 'Ticket Purchase' AND AccountId != null
            GROUP BY AccountId
        ]) {
            ticketPurchasedFans.add((Id) ar.get('a'));
        }

        Map<Id, Integer> result = new Map<Id, Integer>();
        for (Id fanId : eligibleBySignupAge) {
            if (appOpenCounts.containsKey(fanId) && !ticketPurchasedFans.contains(fanId)) {
                result.put(fanId, appOpenCounts.get(fanId));
            }
        }
        return result;
    }
}
