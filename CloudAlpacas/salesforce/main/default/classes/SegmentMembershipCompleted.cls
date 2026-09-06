/**
 * SegmentMembershipCompleted
 * 세그먼트: 멤버십 전환 완료 팬
 * 조건: 가입일 이후 직관 1회+ AND 가입일 이후 굿즈구매 1회+ (순서무관),
 *       그 후 멤버십 구매까지 완료 (멤버십 구매일이 두 활동일보다 이전이 아니어야 함).
 *       가입 이전 활동은 제외.
 */
public with sharing class SegmentMembershipCompleted {

    @AuraEnabled(cacheable=true)
    public static Integer getCount() {
        return getMatchingFans().size();
    }

    @AuraEnabled(cacheable=true)
    public static List<SegmentFanListItem> getFanList() {
        Map<Id, DateTime> matched = getMatchingFans();
        List<SegmentFanListItem> items = new List<SegmentFanListItem>();
        if (matched.isEmpty()) return items;

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :matched.keySet()]);
        for (Id fanId : matched.keySet()) {
            String name = accounts.containsKey(fanId) ? accounts.get(fanId).Name : '(이름 없음)';
            String detail = '멤버십 전환일: ' + matched.get(fanId).date().format();
            items.add(new SegmentFanListItem(fanId, name, detail));
        }
        return items;
    }

    @AuraEnabled(cacheable=true)
    public static Id getRepresentativeFanId() {
        Map<Id, DateTime> matched = getMatchingFans();
        for (Id fanId : matched.keySet()) {
            return fanId; // 첫 번째 매칭 팬
        }
        return null;
    }

    // 조건에 맞는 팬 Id -> (조건을 만족시킨 멤버십 구매일) 맵
    private static Map<Id, DateTime> getMatchingFans() {
        Map<Id, DateTime> signupDate = new Map<Id, DateTime>();
        for (Account a : [SELECT Id, CreatedDate FROM Account]) {
            signupDate.put(a.Id, a.CreatedDate);
        }

        Map<Id, DateTime> firstAdmissionAfterSignup = new Map<Id, DateTime>();
        for (Admission__c ad : [
            SELECT Fan__c, Admission_Time__c FROM Admission__c
            WHERE Fan__c != null AND Admission_Time__c != null
            ORDER BY Admission_Time__c ASC
        ]) {
            if (!signupDate.containsKey(ad.Fan__c)) continue;
            if (ad.Admission_Time__c < signupDate.get(ad.Fan__c)) continue;
            if (!firstAdmissionAfterSignup.containsKey(ad.Fan__c)) {
                firstAdmissionAfterSignup.put(ad.Fan__c, ad.Admission_Time__c);
            }
        }

        Map<Id, DateTime> firstGoodsAfterSignup = new Map<Id, DateTime>();
        Map<Id, List<DateTime>> membershipDates = new Map<Id, List<DateTime>>();
        for (Order o : [
            SELECT AccountId, Order_Type__c, EffectiveDate
            FROM Order
            WHERE AccountId != null AND EffectiveDate != null
                AND Order_Type__c IN ('Goods Purchase', 'Membership Enrollment')
            ORDER BY EffectiveDate ASC
        ]) {
            DateTime effDt = DateTime.newInstance(o.EffectiveDate, Time.newInstance(0,0,0,0));
            if (!signupDate.containsKey(o.AccountId)) continue;

            if (o.Order_Type__c == 'Goods Purchase') {
                if (effDt < signupDate.get(o.AccountId)) continue;
                if (!firstGoodsAfterSignup.containsKey(o.AccountId)) {
                    firstGoodsAfterSignup.put(o.AccountId, effDt);
                }
            } else {
                if (!membershipDates.containsKey(o.AccountId)) {
                    membershipDates.put(o.AccountId, new List<DateTime>());
                }
                membershipDates.get(o.AccountId).add(effDt);
            }
        }

        Map<Id, DateTime> result = new Map<Id, DateTime>();
        for (Id fanId : firstAdmissionAfterSignup.keySet()) {
            if (!firstGoodsAfterSignup.containsKey(fanId)) continue;
            if (!membershipDates.containsKey(fanId)) continue;

            DateTime admDt = firstAdmissionAfterSignup.get(fanId);
            DateTime goodsDt = firstGoodsAfterSignup.get(fanId);

            for (DateTime memDt : membershipDates.get(fanId)) {
                if (admDt <= memDt && goodsDt <= memDt) {
                    result.put(fanId, memDt); // 조건을 만족시킨 멤버십 구매일 기록
                    break;
                }
            }
        }
        return result;
    }
}
