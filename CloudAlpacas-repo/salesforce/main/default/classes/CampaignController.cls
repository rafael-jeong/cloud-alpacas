/**
 * CampaignController
 * 캠페인 탭 카드 데이터. 우리 팀 4개 캠페인만 이름으로 필터링해서 조회.
 * (org에 있는 Salesforce 데모/샘플 Campaign은 제외)
 *
 * 실시간 계산 방식 (2026-08 개편):
 *   발송(numberSent)   = Notification_Log__c 건수 (실제 발송 기록)
 *   진행률(progress)   = 발송 수 ÷ CampaignMember 전체 수 × 100 (목표 대비 발송 진행률)
 *   클릭률(clickRate)  = CampaignMember 중 Responded 수 ÷ (Sent+Responded) × 100
 *   대상 인원(targetCount) = CampaignMember 전체 수
 */
public with sharing class CampaignController {

    private static final Set<String> TEAM_CAMPAIGNS = new Set<String>{
        'Welcome Campaign',
        'First Ticket Campaign',
        'First Merchandise Campaign',
        'Favorite Player Campaign'
    };

    @AuraEnabled(cacheable=true)
    public static List<CampaignCard> getCampaigns() {
        List<CampaignCard> cards = new List<CampaignCard>();

        List<Campaign> camps = [
            SELECT Id, Name, Status, Description, StartDate
            FROM Campaign
            WHERE Name IN :TEAM_CAMPAIGNS
            ORDER BY StartDate
        ];

        if (camps.isEmpty()) {
            return demoCards();
        }

        Set<Id> campaignIds = new Set<Id>();
        for (Campaign c : camps) campaignIds.add(c.Id);

        // 캠페인별 발송(Notification_Log__c) 건수
        Map<Id, Integer> sentCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Campaign__c c, COUNT(Id) cnt FROM Notification_Log__c
            WHERE Campaign__c IN :campaignIds GROUP BY Campaign__c
        ]) {
            sentCounts.put((Id) ar.get('c'), (Integer) ar.get('cnt'));
        }

        // 캠페인별 CampaignMember 전체 수 / Responded 수
        Map<Id, Integer> memberTotal = new Map<Id, Integer>();
        Map<Id, Integer> memberResponded = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT CampaignId c, Status s, COUNT(Id) cnt FROM CampaignMember
            WHERE CampaignId IN :campaignIds GROUP BY CampaignId, Status
        ]) {
            Id campId = (Id) ar.get('c');
            String status = (String) ar.get('s');
            Integer cnt = (Integer) ar.get('cnt');

            memberTotal.put(campId, (memberTotal.containsKey(campId) ? memberTotal.get(campId) : 0) + cnt);
            if (status == 'Responded') {
                memberResponded.put(campId, (memberResponded.containsKey(campId) ? memberResponded.get(campId) : 0) + cnt);
            }
        }

        for (Campaign c : camps) {
            CampaignCard card = new CampaignCard();
            card.name = c.Name;
            card.status = mapStatus(c.Status);
            card.target = c.Description != null ? c.Description : '대상 미지정';
            card.scheduledDate = c.StartDate != null ? c.StartDate.format() : '';

            Integer totalMembers = memberTotal.containsKey(c.Id) ? memberTotal.get(c.Id) : 0;
            Integer sentCount = sentCounts.containsKey(c.Id) ? sentCounts.get(c.Id) : 0;
            Integer respondedCount = memberResponded.containsKey(c.Id) ? memberResponded.get(c.Id) : 0;

            card.numberSent = sentCount;
            card.targetCount = totalMembers;
            card.progress = totalMembers > 0 ? Math.round((sentCount * 100.0) / totalMembers) : 0;
            card.clickRate = totalMembers > 0 ? Math.round((respondedCount * 100.0) / totalMembers) : 0;
            card.isScheduled = (card.status == '예약됨');

            cards.add(card);
        }
        return cards;
    }

    private static String mapStatus(String s) {
        if (s == null) return '진행 중';
        if (s == 'Completed' || s == 'Aborted') return '종료';
        if (s == 'Planned') return '예약됨';
        return '진행 중';
    }

    // 실제 Campaign 레코드가 없을 때만 쓰는 데모 fallback (기존 유지)
    private static List<CampaignCard> demoCards() {
        List<CampaignCard> lst = new List<CampaignCard>();
        lst.add(makeCard('Welcome Campaign', '진행 중', 'New Fan', 43, 512, 48, false, 0, ''));
        lst.add(makeCard('First Ticket Campaign', '예약됨', '가입 후 미구매 팬', 0, 0, 0, true, 1580, '8/20'));
        lst.add(makeCard('First Merchandise Campaign', '예약됨', '굿즈 미구매 팬', 0, 0, 0, true, 2310, '8/12'));
        lst.add(makeCard('Favorite Player Campaign', '종료', '문태양 팬 세그먼트', 100, 890, 61, false, 0, ''));
        return lst;
    }

    private static CampaignCard makeCard(String name, String status, String target,
            Integer progress, Integer numberSent, Integer clickRate,
            Boolean isScheduled, Decimal targetCount, String scheduledDate) {
        CampaignCard c = new CampaignCard();
        c.name = name; c.status = status; c.target = target;
        c.progress = progress; c.numberSent = numberSent; c.clickRate = clickRate;
        c.isScheduled = isScheduled; c.targetCount = targetCount; c.scheduledDate = scheduledDate;
        return c;
    }

    public class CampaignCard {
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public String target;
        @AuraEnabled public Integer progress;
        @AuraEnabled public Integer numberSent;
        @AuraEnabled public Integer clickRate;
        @AuraEnabled public Boolean isScheduled;
        @AuraEnabled public Decimal targetCount;
        @AuraEnabled public String scheduledDate;
    }
}
