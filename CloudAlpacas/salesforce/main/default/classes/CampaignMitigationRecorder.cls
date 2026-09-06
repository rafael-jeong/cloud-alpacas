public with sharing class CampaignMitigationRecorder {

    @InvocableMethod(
        label='Adopt Campaign Mitigation'
        description='Records an approved bottleneck mitigation plan on a Campaign Deliverable Notes field and optionally creates a follow-up Task.'
    )
    public static List<Result> execute(List<Request> requests) {
        List<Result> results = new List<Result>();

        Set<Id> deliverableIds = new Set<Id>();
        for (Request req : requests) {
            if (req.deliverableId != null) {
                deliverableIds.add((Id) req.deliverableId);
            }
        }

        Map<Id, Campaign_Deliverable__c> deliverablesById = new Map<Id, Campaign_Deliverable__c>();
        if (!deliverableIds.isEmpty()) {
            deliverablesById = new Map<Id, Campaign_Deliverable__c>(
                [SELECT Id, Name, Notes__c, Campaign__r.Name
                 FROM Campaign_Deliverable__c
                 WHERE Id IN :deliverableIds
                 WITH USER_MODE]
            );
        }

        List<Campaign_Deliverable__c> toUpdate = new List<Campaign_Deliverable__c>();
        List<Task> tasksToInsert = new List<Task>();
        List<Result> pendingResults = new List<Result>();

        for (Request req : requests) {
            Result r = new Result();
            Campaign_Deliverable__c cd = deliverablesById.get((Id) req.deliverableId);
            if (cd == null) {
                r.success = false;
                r.taskId = '';
                results.add(r);
                continue;
            }

            String stamp = '\n[AI 대책 기록 ' + Date.today().format() + '] ' + req.mitigationPlan;
            Campaign_Deliverable__c upd = new Campaign_Deliverable__c(
                Id = cd.Id,
                Notes__c = (cd.Notes__c == null ? '' : cd.Notes__c) + stamp
            );
            toUpdate.add(upd);

            Boolean makeTask = req.createFollowUpTask == null ? true : req.createFollowUpTask;
            if (makeTask) {
                Task t = new Task(
                    Subject = '지연 대책 후속조치: ' + cd.Name,
                    Description = req.mitigationPlan,
                    WhatId = cd.Id,
                    ActivityDate = Date.today().addDays(3)
                );
                tasksToInsert.add(t);
                r.taskIndex = tasksToInsert.size() - 1;
            } else {
                r.taskIndex = -1;
            }
            r.success = true;
            r.taskId = '';
            pendingResults.add(r);
            results.add(r);
        }

        if (!toUpdate.isEmpty()) {
            update as user toUpdate;
        }
        if (!tasksToInsert.isEmpty()) {
            insert as user tasksToInsert;
            for (Result r : pendingResults) {
                if (r.taskIndex != null && r.taskIndex >= 0) {
                    r.taskId = tasksToInsert[r.taskIndex].Id;
                }
            }
        }

        return results;
    }

    public class Request {
        @InvocableVariable(
            label='Deliverable Id'
            description='Id of the Campaign_Deliverable__c record the mitigation applies to.'
            required=true
        )
        public String deliverableId;

        @InvocableVariable(
            label='Mitigation Plan'
            description='The approved mitigation plan text, recorded on Notes and used as the follow-up Task description.'
            required=true
        )
        public String mitigationPlan;

        @InvocableVariable(
            label='Create Follow-Up Task'
            description='Whether to also create a follow-up Task. Defaults to true if not specified.'
            required=false
        )
        public Boolean createFollowUpTask;
    }

    public class Result {
        @InvocableVariable(label='Task Id' description='Id of the created follow-up Task, empty if none was created.')
        public String taskId;

        @InvocableVariable(label='Success' description='Whether the mitigation was recorded successfully.')
        public Boolean success;

        // Internal bookkeeping only - not exposed via @InvocableVariable, used to
        // map inserted Task Ids back to the correct Result after bulk insert.
        public transient Integer taskIndex;
    }
}
