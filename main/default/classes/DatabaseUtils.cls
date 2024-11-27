public with sharing class DatabaseUtils {

	public static Decimal percentAsyncApexJobsFreeOnOrg = 0.85; // 15%

	public List<SObject> sObjects;

	public List<Database.SaveResult> saveResults;
	public List<Database.UpsertResult> upsertResults;
	public List<Database.DeleteResult> deleteResults;

	public static DatabaseUtils getInstance() {
		return new DatabaseUtils();
	}

	public List<SObject> getSuccessSObjects() {
		List<SObject> successSObjects = new List<SObject>();
		if (sObjects != null && !sObjects.isEmpty()) {
			if (saveResults != null) {
				for (Database.SaveResult saveResult : saveResults) {
					if (saveResult.isSuccess()) {
						for (SObject sObjectRecord : sObjects) {
							if (saveResult.getId() == sObjectRecord.Id) {
								successSObjects.add(sObjectRecord);
								break;
							}
						}
					}
				}
			}
			if (upsertResults != null) {
				for (Database.UpsertResult upsertResult : upsertResults) {
					if (upsertResult.isSuccess()) {
						for (SObject sObjectRecord : sObjects) {
							if (upsertResult.getId() == sObjectRecord.Id) {
								successSObjects.add(sObjectRecord);
								break;
							}
						}
					}
				}
			}
			if (deleteResults != null) {
				for (Database.DeleteResult deleteResult : deleteResults) {
					if (deleteResult.isSuccess()) {
						for (SObject sObjectRecord : sObjects) {
							if (deleteResult.getId() == sObjectRecord.Id) {
								successSObjects.add(sObjectRecord);
								break;
							}
						}
					}
				}
			}
		}
		return successSObjects;
	}

	public DatabaseUtils handleError(String area, String apexName) {
		handleError(area, apexName, Logger.getInstance());
		return this;
	}

	public DatabaseUtils handleError(String area, String apexName, Logger logger) {
		if (saveResults != null) logger?.addInternalErrors(saveResults, area, apexName);
		if (upsertResults != null) logger?.addInternalErrors(upsertResults, area, apexName);
		if (deleteResults != null) logger?.addInternalErrors(deleteResults, area, apexName);
		return this;
	}

	public DatabaseUtils performInsertDML(List<SObject> sObjectList, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			Schema.DescribeSObjectResult dsr = sObjectList.get(0).getSObjectType().getDescribe();
			performInsertDML(sObjectList, dsr, allOrNone);
		}
		return this;
	}

	public DatabaseUtils performInsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performInsertDML(sObjectList, dsr, false);
	}

	public DatabaseUtils performInsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone) {
		return performInsertDML(sObjectList, dsr, allOrNone, false);
	}

	public DatabaseUtils performInsertImmediateDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performInsertDML(sObjectList, dsr, null, true);
	}

	public DatabaseUtils performInsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone, Boolean immediate) {
		if (!sObjectList.isEmpty()) {
			sObjects = sObjectList;
			if (PermissionsUtil.isInsertable(dsr)) {
				saveResults = immediate ? Database.insertImmediate(sObjectList) : Database.insert(sObjectList, allOrNone);
			}
		}
		return this;
	}

	public DatabaseUtils performUpsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performUpsertDML(sObjectList, dsr, false);
	}

	public DatabaseUtils performUpsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone) {
		return performUpsertDML(sObjectList, dsr, null, allOrNone);
	}

	public DatabaseUtils performUpsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, SObjectField field) {
		return performUpsertDML(sObjectList, dsr, field, false);
	}

	public DatabaseUtils performUpsertDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, SObjectField field, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			sObjects = sObjectList;
			if (PermissionsUtil.isUpsertable(dsr)) {
				upsertResults = field == null ? Database.upsert(sObjectList, allOrNone) : Database.upsert(sObjectList, field, allOrNone);
			}
		}
		return this;
	}

	public DatabaseUtils filterUpsertResultsDuplicateValue(String byField) {
		return filterUpsertResults(byField, System.StatusCode.DUPLICATE_VALUE);
	}

	public DatabaseUtils filterUpsertResultsRowLock() {
		return filterUpsertResults(null, System.StatusCode.UNABLE_TO_LOCK_ROW);
	}

	public DatabaseUtils filterUpsertResults(String message, System.StatusCode statusCode) {
		if(this.upsertResults != null && !this.upsertResults.isEmpty()) {
			for(Integer i = 0; i < this.upsertResults.size(); i++) {
				Database.UpsertResult upsertResult = this.upsertResults.get(i);
				if (!upsertResult.isSuccess()) {
					for (Database.Error error : upsertResult.getErrors()) {
						if(error?.getStatusCode() == statusCode 
							&& (String.isBlank(message) 
							|| (String.isNotBlank(message) && error?.getMessage()?.containsIgnoreCase(message)))) {
							
							this.upsertResults.remove(i);
							break;
						}
					}
				}
			}
		}
		return this;
	}

	public DatabaseUtils performUpdateDML(List<SObject> sObjectList) {
		return performUpdateDML(sObjectList, false);
	}

	public DatabaseUtils performUpdateDML(List<SObject> sObjectList, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			Schema.DescribeSObjectResult dsr = sObjectList.get(0).getSObjectType().getDescribe();
			performUpdateDML(sObjectList, dsr, allOrNone);
		}
		return this;
	}

	public DatabaseUtils performUpdateDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performUpdateDML(sObjectList, dsr, false);
	}

	public DatabaseUtils performUpdateDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			sObjects = sObjectList;
			if (PermissionsUtil.isUpdateable(dsr)) {
				saveResults = Database.update(sObjectList, allOrNone);
			}
		}
		return this;
	}

	public DatabaseUtils performDeleteDML(List<SObject> sObjectList) {
		return performDeleteDML(sObjectList, false);
	}

	public DatabaseUtils performDeleteDML(List<SObject> sObjectList, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			Schema.DescribeSObjectResult dsr = sObjectList.get(0).getSObjectType().getDescribe();
			performDeleteDML(sObjectList, dsr, allOrNone);
		}
		return this;
	}

	public DatabaseUtils performDeleteDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr) {
		return performDeleteDML(sObjectList, dsr, false);
	}

	public DatabaseUtils performDeleteDML(List<SObject> sObjectList, Schema.DescribeSObjectResult dsr, Boolean allOrNone) {
		if (!sObjectList.isEmpty()) {
			sObjects = sObjectList;
			if (PermissionsUtil.isDeletable(dsr)) {
				deleteResults = Database.delete(sObjectList, allOrNone);
			}
		}
		return this;
	}

	public DatabaseUtils performDeleteDML(List<Id> listIds, Schema.DescribeSObjectResult dsr) {
		if (!listIds.isEmpty()) {
			if (PermissionsUtil.isDeletable(dsr)) {
				deleteResults = Database.delete(listIds, false);
			}
		}
		return this;
	}

	public static void publishLogEvent(List<Log__c> logs) {
		Log_Event__e logEvent = (Log_Event__e)PermissionsUtil.newSObject(Schema.SObjectType.Log_Event__e);
		PermissionsUtil.putSObjectField(logEvent, Schema.SObjectType.Log_Event__e.fields.Body__c, JSON.serialize(logs));
		EventBus.publish(
				logEvent
		);
	}

	public interface PharosBatchInterface {
		void startBatch();
		Boolean initialValidation();
		Integer getIterationsCount();
	}

	public virtual class PharosBatchImpl implements PharosBatchInterface {
		public Logger loggerInstance;
		public Integer BATCH_SCOPE = 1;
		public Boolean isForceStart = false;
		public LogServiceScheduler schedulerInstance;
		public PharosBatchImpl() {}
		public PharosBatchImpl(Logger logger) {
			this.loggerInstance = logger;
		}
		public virtual void startBatch() {}
		public virtual void forceStartBatch() {
			this.isForceStart = true;
			startBatch();
		}
		public virtual Boolean initialValidation() {
			return true;
		}
		public virtual Integer getIterationsCount() {
			return 0;
		}
		public virtual void finishBatch() {
			if (schedulerInstance != null) {
				schedulerInstance.serviceSchedulerDispatcher();
			}
		}
		public virtual Boolean isExecutionTime(String jobName) {
			Boolean result = true;
			Integer recurring = getRecurring(jobName, LogServiceScheduler.FREQUENCY_HOURS);
			if (recurring == null) recurring = getRecurring(jobName, LogServiceScheduler.FREQUENCY_HOURS_DEFAULT);
			if (recurring != null) {
				Datetime systemTime = System.now();
				switch on recurring {
					when 0 {
						result = false;
					}
					when 168 {
						if (!systemTime.format('EEE').equalsIgnoreCase('SUN') || systemTime.hour() != 0) result = false;
					}
					when else {
						result = systemTime.hour() / recurring * recurring == systemTime.hour();
					}
				}
			}
			return result;
		}
		public virtual void setSchedulerInstance(LogServiceScheduler schedulerInstance) {
			this.schedulerInstance = schedulerInstance;
		}
		private Integer getRecurring(String jobName, Map<String, String> FREQUENCY_HOURS) {
			Integer frequency;
			if (FREQUENCY_HOURS.containsKey(jobName) && String.isNotBlank(FREQUENCY_HOURS.get(jobName))) {
				try {
					frequency = Integer.valueOf(FREQUENCY_HOURS.get(jobName));
				} catch (Exception e) {}
			}
			return frequency;
		}
	}

    public static List<AsyncApexJob> getCurrentJobs(List<String> apexClassNames) {
        return [
            SELECT Id
            FROM AsyncApexJob
            WHERE Status IN :ConfigUtil.ASYNC_APEX_JOB_PROCESS_STATUS
            AND JobType NOT IN :ConfigUtil.ASYNC_APEX_JOB_PROCESS_TYPES
            AND ApexClass.Name IN :apexClassNames
            LIMIT 1
        ];
    }

    public static Integer getSumTotalJobItems() {
        return Integer.valueOf([
            SELECT SUM(TotalJobItems) sumTotalJobItems
            FROM AsyncApexJob
            WHERE JobType = 'BatchApex'
            AND Status IN :ConfigUtil.ASYNC_APEX_JOB_PROCESS_STATUS
        ][0].get('sumTotalJobItems'));
    }

	public static Boolean executeBatchWithLimitCheck(String jobName, Object batchInstance) {
		return executeBatchWithLimitCheck(new List<String>{jobName}, batchInstance);
	}

	public static Boolean executeBatchWithLimitCheck(List<String> jobNames, Object batchInstance) {
		if (jobNames == null || jobNames.isEmpty()) return false;

		PharosBatchImpl pharosBatch = (PharosBatchImpl)batchInstance;

		if (!pharosBatch.isForceStart && !pharosBatch.isExecutionTime(jobNames[0])) return false;
		if (!pharosBatch.initialValidation()) return false;

		// check duplicate jobs
		if (!getCurrentJobs(jobNames).isEmpty()) return false;

		// check AsyncApexExecutions limits
		Integer sumTotalJobItems = getSumTotalJobItems();
		Integer availableQuantityAsyncApexExecutionsOnOrg = Integer.valueOf(LimitsService.getAvailableQuantityAsyncApexExecutions() * percentAsyncApexJobsFreeOnOrg);
		Integer availableQuantityAsyncApexExecutions = availableQuantityAsyncApexExecutionsOnOrg - (sumTotalJobItems != null ? sumTotalJobItems : 0);

		Integer batchIterations = Integer.valueOf(Math.ceil(pharosBatch.getIterationsCount() / Decimal.valueOf(pharosBatch.BATCH_SCOPE)));
		// "-2" - Decreasing count by 2 to reserve slots for batch start and finish in async apex executions.
		Decimal neededAsyncApexExecutionsRuns = (availableQuantityAsyncApexExecutions - batchIterations - 2);

		if (batchIterations <= 0 || neededAsyncApexExecutionsRuns <= 0) return false;

		// check You've exceeded the limit of 100 jobs in the flex queue
		if (!LimitsService.isFlexQueueSlotAvailable()) return false;

		try {
			Database.executeBatch((Database.Batchable<PharosBatchInterface>)pharosBatch, pharosBatch.BATCH_SCOPE);
			return true;
		}
		catch(Exception e) {
			String className = String.valueOf(batchInstance).split(':')[0];
			Logger.getInstance().internalError(e, null, true, className, className);
			return false;
		}
	}

}