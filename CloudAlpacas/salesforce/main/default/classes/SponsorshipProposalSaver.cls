public with sharing class SponsorshipProposalSaver {

    public class SponsorshipProposalSaverException extends Exception {}

    @InvocableMethod(
        label='Save Sponsorship Proposal'
        description='Creates a Quote and QuoteLineItem for the selected Sponsorship Package on this Opportunity, and updates Opportunity benefit / target segment fields when provided.'
    )
    public static List<Result> execute(List<Request> requests) {
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true WITH USER_MODE LIMIT 1];

        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result r = new Result();

            List<PricebookEntry> entries = [
                SELECT Id, UnitPrice
                FROM PricebookEntry
                WHERE Product2Id = :req.productId
                  AND Pricebook2Id = :standardPricebook.Id
                  AND IsActive = true
                WITH USER_MODE
                LIMIT 1
            ];
            if (entries.isEmpty()) {
                throw new SponsorshipProposalSaverException(
                    'No active Standard Price Book entry found for product ' + req.productId
                );
            }
            PricebookEntry entry = entries[0];

            Quote newQuote = new Quote(
                Name = req.quoteName,
                OpportunityId = req.opportunityId,
                Pricebook2Id = standardPricebook.Id
            );
            insert as user newQuote;

            QuoteLineItem qli = new QuoteLineItem(
                QuoteId = newQuote.Id,
                PricebookEntryId = entry.Id,
                Quantity = 1,
                UnitPrice = entry.UnitPrice
            );
            insert as user qli;

            Boolean hasBenefitUpdate = String.isNotBlank(req.shortTermBenefit)
                || String.isNotBlank(req.midTermBenefit)
                || String.isNotBlank(req.longTermBenefit)
                || String.isNotBlank(req.targetSegment);
            if (hasBenefitUpdate) {
                Opportunity opp = new Opportunity(Id = req.opportunityId);
                if (String.isNotBlank(req.shortTermBenefit)) {
                    opp.Expected_Benefit_Short_Term__c = req.shortTermBenefit;
                }
                if (String.isNotBlank(req.midTermBenefit)) {
                    opp.Expected_Benefit_Mid_Term__c = req.midTermBenefit;
                }
                if (String.isNotBlank(req.longTermBenefit)) {
                    opp.Expected_Benefit_Long_Term__c = req.longTermBenefit;
                }
                if (String.isNotBlank(req.targetSegment)) {
                    opp.Target_Segment__c = req.targetSegment;
                }
                update as user opp;
            }

            r.quoteId = newQuote.Id;
            r.quoteName = newQuote.Name;
            r.success = true;
            results.add(r);
        }

        return results;
    }

    public class Request {
        @InvocableVariable(
            label='Opportunity Id'
            description='Opportunity to attach the Quote to.'
            required=true
        )
        public Id opportunityId;

        @InvocableVariable(
            label='Product Id'
            description='Selected Sponsorship Package Product2 Id.'
            required=true
        )
        public Id productId;

        @InvocableVariable(
            label='Quote Name'
            description='Name for the new Quote.'
            required=true
        )
        public String quoteName;

        @InvocableVariable(
            label='Short-Term Benefit'
            description='Opportunity.Expected_Benefit_Short_Term__c value to write, if provided.'
            required=false
        )
        public String shortTermBenefit;

        @InvocableVariable(
            label='Mid-Term Benefit'
            description='Opportunity.Expected_Benefit_Mid_Term__c value to write, if provided.'
            required=false
        )
        public String midTermBenefit;

        @InvocableVariable(
            label='Long-Term Benefit'
            description='Opportunity.Expected_Benefit_Long_Term__c value to write, if provided.'
            required=false
        )
        public String longTermBenefit;

        @InvocableVariable(
            label='Target Segment'
            description='Opportunity.Target_Segment__c value to write, if provided.'
            required=false
        )
        public String targetSegment;
    }

    public class Result {
        @InvocableVariable(label='Quote Id' description='Id of the created Quote.')
        public Id quoteId;

        @InvocableVariable(label='Quote Name' description='Name of the created Quote.')
        public String quoteName;

        @InvocableVariable(label='Success' description='Whether the save completed successfully.')
        public Boolean success;
    }
}
