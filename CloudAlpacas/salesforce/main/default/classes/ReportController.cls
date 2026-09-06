/**
 * ReportController
 * 리포트 탭(09 시안) 데이터를 조회한다.
 * - 매출 카드: 채널별로 "데이터가 있는 가장 최근 달" vs "그 직전 달" 비교 (실시간)
 * - 세그먼트 구성: Engagement_Level__c 실제 분포 (실시간)
 * - 퍼널: CampaignMember/Order 실제 집계 (실시간)
 * - 세그먼트별 전환율: 이력 데이터가 없어 시안 고정값 (TODO: 이력 추적 생기면 교체)
 * - 관람→굿즈전환/멤버십전환: Admission/Order 실제 집계 (실시간)
 */
public with sharing class ReportController {

    @AuraEnabled(cacheable=true)
    public static ReportData getReportData() {
        ReportData d = new ReportData();

        // ── 1. 매출 카드 (채널별 최근월 vs 직전월) ──
        d.onlineRevenue = buildRevenueCard('Online');
        d.stadiumRevenue = buildRevenueCard('Stadium');

        // ── 2. 세그먼트 구성 (Engagement_Level__c) ──
        d.segmentDistribution = new List<SegmentCount>();
        Integer totalFans = 0;
        Map<String, Integer> segCounts = new Map<String, Integer>();
        for (AggregateResult ar : [
            SELECT Engagement_Level__c lvl, COUNT(Id) cnt
            FROM Account
            WHERE Engagement_Level__c != null
            GROUP BY Engagement_Level__c
        ]) {
            String lvl = (String) ar.get('lvl');
            Integer cnt = (Integer) ar.get('cnt');
            segCounts.put(lvl, cnt);
            totalFans += cnt;
        }
        for (String lvl : segCounts.keySet()) {
            SegmentCount sc = new SegmentCount();
            sc.label = lvl;
            sc.count = segCounts.get(lvl);
            sc.percent = totalFans > 0 ? Math.round((sc.count * 100.0) / totalFans) : 0;
            d.segmentDistribution.add(sc);
        }
        d.segmentTotal = totalFans;

        // ── 3. 퍼널 ──
        Integer totalPersonAccounts = [SELECT COUNT() FROM Account];
        Integer campaignMembers = 0;
        for (AggregateResult ar : [SELECT COUNT_DISTINCT(ContactId) cnt FROM CampaignMember]) {
            campaignMembers = (Integer) ar.get('cnt');
        }
        Integer responded = 0;
        for (AggregateResult ar : [SELECT COUNT_DISTINCT(ContactId) cnt FROM CampaignMember WHERE Status = 'Responded']) {
            responded = (Integer) ar.get('cnt');
        }
        Integer purchasedFans = 0;
        for (AggregateResult ar : [SELECT COUNT_DISTINCT(AccountId) cnt FROM Order WHERE AccountId != null]) {
            purchasedFans = (Integer) ar.get('cnt');
        }
        // 재방문/전환: Order 2건 이상인 팬
        Integer repeatFans = 0;
        Map<Id, Integer> orderCountByFan = new Map<Id, Integer>();
        for (AggregateResult ar : [SELECT AccountId acc, COUNT(Id) cnt FROM Order WHERE AccountId != null GROUP BY AccountId]) {
            Integer c = (Integer) ar.get('cnt');
            if (c >= 2) repeatFans++;
        }

        d.funnel = new List<FunnelStep>();
        d.funnel.add(makeFunnelStep('대상 팬', totalPersonAccounts, totalPersonAccounts));
        d.funnel.add(makeFunnelStep('Campaign 참여', campaignMembers, totalPersonAccounts));
        d.funnel.add(makeFunnelStep('클릭 / 반응', responded, totalPersonAccounts));
        d.funnel.add(makeFunnelStep('구매', purchasedFans, totalPersonAccounts));
        d.funnel.add(makeFunnelStep('재방문 / 전환', repeatFans, totalPersonAccounts));

        // ── 4. 세그먼트별 전환율 (고정값 — 이력 데이터 없음) ──
        d.tierConversion = new List<TierRate>();
        d.tierConversion.add(makeTierRate('VIP', 61));
        d.tierConversion.add(makeTierRate('충성', 34));
        d.tierConversion.add(makeTierRate('활동', 22));
        d.tierConversion.add(makeTierRate('관심', 9));

        // ── 5. 관람→굿즈전환 / 멤버십전환 ──
        Set<Id> admissionFans = new Set<Id>();
        for (AggregateResult ar : [SELECT Fan__c f FROM Admission__c WHERE Fan__c != null GROUP BY Fan__c]) {
            admissionFans.add((Id) ar.get('f'));
        }
        Set<Id> goodsFans = new Set<Id>();
        for (AggregateResult ar : [SELECT AccountId a FROM Order WHERE Order_Type__c = 'Goods Purchase' AND AccountId != null GROUP BY AccountId]) {
            goodsFans.add((Id) ar.get('a'));
        }
        Integer admissionCount = admissionFans.size();
        Integer goodsConvertedCount = 0;
        for (Id fanId : admissionFans) {
            if (goodsFans.contains(fanId)) goodsConvertedCount++;
        }

        Set<Id> membershipFans = new Set<Id>();
        for (AggregateResult ar : [SELECT AccountId a FROM Order WHERE Order_Type__c = 'Membership Enrollment' AND AccountId != null GROUP BY AccountId]) {
            membershipFans.add((Id) ar.get('a'));
        }

        d.attendanceToGoods = new ConversionPair();
        d.attendanceToGoods.fromLabel = '경기 관람 팬';
        d.attendanceToGoods.fromCount = admissionCount;
        d.attendanceToGoods.toLabel = '굿즈 구매 전환';
        d.attendanceToGoods.toCount = goodsConvertedCount;
        d.attendanceToGoods.rate = admissionCount > 0 ? Math.round((goodsConvertedCount * 100.0) / admissionCount) : 0;

        d.visitToMembership = new ConversionPair();
        d.visitToMembership.fromLabel = '비회원 방문 팬';
        d.visitToMembership.fromCount = totalPersonAccounts;
        d.visitToMembership.toLabel = '멤버십 전환';
        d.visitToMembership.toCount = membershipFans.size();
        d.visitToMembership.rate = totalPersonAccounts > 0 ? Math.round((membershipFans.size() * 100.0) / totalPersonAccounts) : 0;

        return d;
    }

    // ── 채널별 매출 카드 생성 (데이터 있는 최근월 vs 직전월) ──
    private static RevenueCard buildRevenueCard(String channel) {
        RevenueCard card = new RevenueCard();
        card.channelLabel = channel == 'Online' ? '온라인 굿즈' : '구장 오프라인 굿즈';

        List<Order> orders = [
            SELECT EffectiveDate, TotalAmount
            FROM Order
            WHERE Order_Type__c = 'Goods Purchase' AND Purchase_Channel__c = :channel AND EffectiveDate != null
            ORDER BY EffectiveDate DESC
        ];

        if (orders.isEmpty()) {
            card.thisAmount = 0;
            card.lastAmount = 0;
            card.percentChange = 0;
            card.isUp = true;
            return card;
        }

        Date latest = orders[0].EffectiveDate;
        Integer thisY = latest.year();
        Integer thisM = latest.month();
        Date lastMonthDate = latest.addMonths(-1);
        Integer lastY = lastMonthDate.year();
        Integer lastM = lastMonthDate.month();

        Decimal thisTotal = 0;
        Decimal lastTotal = 0;
        for (Order o : orders) {
            if (o.EffectiveDate.year() == thisY && o.EffectiveDate.month() == thisM) {
                thisTotal += (o.TotalAmount != null ? o.TotalAmount : 0);
            } else if (o.EffectiveDate.year() == lastY && o.EffectiveDate.month() == lastM) {
                lastTotal += (o.TotalAmount != null ? o.TotalAmount : 0);
            }
        }

        card.thisAmount = thisTotal;
        card.lastAmount = lastTotal;
        if (lastTotal > 0) {
            card.percentChange = Math.abs(Math.round(((thisTotal - lastTotal) / lastTotal) * 1000) / 10.0);
            card.isUp = thisTotal >= lastTotal;
        } else {
            card.percentChange = 0;
            card.isUp = true;
        }
        return card;
    }

    private static FunnelStep makeFunnelStep(String label, Integer count, Integer base) {
        FunnelStep s = new FunnelStep();
        s.label = label;
        s.count = count;
        s.percent = base > 0 ? Math.round((count * 100.0) / base) : 0;
        return s;
    }

    private static TierRate makeTierRate(String label, Integer rate) {
        TierRate t = new TierRate();
        t.label = label;
        t.rate = rate;
        return t;
    }

    // ── Wrapper 클래스들 ──
    public class ReportData {
        @AuraEnabled public RevenueCard onlineRevenue;
        @AuraEnabled public RevenueCard stadiumRevenue;
        @AuraEnabled public List<SegmentCount> segmentDistribution;
        @AuraEnabled public Integer segmentTotal;
        @AuraEnabled public List<FunnelStep> funnel;
        @AuraEnabled public List<TierRate> tierConversion;
        @AuraEnabled public ConversionPair attendanceToGoods;
        @AuraEnabled public ConversionPair visitToMembership;
    }

    public class RevenueCard {
        @AuraEnabled public String channelLabel;
        @AuraEnabled public Decimal thisAmount;
        @AuraEnabled public Decimal lastAmount;
        @AuraEnabled public Decimal percentChange;
        @AuraEnabled public Boolean isUp;
    }

    public class SegmentCount {
        @AuraEnabled public String label;
        @AuraEnabled public Integer count;
        @AuraEnabled public Integer percent;
    }

    public class FunnelStep {
        @AuraEnabled public String label;
        @AuraEnabled public Integer count;
        @AuraEnabled public Integer percent;
    }

    public class TierRate {
        @AuraEnabled public String label;
        @AuraEnabled public Integer rate;
    }

    public class ConversionPair {
        @AuraEnabled public String fromLabel;
        @AuraEnabled public Integer fromCount;
        @AuraEnabled public String toLabel;
        @AuraEnabled public Integer toCount;
        @AuraEnabled public Integer rate;
    }
}
