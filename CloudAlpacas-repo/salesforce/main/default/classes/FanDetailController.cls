/**
 * FanDetailController
 * Fan(Person Account) 상세 페이지의 Summary / Recommended Actions / Timeline 탭 데이터를 제공한다.
 */
public with sharing class FanDetailController {

    // ══════════════════════════════════════════
    // 1. Summary — 팬 건강도 + 고객 스냅샷
    // ══════════════════════════════════════════
    @AuraEnabled(cacheable=true)
    public static FanSummary getFanSummary(Id fanId) {
        FanSummary s = new FanSummary();

        Account acc = [
            SELECT Id, Engagement_Score__c, Engagement_Level__c, Fan_Value_Tier__c
            FROM Account WHERE Id = :fanId LIMIT 1
        ];
        s.engagementScore = acc.Engagement_Score__c != null ? acc.Engagement_Score__c.intValue() : 0;
        s.engagementLevel = acc.Engagement_Level__c;
        s.fanValueTier = acc.Fan_Value_Tier__c;

        // 경기 관람 횟수 (Attendance_Record__c 집계 레코드)
        List<Attendance_Record__c> ars = [
            SELECT Total_Admissions__c FROM Attendance_Record__c WHERE Fan__c = :fanId LIMIT 1
        ];
        s.attendanceCount = (!ars.isEmpty() && ars[0].Total_Admissions__c != null)
            ? ars[0].Total_Admissions__c.intValue() : 0;

        // 구매 건수 (Order 집계)
        Integer ticketCount = 0, onlineGoods = 0, stadiumGoods = 0;
        String membershipStatus = '없음';
        for (Order o : [
            SELECT Order_Type__c, Purchase_Channel__c, Membership_Status__c
            FROM Order WHERE AccountId = :fanId
        ]) {
            if (o.Order_Type__c == 'Ticket Purchase') {
                ticketCount++;
            } else if (o.Order_Type__c == 'Goods Purchase') {
                if (o.Purchase_Channel__c == 'Online') onlineGoods++;
                else if (o.Purchase_Channel__c == 'Stadium') stadiumGoods++;
            } else if (o.Order_Type__c == 'Membership Enrollment') {
                membershipStatus = o.Membership_Status__c != null ? o.Membership_Status__c : '가입됨';
            }
        }
        s.ticketPurchaseCount = ticketCount;
        s.onlineGoodsCount = onlineGoods;
        s.stadiumGoodsCount = stadiumGoods;
        s.membershipStatus = membershipStatus;

        // LTV (Fan_Activity_Pattern__c 누적)
        Decimal totalSpend = 0;
        for (Fan_Activity_Pattern__c fap : [
            SELECT Total_Spend__c FROM Fan_Activity_Pattern__c WHERE Fan__c = :fanId
        ]) {
            if (fap.Total_Spend__c != null) totalSpend += fap.Total_Spend__c;
        }
        s.ltv = totalSpend;

        return s;
    }

    // ══════════════════════════════════════════
    // 2. Recommended Actions — Next Best Actions
    // ══════════════════════════════════════════
    @AuraEnabled(cacheable=true)
    public static List<ActionCard> getRecommendedActions(Id fanId) {
        List<ActionCard> cards = new List<ActionCard>();
        for (Recommendations__c r : [
            SELECT Id, Recommended_Action__c, Reason__c, Status__c
            FROM Recommendations__c
            WHERE Fan__c = :fanId AND Status__c = 'Pending'
            ORDER BY CreatedDate DESC
        ]) {
            ActionCard c = new ActionCard();
            c.id = r.Id;
            c.actionLabel = actionLabel(r.Recommended_Action__c);
            c.reason = r.Reason__c;
            c.priority = priorityFor(r.Recommended_Action__c); // TODO: 실제 Priority__c 필드 생기면 교체
            cards.add(c);
        }
        return cards;
    }

    // 액션 버튼 클릭 → 조치 완료 처리 (Status__c = Executed)
    @AuraEnabled
    public static void markActionExecuted(Id recommendationId) {
        Recommendations__c r = new Recommendations__c(Id = recommendationId, Status__c = 'Executed');
        update r;
    }

    private static String actionLabel(String raw) {
        Map<String, String> labels = new Map<String, String>{
            'Welcome Message' => '웰컴 메시지 발송',
            'First Ticket Campaign' => '첫 티켓 구매 유도',
            'First Visit Guide' => '첫 방문 안내',
            'First Merchandise Campaign' => '굿즈 구매 유도',
            'Favorite Player Campaign' => '최애 선수 콘텐츠 발송',
            'Membership Campaign' => '멤버십 갱신 안내'
        };
        return labels.containsKey(raw) ? labels.get(raw) : raw;
    }

    // MVP 임시 우선순위 매핑 (실제 Priority__c 필드 없음 — TODO)
    private static String priorityFor(String action) {
        if (action == 'Membership Campaign' || action == 'First Visit Guide') return '높음';
        if (action == 'Favorite Player Campaign' || action == 'First Merchandise Campaign') return '중간';
        return '낮음';
    }

    // ══════════════════════════════════════════
    // 3. Timeline — 여러 Object를 시간순 통합
    // ══════════════════════════════════════════
    @AuraEnabled(cacheable=true)
    public static List<TimelineItem> getFanTimeline(Id fanId) {
        List<TimelineItem> items = new List<TimelineItem>();

        // 티켓/굿즈 구매 (Order)
        for (Order o : [
            SELECT Order_Type__c, EffectiveDate, TotalAmount
            FROM Order WHERE AccountId = :fanId AND Order_Type__c IN ('Ticket Purchase', 'Goods Purchase')
        ]) {
            TimelineItem t = new TimelineItem();
            t.type = o.Order_Type__c == 'Ticket Purchase' ? '티켓 구매' : '굿즈 구매';
            t.title = t.type + (o.TotalAmount != null ? ' · ₩' + o.TotalAmount.format() : '');
            t.dateVal = o.EffectiveDate != null ? DateTime.newInstance(o.EffectiveDate, Time.newInstance(0,0,0,0)) : null;
            t.dateDisplay = o.EffectiveDate != null ? o.EffectiveDate.format() : '';
            items.add(t);
        }

        // 경기장 방문 (Admission__c)
        for (Admission__c a : [
            SELECT Admission_Time__c, Game__r.Opponent__c
            FROM Admission__c WHERE Fan__c = :fanId
        ]) {
            TimelineItem t = new TimelineItem();
            t.type = '경기장 방문';
            t.title = '경기장 방문' + (a.Game__r != null && a.Game__r.Opponent__c != null ? ' · vs ' + a.Game__r.Opponent__c : '');
            t.dateVal = a.Admission_Time__c;
            t.dateDisplay = a.Admission_Time__c != null ? a.Admission_Time__c.format('yyyy.MM.dd') : '';
            items.add(t);
        }

        // 캠페인 반응 (Notification_Log__c)
        for (Notification_Log__c n : [
            SELECT Content__c, Sent_Date__c FROM Notification_Log__c WHERE Fan__c = :fanId
        ]) {
            TimelineItem t = new TimelineItem();
            t.type = '캠페인 반응';
            t.title = n.Content__c;
            t.dateVal = n.Sent_Date__c;
            t.dateDisplay = n.Sent_Date__c != null ? n.Sent_Date__c.format('yyyy.MM.dd') : '';
            items.add(t);
        }

        // 문의 (Case)
        for (Case c : [
            SELECT Subject, Status, CreatedDate FROM Case WHERE AccountId = :fanId
        ]) {
            TimelineItem t = new TimelineItem();
            t.type = '문의';
            t.title = (c.Subject != null ? c.Subject : '문의') + ' · ' + c.Status;
            t.dateVal = c.CreatedDate;
            t.dateDisplay = c.CreatedDate != null ? c.CreatedDate.format('yyyy.MM.dd') : '';
            items.add(t);
        }

        // 최신순 정렬
        items.sort();
        return items;
    }

    // ══════════════════════════════════════════
    // Wrapper 클래스들
    // ══════════════════════════════════════════
    public class FanSummary {
        @AuraEnabled public Integer engagementScore;
        @AuraEnabled public String engagementLevel;
        @AuraEnabled public String fanValueTier;
        @AuraEnabled public Integer attendanceCount;
        @AuraEnabled public Integer ticketPurchaseCount;
        @AuraEnabled public Integer onlineGoodsCount;
        @AuraEnabled public Integer stadiumGoodsCount;
        @AuraEnabled public String membershipStatus;
        @AuraEnabled public Decimal ltv;
    }

    public class ActionCard {
        @AuraEnabled public Id id;
        @AuraEnabled public String actionLabel;
        @AuraEnabled public String reason;
        @AuraEnabled public String priority;
    }

    public class TimelineItem implements Comparable {
        @AuraEnabled public String type;
        @AuraEnabled public String title;
        @AuraEnabled public DateTime dateVal;
        @AuraEnabled public String dateDisplay;

        public Integer compareTo(Object other) {
            TimelineItem o = (TimelineItem) other;
            if (this.dateVal == null && o.dateVal == null) return 0;
            if (this.dateVal == null) return 1;
            if (o.dateVal == null) return -1;
            return o.dateVal < this.dateVal ? -1 : (o.dateVal > this.dateVal ? 1 : 0);
        }
    }
}
