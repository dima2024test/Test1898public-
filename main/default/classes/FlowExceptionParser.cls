global with sharing virtual class FlowExceptionParser implements IErrorParser {

    public static final String FLOW_EXCEPTION = 'FlowException';
    public static final String FLOW_CATEGORY = 'Flow';
    public static final String PROCESS_BUILDER_CATEGORY = 'Process Builder';
    public static final String PROCESS_BUILDER_EXCEPTION = 'ProcessBuilderException';
    public static final String PARSER_AREA_FLOW = 'Flow';
    public static final String PARSER_AREA_PROCESS_BUILDER = 'Process Builder';
    public static final String PARSER_TOKEN = 'Flow Details';
    public static final String PARSER_SYSTEM_PREFIX = 'System.';
    public static final String PARSER_SUMMARY_UNDEFINED = 'Undefined';

    public static final String PB_TYPE_RECORD_CHANGE_PROCESS = 'Record Change Process';
    public static final String PB_TYPE_PLATFORM_EVENT_PROCESS = 'Platform Event Process';
    public static final String PB_TYPE_INVOCABLE_PROCESS = 'Invocable Process';
    public static final String UNDEFINED_TYPE = 'Undefined';
    public static final String HANDLED_ERROR_TOKEN = 'Error Handled';

    // GLOBAL

    global FlowExceptionParser() {}

    global virtual void init(String errorBody, String emailSubject, String emailSentFrom) {
        this.originalMessage = (String.isNotBlank(errorBody)) ? errorBody.stripHtmlTags() : errorBody;
        this.stacktrace = errorBody;
        this.emailSubject = emailSubject;
    }

    global virtual Boolean canProcess() {
        String msg = getError();
        return !String.isBlank(msg) && msg.containsIgnoreCase(PARSER_TOKEN);
    }

    global virtual void process() {
        parseErrorMessage();
    }

    global virtual String getError() {
        return this.originalMessage;
    }

    global virtual String getErrorSummary() {
        return this.summary;
    }

    public static String getValueForHash(String inputValue) {
        if(String.isNotBlank(inputValue)) {
            // remove flow guid
            inputValue = inputValue.replaceAll(LogService.REGEX_FLOW_GUID_PATTERN, '');
            // remove times
            inputValue = inputValue.replaceAll(LogService.REGEX_TIME_PATTERN, '');
            // remove all IDs (pseudo Ids)
            inputValue = inputValue.replaceAll(LogService.REGEX_ID_PATTERN, '');
            // remove all Non-alphanum characters and whitespaces
            inputValue = inputValue.replaceAll(LogService.REGEX_NON_ALPHANUMERIC_PATTERN, '');
            // remove all numbers
            inputValue = inputValue.replaceAll(LogService.REGEX_ALL_NUMBERS_PATTERN, '');
            // remove current user
            inputValue = inputValue.replaceAll(LogService.REGEX_FLOW_CURRENT_USER, '');
            // remove running user
            inputValue = inputValue.replaceAll(LogService.REGEX_FLOW_RUNNING_USER, '');
        }
        return inputValue;
    }

    global virtual String getErrorDetails() {
        return this.originalMessage;
    }

    global virtual String getVisualforcePage() {
        return this.visualforcePage;
    }

    global virtual String getRelatedId() {
        return this.relatedId;
    }

    global virtual String getRelatedObjectType() {
        return this.relatedObjectType;
    }

    global virtual String getAsyncJobName() {
        return this.asyncJobName;
    }

    global virtual String getAsyncJobId() {
        return this.asyncJobId;
    }

    global virtual String getErrorType() {
        return this.errorType;
    }

    global virtual String getArea() {
        return this.area;
    }

    global virtual String getUserId() {
        return this.userId;
    }

    global virtual String getOrganizationId() {
        return this.organizationId;
    }

    global virtual String getStackTrace() {
        return this.stacktrace;
    }

    global virtual String parseStackTrace() {
        return null;
    }

    global virtual String getMethodName() {
        return null;
    }

    global virtual String getHash1() {
        String value = getFlowApiName() + getFlowVersion() + getValueForHash(LogService.removeExtraErrorDetails(getErrorSummary()) + getFlowErrorElement());
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));
        return hash;
    }

    global virtual String getHash2() {
        String value = getFlowVersion() + getFlowApiName() + getValueForHash(LogService.removeExtraErrorDetails(getErrorSummary()));
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));
        return hash;
    }

    global virtual String getHash3() {
        String value = getFlowApiName() + getValueForHash(LogService.removeExtraErrorDetails(getErrorSummary()));
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(value)));
        return hash;
    }

    global virtual String getPendingJobsInfo() {
        return null;
    }

    global virtual Decimal getTotalActiveSessions() {
        return null;
    }

    global virtual String getAuditTrail() {
        return null;
    }

    global virtual String getInstalledPackagesInfo() {
        return null;
    }

    global virtual String getNamespace() {
        return null;
    }

    global virtual String getDeploymentsInfo() {
        return null;
    }

    global virtual String getSalesforceErrorId() {
        return this.salesforceErrorId;
    }

    global virtual String getFlowVersion() {
        return this.flowVersion;
    }

    private String getCategory() {
        return this.category;
    }

    private String getFlowApiName() {
        return this.flowApiName;
    }

    private String getRelatedObjects() {
        return this.relatedObjects;
    }

    private String getInterviewGUID() {
        return this.interviewGUID;
    }

    private String getDuration() {
        return this.duration;
    }

    private String getFlowErrorElement() {
        return this.flowErrorElement;
    }

    global virtual List<ICustomErrorInfo> getCustomInfo() {
        List<ICustomErrorInfo> customFields = new List<ICustomErrorInfo>{
            new CategoryField(this.getCategory()),
            new FlowApiNameField(this.getFlowApiName()),
            new FlowHandledErrorField(String.valueOf(this.isHandledFlowError)),
            new RelatedObjectsField(this.getRelatedObjects()),
            new InterviewGUIDField(this.getInterviewGUID()),
            new DurationField(this.getDuration())
        };
        return customFields;
    }

    public static final String FLOW_HANDLED_ERROR_FIELD = 'FlowHandledErrorField';
    public class FlowHandledErrorField implements  ICustomErrorInfo {
        public String flowHandledErrorField;
        public FlowHandledErrorField(String value) {
            this.flowHandledErrorField = value;
        }
        public String getValue() {
            return this.flowHandledErrorField;
        }
        public String getLogFieldName() {
            return FLOW_HANDLED_ERROR_FIELD;
        }
    }

    public class FlowApiNameField implements  ICustomErrorInfo {
        public String flowAPIName;
        public FlowApiNameField(String value) {
            this.flowAPIName = value;
        }
        public String getValue() {
            return this.flowAPIName;
        }
        public String getLogFieldName() {
            return Schema.sObjectType.Log__c.fields.Flow_API_Name__c.getName();
        }
    }

    public class CategoryField implements ICustomErrorInfo {
        public String category;
        public CategoryField(String value) {
            this.category = value;
        }
        public String getValue() {
            return this.category;
        }
        public String getLogFieldName() {
            return Schema.sObjectType.Log__c.fields.Category__c.getName();
        }
    }

    public class RelatedObjectsField implements ICustomErrorInfo {
        public String relatedObjects;
        public RelatedObjectsField(String value) {
            this.relatedObjects = value;
        }
        public String getValue() {
            return this.relatedObjects;
        }
        public String getLogFieldName() {
            return Schema.SObjectType.Log__c.fields.Related_Objects__c.getName();
        }
    }

    public class InterviewGUIDField implements ICustomErrorInfo {
        public String interviewGUID;
        public InterviewGUIDField(String value) {
            this.interviewGUID = value;
        }
        public String getValue() {
            return this.interviewGUID;
        }
        public String getLogFieldName() {
            return Schema.SObjectType.Log__c.fields.Interview_GUID_External__c.getName();
        }
    }

    public class DurationField implements ICustomErrorInfo {
        public String duration;
        public DurationField(String value) {
            this.duration = value.replace(' seconds', '');
        }
        public String getValue() {
            return this.duration;
        }
        public String getLogFieldName() {
            return Schema.SObjectType.Log__c.fields.Duration__c.getName();
        }
    }

    global virtual List<Queueable> getAsyncMethods(Id logId) {
        List<Queueable> asyncMethods = new List<Queueable>();
        return asyncMethods;
    }

    global class FlowExceptionParserException extends Exception {}

    // PRIVATE
    public String originalMessage = null;
    public String emailSubject;
    private String summary;
    private String visualforcePage;
    private String relatedId;
    private String relatedObjectType;
    private String relatedObjects;
    private String area;
    private String userId;
    private String organizationId;
    private String asyncJobName;
    private String asyncJobId;
    private String stacktrace;
    private String errorType;
    private String apexName;
    private String flowVersion;
    private String salesforceErrorId;
    private String flowApiName;
    private String flowErrorElement;
    private String category;
    private String interviewGUID;
    private String duration;
    private Boolean isHandledFlowError = false;

    private void parseErrorMessage() {

        FlowService.FlowStacktraceParser parser = new FlowService.FlowStacktraceParser(getStackTrace());
        FlowService.FlowStacktraceInfo stackTraceInfo = parser.parse();
        
        this.area = PARSER_AREA_FLOW;
        this.category = FLOW_CATEGORY;

        String flowType = stackTraceInfo?.flowDetails?.type;
        if(String.isNotBlank(flowType) &&
            (flowType.containsIgnoreCase(PB_TYPE_RECORD_CHANGE_PROCESS)
                || flowType.containsIgnoreCase(PB_TYPE_PLATFORM_EVENT_PROCESS)
                || flowType.containsIgnoreCase(PB_TYPE_INVOCABLE_PROCESS))) {
            this.category = PROCESS_BUILDER_CATEGORY;
            this.area = PARSER_AREA_PROCESS_BUILDER;
        }

        if(String.isNotBlank(flowType)) {
            this.errorType = flowType;
        }
        if(String.isBlank(this.errorType)) {
            this.errorType = UNDEFINED_TYPE;
        }

        String summaryValue = stackTraceInfo?.errorMessage;
        this.summary = (String.isNotBlank(summaryValue)) ? summaryValue.abbreviate(ConfigUtil.MAX_LENGTH_TEXT_FIELD) : this.emailSubject;
        if(this.emailSubject.startsWith(FlowService.FLOW_ERROR_MESSAGE_SEPARATOR)) {
            this.summary = this.emailSubject?.removeStart(FlowService.FLOW_ERROR_MESSAGE_SEPARATOR)?.abbreviate(ConfigUtil.MAX_LENGTH_TEXT_FIELD);
        }
        this.userId = stackTraceInfo?.flowInterviewDetails?.currentUserId;
        this.interviewGUID = stackTraceInfo?.flowInterviewDetails?.interviewGUID;
        this.duration = stackTraceInfo?.flowInterviewDetails?.duration;
        this.organizationId = stackTraceInfo?.flowDetails?.orgId;
        this.salesforceErrorId = stackTraceInfo?.salesforceErrorId;
        this.flowVersion = stackTraceInfo?.flowDetails?.version;
        this.flowApiName = stackTraceInfo?.flowDetails?.flowApiName;

        List<String> executionPathList = getFlowExecutionPathList();
        if(!executionPathList.isEmpty()) {
            Set<String> executionPathSet = new Set<String>();
            for(String pathElement : executionPathList) {
                executionPathSet.add(pathElement);
            }
            this.flowErrorElement = executionPathList.get(executionPathList.size() - 1);
            this.isHandledFlowError = stackTraceInfo?.isHandledError;
        }

        this.relatedId = stackTraceInfo?.howTheInterviewStarted?.recordId;
        this.relatedObjectType = stackTraceInfo?.howTheInterviewStarted?.recordName;

        ConfigUtil.HTMLStringRowIterator rIterator = new ConfigUtil.HTMLStringRowIterator(String.isNotBlank(stackTraceInfo?.errorMessage) ? stackTraceInfo?.errorMessage : this.emailSubject);
        Pattern p = ConfigUtil.SOBJECT_ID_PATTERN;
        Set<String> relatedIds = new Set<String>();

        String stacktraceRow;
        while(rIterator.hasNext()) {
            stacktraceRow = rIterator.next();
            Matcher pm = p.matcher(stacktraceRow);
            while (pm.find()) {
                relatedIds.add(pm.group(1));
            }
        }
        if (!relatedIds.isEmpty()) this.relatedObjects = JSON.serialize(relatedIds);
    }

    private List<String> getFlowExecutionPathList() {
        List<String> executionPathList = FlowService.getFlowExecutionPath(getStackTrace());
        return executionPathList;
    }
}