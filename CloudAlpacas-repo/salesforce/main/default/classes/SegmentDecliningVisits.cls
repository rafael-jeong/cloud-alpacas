/**
 * SegmentDecliningVisits
 * 세그먼트: 최근 30일 관람 감소
 * 조건: 멤버십 만료일이 오늘로부터 45~75일 남은 팬 중,
 *       최근 30일 관람 횟수가 "가입 이후 30일당 평균 관람 횟수"의 40% 이하인 사람.
 *       (평균 자체가 0이면 "감소"를 판단할 기준이 없으므로 제외)
 */
public with sharing class SegmentDecliningVisits {

    @AuraEnabled(cacheable=true)
    public static Integer getCount() {
        return getMatchingFans().size();
    }

    @AuraEnabled(cacheable=true)
    public static List<SegmentFanListItem> getFanList() {
        Map<Id, Decimal> matched = getMatchingFans(); // fanId -> 감소율(%)
        List<SegmentFanListItem> items = new List<SegmentFanListItem>();
        if (matched.isEmpty()) return items;

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :matched.keySet()]);
        for (Id fanId : matched.keySet()) {
            String name = accounts.containsKey(fanId) ? accounts.get(fanId).Name : '(이름 없음)';
            Integer pct = (matched.get(fanId) * 100).intValue();
            String detail = '평균 대비 ' + pct + '%로 감소';
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

    // 조건에 맞는 팬 Id -> (최근30일 관람 / 평균) 비율 맵
    private static Map<Id, Decimal> getMatchingFans() {
        Date today = Date.today();

        Set<Id> eligibleFans = new Set<Id>();
        for (Order o : [
            SELECT AccountId
            FROM Order
            WHERE Order_Type__c = 'Membership Enrollment'
                AND Coverage_End_Date__c != null
                AND Coverage_End_Date__c >= :today.addDays(45)
                AND Coverage_End_Date__c <= :today.addDays(75)
                AND AccountId != null
        ]) {
            eligibleFans.add(o.AccountId);
        }
        Map<Id, Decimal> result = new Map<Id, Decimal>();
        if (eligibleFans.isEmpty()) return result;

        Map<Id, Date> signupDate = new Map<Id, Date>();
        for (Account a : [SELECT Id, CreatedDate FROM Account WHERE Id IN :eligibleFans]) {
            signupDate.put(a.Id, a.CreatedDate.date());
        }

        Map<Id, Integer> totalAdmissions = new Map<Id, Integer>();
        Map<Id, Integer> recent30Admissions = new Map<Id, Integer>();
        Date recentCutoff = today.addDays(-30);

        for (Admission__c ad : [
            SELECT Fan__c, Admission_Time__c
            FROM Admission__c
            WHERE Fan__c IN :eligibleFans AND Admission_Time__c != null
        ]) {
            Date admDate = ad.Admission_Time__c.date();
            if (!signupDate.containsKey(ad.Fan__c)) continue;
            if (admDate < signupDate.get(ad.Fan__c)) continue;

            totalAdmissions.put(ad.Fan__c, (totalAdmissions.containsKey(ad.Fan__c) ? totalAdmissions.get(ad.Fan__c) : 0) + 1);
            if (admDate >= recentCutoff) {
                recent30Admissions.put(ad.Fan__c, (recent30Admissions.containsKey(ad.Fan__c) ? recent30Admissions.get(ad.Fan__c) : 0) + 1);
            }
        }

        for (Id fanId : eligibleFans) {
            Integer total = totalAdmissions.containsKey(fanId) ? totalAdmissions.get(fanId) : 0;
            Integer recent30 = recent30Admissions.containsKey(fanId) ? recent30Admissions.get(fanId) : 0;

            Integer daysSinceSignup = signupDate.get(fanId).daysBetween(today);
            if (daysSinceSignup <= 0) continue;

            Decimal avgPer30 = (Decimal.valueOf(total) / daysSinceSignup) * 30;
            if (avgPer30 <= 0) continue;

            Decimal ratio = recent30 / avgPer30;
            if (ratio <= 0.4) {
                result.put(fanId, ratio);
            }
        }
        return result;
    }
}
