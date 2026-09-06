public with sharing class OpportunityProposalContext {

    @InvocableMethod(
        label='Get Opportunity Proposal Context'
        description='Returns Opportunity B2B fields and, if this Opportunity was converted from a Lead, that Lead\'s Segment Match / Recommendation Reason / Lead Score for use in Sponsorship Proposal drafting.'
    )
    public static List<Result> execute(List<Request> requests) {
        Set<Id> oppIds = new Set<Id>();
        for (Request req : requests) {
            if (req.opportunityId != null) {
                oppIds.add(req.opportunityId);
            }
        }

        Map<Id, Opportunity> oppsById = new Map<Id, Opportunity>();
        if (!oppIds.isEmpty()) {
            oppsById = new Map<Id, Opportunity>(
                [SELECT Id, Name, Target_Segment__c, Partner_Tier__c,
                        Expected_Benefit_Short_Term__c, Expected_Benefit_Mid_Term__c,
                        Expected_Benefit_Long_Term__c
                 FROM Opportunity
                 WHERE Id IN :oppIds
                 WITH USER_MODE]
            );
        }

        Map<Id, Lead> convertedLeadByOppId = new Map<Id, Lead>();
        if (!oppIds.isEmpty()) {
            for (Lead ld : [SELECT Id, ConvertedOpportunityId, Target_Segment__c,
                                    Segment_Match__c, Recommendation_Reason__c, Lead_Score__c
                             FROM Lead
                             WHERE ConvertedOpportunityId IN :oppIds
                             WITH USER_MODE]) {
                convertedLeadByOppId.put(ld.ConvertedOpportunityId, ld);
            }
        }

        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            Opportunity opp = oppsById.get(req.opportunityId);
            if (opp == null) {
                results.add(r);
                continue;
            }

            r.opportunityName = opp.Name;
            r.targetSegment = opp.Target_Segment__c;
            r.partnerTier = opp.Partner_Tier__c;
            r.existingShortTermBenefit = opp.Expected_Benefit_Short_Term__c;
            r.existingMidTermBenefit = opp.Expected_Benefit_Mid_Term__c;
            r.existingLongTermBenefit = opp.Expected_Benefit_Long_Term__c;

            Lead ld = convertedLeadByOppId.get(opp.Id);
            if (ld != null) {
                r.hasConvertedLead = true;
                r.leadTargetSegment = ld.Target_Segment__c;
                r.leadSegmentMatch = ld.Segment_Match__c;
                r.leadRecommendationReason = ld.Recommendation_Reason__c;
                r.leadScore = ld.Lead_Score__c;
            } else {
                r.hasConvertedLead = false;
            }

            results.add(r);
        }
        return results;
    }

    public class Request {
        @InvocableVariable(
            label='Opportunity Id'
            description='Id of the Opportunity to fetch B2B proposal context for.'
            required=true
        )
        public Id opportunityId;
    }

    public class Result {
        @InvocableVariable(label='Opportunity Name' description='Opportunity.Name')
        public String opportunityName;

        @InvocableVariable(label='Target Segment' description='Opportunity.Target_Segment__c')
        public String targetSegment;

        @InvocableVariable(label='Partner Tier' description='Opportunity.Partner_Tier__c')
        public String partnerTier;

        @InvocableVariable(label='Existing Short-Term Benefit' description='Opportunity.Expected_Benefit_Short_Term__c')
        public String existingShortTermBenefit;

        @InvocableVariable(label='Existing Mid-Term Benefit' description='Opportunity.Expected_Benefit_Mid_Term__c')
        public String existingMidTermBenefit;

        @InvocableVariable(label='Existing Long-Term Benefit' description='Opportunity.Expected_Benefit_Long_Term__c')
        public String existingLongTermBenefit;

        @InvocableVariable(label='Has Converted Lead' description='Whether a Lead was converted into this Opportunity.')
        public Boolean hasConvertedLead = false;

        @InvocableVariable(label='Lead Target Segment' description='Converted Lead.Target_Segment__c (picklist).')
        public String leadTargetSegment;

        @InvocableVariable(label='Lead Segment Match' description='Converted Lead.Segment_Match__c - Agentforce fan/company fit score.')
        public Decimal leadSegmentMatch;

        @InvocableVariable(label='Lead Recommendation Reason' description='Converted Lead.Recommendation_Reason__c.')
        public String leadRecommendationReason;

        @InvocableVariable(label='Lead Score' description='Converted Lead.Lead_Score__c - sales qualification score.')
        public Decimal leadScore;
    }
}
