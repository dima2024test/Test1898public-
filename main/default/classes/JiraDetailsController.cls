public with sharing class JiraDetailsController {

    public string jiraTaskUrl { get; set; }
    public string jiraTask { get; set; }
    public Log__c log { get; set; }

    public Boolean isAzure { get; set; }
    public string workItem { get; set; }
    public string workItemComments { get; set; }

    public JiraDetailsController(ApexPages.StandardController stdController) {
        SObjectType sObjectType = stdController.getRecord().getSObjectType();
        if(sObjectType == Log__c.sObjectType){
            this.log = [
                SELECT Id, Bug_Tracker__c, Hash_1__c
                FROM Log__c
                WHERE Id = :stdController.getId()
            ];
            this.jiraTaskUrl = this.log.Bug_Tracker__c;
        }
        else if(sObjectType == Issue__c.sObjectType){
            Issue__c issue  = [
                SELECT Id, Bug_Tracker__c
                FROM Issue__c
                WHERE Id = :stdController.getId()
            ];
            this.jiraTaskUrl = issue.Bug_Tracker__c;
        }

    }

    public void init() {
        try {
            if (this.jiraTaskUrl.contains('azure')) {
                this.isAzure = true;
                
                AzureService.WorkItemUrlParser urlWorkItem = new AzureService.WorkItemUrlParser(this.jiraTaskUrl);
                String workItemId = urlWorkItem.workItemId;
                String projectId = urlWorkItem.projectIdOrName;
                String organizationId = urlWorkItem.organizationName;
                
                AzureService.AzureDevOpsWorkItem workItem = AzureService.getProjectWorkItem(organizationId, projectId, workItemId);
                workItem.organizationName = urlWorkItem.organizationName;
                AzureService.AzureDevOpsWorkItemCommentsWrap comments = AzureService.getProjectWorkItemComments(organizationId, projectId, workItemId);
                
                this.workItem = JSON.serialize(workItem);
                this.workItemComments = JSON.serialize(comments);
            } else {
                String taskKey = JiraService.getIssueKeyByUrl(this.jiraTaskUrl);
                this.jiraTask = JiraService.getService().getJiraIssueByKeyRaw(taskKey, null);
            }
        } catch(Exception e) {
            this.jiraTask = e.getMessage();
        }
    }

}