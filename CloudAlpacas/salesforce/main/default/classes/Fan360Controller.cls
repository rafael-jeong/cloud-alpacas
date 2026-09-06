/**
 * Fan360Controller
 * 추천 탭(05.html) Fan 360 요약 데이터를 조회한다.
 * - getFan360(fanId): 특정 팬 Id로 조회 (Record Page / 버튼 클릭 시)
 * - getRepresentativeFan(): 데모 대표 팬(이루키)을 이름으로 찾아 조회 (App Page 기본 표시용)
 */
public with sharing class Fan360Controller {

    @AuraEnabled(cacheable=true)
    public static Fan360Data getFan360(Id fanId) {
        return buildFan360(fanId);
    }

    // 데모 대표 팬(이루키)을 이름으로 찾아서 반환. 없으면 null.
    @AuraEnabled(cacheable=true)
    public static Fan360Data getRepresentativeFan() {
        List<Account> fans = [
            SELECT Id FROM Account WHERE Name LIKE '%이루키%' LIMIT 1
        ];
        if (fans.isEmpty()) {
            return null;
        }
        return buildFan360(fans[0].Id);
    }

    // 실제 조회 로직 (공통)
    private static Fan360Data buildFan360(Id fanId) {
        Fan360Data data = new Fan360Data();

        // 1. Fan 기본 정보
        Account fan = [
            SELECT Id, Name, Current_Segment__c, Fan_Value_Tier__c,
                   Favorite_Player__r.Name, Favorite_Player__r.Uniform_Number__c
            FROM Account
            WHERE Id = :fanId
            LIMIT 1
        ];
        data.fanId = fan.Id;
        data.fanName = fan.Name;
        data.currentSegment = fan.Current_Segment__c;
        data.fanValueTier = fan.Fan_Value_Tier__c;
        data.favoritePlayer = fan.Favorite_Player__r != null
            ? fan.Favorite_Player__r.Name + ' #' + String.valueOf(fan.Favorite_Player__r.Uniform_Number__c)
            : '없음';

        // 2. 최근 경기 관람
        List<Admission__c> admissions = [
            SELECT Admission_Time__c FROM Admission__c
            WHERE Fan__c = :fanId ORDER BY Admission_Time__c DESC LIMIT 1
        ];
        data.lastAttendance = admissions.isEmpty()
            ? '기록 없음' : admissions[0].Admission_Time__c.date().format();

        // 3. 티켓 / 굿즈 / 멤버십 (Order 집계)
        Integer ticketCount = 0;
        String membership = '없음';
        String goods = '없음';
        for (Order o : [
            SELECT Order_Type__c, Membership_Status__c FROM Order
            WHERE AccountId = :fanId AND Payment_Status__c = 'Paid'
        ]) {
            if (o.Order_Type__c == 'Ticket Purchase') ticketCount++;
            else if (o.Order_Type__c == 'Membership Enrollment') membership = 'Standard · ' + o.Membership_Status__c;
            else if (o.Order_Type__c == 'Goods Purchase') goods = '문태양 유니폼(홈)';
        }
        data.ticketPurchase = ticketCount + '매';
        data.membership = membership;
        data.merchPurchase = goods;

        // 4. LTV
        Decimal totalSpend = 0;
        for (Fan_Activity_Pattern__c fap : [
            SELECT Total_Spend__c FROM Fan_Activity_Pattern__c WHERE Fan__c = :fanId
        ]) {
            if (fap.Total_Spend__c != null) totalSpend += fap.Total_Spend__c;
        }
        data.ltv = '₩' + totalSpend.format();

        // 5. 타임라인 (Notification_Log 최근 5건)
        List<TimelineItem> timeline = new List<TimelineItem>();
        for (Notification_Log__c n : [
            SELECT Content__c, Sent_Date__c FROM Notification_Log__c
            WHERE Fan__c = :fanId ORDER BY Sent_Date__c DESC LIMIT 5
        ]) {
            TimelineItem t = new TimelineItem();
            t.type = '캠페인';
            t.text = n.Content__c;
            t.whenText = n.Sent_Date__c != null ? n.Sent_Date__c.date().format() : '';
            timeline.add(t);
        }
        data.timeline = timeline;

        return data;
    }

    public class Fan360Data {
        @AuraEnabled public String fanId;
        @AuraEnabled public String fanName;
        @AuraEnabled public String currentSegment;
        @AuraEnabled public String fanValueTier;
        @AuraEnabled public String favoritePlayer;
        @AuraEnabled public String lastAttendance;
        @AuraEnabled public String ticketPurchase;
        @AuraEnabled public String merchPurchase;
        @AuraEnabled public String membership;
        @AuraEnabled public String ltv;
        @AuraEnabled public List<TimelineItem> timeline;
    }

    public class TimelineItem {
        @AuraEnabled public String type;
        @AuraEnabled public String text;
        @AuraEnabled public String whenText;
    }
}
