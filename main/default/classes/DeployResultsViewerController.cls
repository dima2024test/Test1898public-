public with sharing class DeployResultsViewerController {

    private static final String IS_BLUR_MODE_PARAM_NAME = 'isBlurMode';
    private static final String DEPLOY_RESULT_FAKE_DATA = '[{"status":"Succeeded","id":"XXXXXXXXXXXXXXXXXX","completedDate":"2022-12-13T21:48:21.000Z"},{"status":"Succeeded","id":"XXXXXXXXXXXXXXXXXX","completedDate":"2022-12-13T21:48:21.000Z"}]';

    public Boolean isBlurMode { get; set; }
    public String blurModeUrlParameter { get; set; }
    public Log__c log { get; set; }
    public String instanceUrl { get; set; }
    public Integer timeZoneOffset { get; set; }
    public String data { get; set; }

    public DeployResultsViewerController(ApexPages.StandardController stdController) {
        this.log = [
            SELECT Id, Deploy_Results__c, Organization_Id__c, Issue__c
            FROM Log__c
            WHERE Id = :stdController.getId()
        ];

        if (String.isNotBlank(log.Organization_Id__c)) instanceUrl = ConnectedOrgService.getConnectedOrgById(log.Organization_Id__c)?.Instance_Url__c;

        timeZoneOffset = AdminService.getUserTimezoneOffset();
        data = log.Deploy_Results__c;
        String isBlurModeParam = ApexPages.currentPage().getParameters().get(IS_BLUR_MODE_PARAM_NAME);
        if (String.isNotBlank(isBlurModeParam)) {
            isBlurMode = Boolean.valueOf(isBlurModeParam);
        } else {
            isBlurMode = !BlurModeService.isAvailableDebugView(this.log.Issue__c);
        }
        if (isBlurMode) {
            data = DEPLOY_RESULT_FAKE_DATA;
            blurModeUrlParameter = BlurModeService.getEncryptedUrlParameter();
        }
    }

}