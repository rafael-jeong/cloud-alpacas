public with sharing class RenewalSummaryRefresher {

    @InvocableMethod(
        label='Refresh Renewal Summary'
        description='Finds a Sponsorship Renewal campaign by sponsor/campaign name, forces its Performance_Summary__c to recalculate by re-saving it, then returns the fresh summary.'
    )
    public static List<Result> execute(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result r = new Result();
            String likePattern = '%' + (String.isBlank(req.searchTerm) ? '' : req.searchTerm) + '%';

            List<Campaign> matches = [
                SELECT Id, Name
                FROM Campaign
                WHERE RecordType.DeveloperName = 'Sponsorship_Renewal'
                  AND Name LIKE :likePattern
                WITH USER_MODE
                LIMIT 1
            ];

            if (matches.isEmpty()) {
                r.found = false;
                r.campaignName = '';
                r.performanceSummary = '';
                results.add(r);
                continue;
            }

            Campaign camp = matches[0];

            // Touch-update with no field changes: the DML statement itself is
            // enough to re-fire the Before-Save Flow that recalculates
            // Performance_Summary__c from sibling Collaboration campaigns.
            update as user new Campaign(Id = camp.Id);

            Campaign refreshed = [
                SELECT Name, Performance_Summary__c
                FROM Campaign
                WHERE Id = :camp.Id
                WITH USER_MODE
                LIMIT 1
            ];

            r.found = true;
            r.campaignName = refreshed.Name;
            r.performanceSummary = refreshed.Performance_Summary__c;

            results.add(r);
        }

        return results;
    }

    public class Request {
        @InvocableVariable(
            label='Search Term'
            description='Sponsor or campaign name to find the matching Sponsorship Renewal campaign.'
            required=true
        )
        public String searchTerm;
    }

    public class Result {
        @InvocableVariable(label='Campaign Name' description='Name of the matched renewal campaign.')
        public String campaignName;

        @InvocableVariable(label='Performance Summary' description='Freshly recalculated Performance_Summary__c text.')
        public String performanceSummary;

        @InvocableVariable(label='Found' description='Whether a matching renewal campaign was found.')
        public Boolean found;
    }
}
