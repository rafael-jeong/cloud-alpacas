public with sharing class CampaignBottleneckFinder {

    @InvocableMethod(
        label='Find Campaign Bottlenecks'
        description='Finds Campaign Deliverables that are Blocked, or overdue and not yet Completed, optionally filtered by sponsor/campaign name.'
    )
    public static List<Result> execute(List<Request> requests) {
        List<Result> results = new List<Result>();
        Date today = Date.today();

        for (Request req : requests) {
            Result r = new Result();
            String likePattern = '%' + (String.isBlank(req.searchTerm) ? '' : req.searchTerm) + '%';

            List<Campaign_Deliverable__c> found = [
                SELECT Id, Name, Campaign__r.Name, Status__c, Blocked_Reason__c, Notes__c, Due_Date__c
                FROM Campaign_Deliverable__c
                WHERE Campaign__r.Name LIKE :likePattern
                  AND (Status__c = 'Blocked' OR (Due_Date__c < :today AND Status__c != 'Completed'))
                WITH USER_MODE
                ORDER BY Due_Date__c ASC NULLS LAST
                LIMIT 200
            ];

            r.bottlenecks = new List<BottleneckItem>();
            for (Campaign_Deliverable__c cd : found) {
                BottleneckItem item = new BottleneckItem();
                item.deliverableId = cd.Id;
                item.campaignName = cd.Campaign__r.Name;
                item.deliverableName = cd.Name;
                item.status = cd.Status__c;
                item.blockedReason = cd.Blocked_Reason__c;
                item.notes = cd.Notes__c;
                item.dueDate = cd.Due_Date__c;
                item.isOverdue = cd.Due_Date__c != null && cd.Due_Date__c < today;
                r.bottlenecks.add(item);
            }
            r.totalCount = r.bottlenecks.size();
            results.add(r);
        }
        return results;
    }

    public class Request {
        @InvocableVariable(
            label='Search Term'
            description='Sponsor or campaign name to filter by. Leave blank to search all sponsorship campaigns.'
            required=false
        )
        public String searchTerm;
    }

    public class Result {
        @InvocableVariable(label='Bottlenecks' description='List of blocked or overdue-and-incomplete deliverables.')
        public List<BottleneckItem> bottlenecks;

        @InvocableVariable(label='Total Count' description='Number of bottlenecks found.')
        public Integer totalCount;
    }

    public class BottleneckItem {
        @InvocableVariable(label='Deliverable Id' description='Campaign_Deliverable__c record Id, used by adopt_mitigation.')
        public String deliverableId;

        @InvocableVariable(label='Campaign Name' description='Parent Campaign name.')
        public String campaignName;

        @InvocableVariable(label='Deliverable Name' description='Campaign_Deliverable__c auto-number Name.')
        public String deliverableName;

        @InvocableVariable(label='Status' description='Current Status__c value.')
        public String status;

        @InvocableVariable(label='Blocked Reason' description='Blocked_Reason__c value, if set.')
        public String blockedReason;

        @InvocableVariable(label='Notes' description='Notes__c free-text detail, if any.')
        public String notes;

        @InvocableVariable(label='Due Date' description='Due_Date__c value.')
        public Date dueDate;

        @InvocableVariable(label='Is Overdue' description='True if Due Date has passed and the item is not Completed.')
        public Boolean isOverdue;
    }
}
