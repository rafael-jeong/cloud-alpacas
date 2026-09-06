/**
 * Supplies upsell-oriented data for a sponsor Account so an account manager can
 * decide whether to move an existing sponsor up to a higher package tier next season.
 * Powers the sponsorUpsellPanel LWC on the Account record page.
 */
public with sharing class SponsorUpsellController {

    private static final List<String> TIER_ORDER = new List<String>{ 'Gold', 'Platinum', 'Diamond' };

    // Standard Price Book price for each package tier (KRW).
    private static final Map<String, Decimal> TIER_PRICE = new Map<String, Decimal>{
        'Gold' => 261000000.0, 'Platinum' => 1242000000.0, 'Diamond' => 5220000000.0
    };

    // Each à-la-carte right belongs to the lowest package tier that unlocks it.
    private static final Map<String, String> RIGHT_TIER = new Map<String, String>{
        'SPN-APP-BANNER' => 'Gold', 'SPN-FENCE-OUTFIELD' => 'Gold',
        'SPN-OFFICIAL-PARTNER-STATUS' => 'Gold', 'SPN-PROMO-GIVEAWAY' => 'Gold',
        'SPN-SNS-CONTENT' => 'Gold',
        'SPN-BOARD-DUGOUT' => 'Platinum', 'SPN-BROADCAST-BANNER' => 'Platinum',
        'SPN-HELMET-LOGO' => 'Platinum', 'SPN-LED-OUTFIELD' => 'Platinum',
        'SPN-UNIFORM-SLEEVE' => 'Platinum',
        'SPN-BRANDDAY-SOLO' => 'Diamond', 'SPN-CATEGORY-EXCLUSIVE' => 'Diamond',
        'SPN-COLLAB-GOODS' => 'Diamond', 'SPN-LED-BACKNET' => 'Diamond',
        'SPN-LED-BRANDDAY' => 'Diamond', 'SPN-MARQUEE-TITLE' => 'Diamond',
        'SPN-NAMING-ZONE' => 'Diamond', 'SPN-UNIFORM-MAIN' => 'Diamond'
    };

    @AuraEnabled(cacheable=true)
    public static UpsellData getUpsellData(Id recordId) {
        // The component can live on an Account page or on an AccountPlan
        // ("파트너십 플랜") page — resolve to the underlying Account either way.
        Id accountId = recordId;
        if (recordId.getSObjectType() == AccountPlan.SObjectType) {
            accountId = [SELECT AccountId FROM AccountPlan WHERE Id = :recordId].AccountId;
        }

        UpsellData data = new UpsellData();

        Account acc = [
            SELECT Id, Name, Sponsor_Tier__c, Total_Sponsorship_Value__c,
                   Operating_Profit__c, Total_Assets__c, Market_Type__c
            FROM Account WHERE Id = :accountId
        ];
        data.accountName = acc.Name;
        data.currentTier = String.isBlank(acc.Sponsor_Tier__c) || acc.Sponsor_Tier__c == 'None'
            ? null : acc.Sponsor_Tier__c;
        data.totalValue = acc.Total_Sponsorship_Value__c;
        data.operatingProfit = acc.Operating_Profit__c;
        data.totalAssets = acc.Total_Assets__c;
        data.marketType = acc.Market_Type__c;

        // ---- Contract history (Closed Won sponsorship deals, oldest first) ----
        List<HistoryPoint> hist = new List<HistoryPoint>();
        Decimal maxAmt = 0;
        for (Opportunity o : [
            SELECT Amount, CloseDate FROM Opportunity
            WHERE AccountId = :accountId AND StageName = 'Closed Won' AND Amount != null
            ORDER BY CloseDate ASC
        ]) {
            HistoryPoint hp = new HistoryPoint();
            hp.year = String.valueOf(o.CloseDate.year());
            hp.amount = o.Amount;
            hist.add(hp);
            if (o.Amount > maxAmt) maxAmt = o.Amount;
        }
        for (HistoryPoint hp : hist) {
            hp.pct = maxAmt > 0 ? (hp.amount / maxAmt * 100).setScale(0) : 0;
        }
        data.history = hist;
        data.contractYears = hist.size();
        if (hist.size() >= 2) {
            Decimal prev = hist[hist.size() - 2].amount;
            Decimal last = hist[hist.size() - 1].amount;
            if (prev != null && prev != 0) {
                data.yoyGrowth = ((last - prev) / prev * 100).setScale(1);
            }
        }

        // ---- Held rights (Installed assets) ----
        Set<String> held = new Set<String>();
        for (Asset a : [
            SELECT Product2.ProductCode FROM Asset
            WHERE AccountId = :accountId AND Product2.ProductCode != null
        ]) {
            held.add(a.Product2.ProductCode);
        }

        // ---- Target tier (next one up, or same if already Diamond / unknown) ----
        Integer curIdx = data.currentTier == null ? -1 : TIER_ORDER.indexOf(data.currentTier);
        String targetTier;
        if (curIdx < 0) {
            targetTier = 'Gold';           // no tier yet -> entry package
        } else if (curIdx >= TIER_ORDER.size() - 1) {
            targetTier = 'Diamond';        // already top -> deepen within Diamond
            data.isTopTier = true;
        } else {
            targetTier = TIER_ORDER[curIdx + 1];
        }
        data.targetTier = targetTier;
        if (data.currentTier != null && TIER_PRICE.containsKey(targetTier)
                && TIER_PRICE.containsKey(data.currentTier)) {
            data.priceDelta = TIER_PRICE.get(targetTier) - TIER_PRICE.get(data.currentTier);
        }

        // ---- Tier ladder for the visual ----
        List<TierStep> ladder = new List<TierStep>();
        for (Integer i = 0; i < TIER_ORDER.size(); i++) {
            String t = TIER_ORDER[i];
            TierStep step = new TierStep();
            step.name = t;
            step.price = TIER_PRICE.get(t);
            step.isCurrent = (t == data.currentTier);
            step.isTarget = (t == targetTier && !step.isCurrent);
            step.isAchieved = (curIdx >= 0 && i <= curIdx);
            ladder.add(step);
        }
        data.ladder = ladder;

        // ---- Product names for the incremental rights of the target tier ----
        Map<String, String> nameByCode = new Map<String, String>();
        for (Product2 p : [
            SELECT ProductCode, Name FROM Product2 WHERE ProductCode IN :RIGHT_TIER.keySet()
        ]) {
            nameByCode.put(p.ProductCode, p.Name);
        }

        // ---- Upsell rights: rights unlocked at the target tier, flagged by whether held ----
        List<RightItem> rights = new List<RightItem>();
        Integer gainCount = 0;
        for (String code : RIGHT_TIER.keySet()) {
            if (RIGHT_TIER.get(code) != targetTier) continue;
            RightItem ri = new RightItem();
            ri.code = code;
            ri.name = nameByCode.containsKey(code) ? nameByCode.get(code) : code;
            ri.held = held.contains(code);
            if (!ri.held) gainCount++;
            rights.add(ri);
        }
        rights.sort();
        data.upsellRights = rights;
        data.newRightCount = gainCount;

        return data;
    }

    // ---------- DTOs ----------
    public class UpsellData {
        @AuraEnabled public String accountName;
        @AuraEnabled public String currentTier;
        @AuraEnabled public String targetTier;
        @AuraEnabled public Boolean isTopTier = false;
        @AuraEnabled public Decimal totalValue;
        @AuraEnabled public Decimal priceDelta;
        @AuraEnabled public Integer contractYears = 0;
        @AuraEnabled public Decimal yoyGrowth;
        @AuraEnabled public Decimal operatingProfit;
        @AuraEnabled public Decimal totalAssets;
        @AuraEnabled public String marketType;
        @AuraEnabled public Integer newRightCount = 0;
        @AuraEnabled public List<HistoryPoint> history = new List<HistoryPoint>();
        @AuraEnabled public List<TierStep> ladder = new List<TierStep>();
        @AuraEnabled public List<RightItem> upsellRights = new List<RightItem>();
    }
    public class HistoryPoint {
        @AuraEnabled public String year;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Decimal pct;
    }
    public class TierStep {
        @AuraEnabled public String name;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Boolean isCurrent;
        @AuraEnabled public Boolean isTarget;
        @AuraEnabled public Boolean isAchieved;
    }
    public class RightItem implements Comparable {
        @AuraEnabled public String code;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean held;
        public Integer compareTo(Object other) {
            RightItem o = (RightItem) other;
            if (this.held == o.held) return this.name.compareTo(o.name);
            return this.held ? 1 : -1;   // not-held first
        }
    }
}