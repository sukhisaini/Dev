public class APICalloutBatchJob implements Schedulable, Database.Batchable<SObject>, Database.Stateful {

	public void execute(SchedulableContext sc) {
		Database.executeBatch(new APICalloutBatchJob());
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'SELECT ParentId__c, Endpoint__c, MethodType__c, Body__c FROM AusPostHubMessage__c WHERE IsSuccess__c = FALSE';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<AusPostHubMessage__c> ausPostHubMessages) {
		try {
			List<Case> casesToUpdate = new List<Case>();
			for (AusPostHubMessage__c ausPostHubMessage : ausPostHubMessages) {
				ServicesWrapper serviceResult = callout(ausPostHubMessage.Endpoint__c, ausPostHubMessage.MethodType__c,
					ausPostHubMessage.Body__c);

				if (serviceResult.success) {
					casesToUpdate.add(new Case(Id = ausPostHubMessage.ParentId, SecretKey__c = serviceResult.secretKey));
					ausPostHubMessage.IsSuccess__c = true;
				} else {
					ausPostHubMessage.FailureReason__c = serviceResult.error;
					// Use the Custom logging mechanism developed at AusPost to log error
				}
			}

			updateCases(casesToUpdate);
			Database.update(ausPostHubMessages, false);
		} catch (Exception ex) {
			final String errorMessage = ex.getMessage() + '.\n\n' + ex.getLineNumber() + '.\n\n' + ex.getStackTraceString();
			// Use the Custom logging mechanism developed at AusPost to log above message
			// Send an email to developer group with above error message
		}
	}

	public void finish(Database.BatchableContext context) {
		try {
			GlobalUtility.sendDeveloperBatchReportEmail(context.getJobId());
		} catch (Exception ex) {
			Logger.log(LoggingLevel.ERROR, 'Error in CommenceMFRProcessBatchJob.finish: ' + ex.getMessage() + '.\n\n' +
				ex.getLineNumber() + '.\n\n' + ex.getStackTraceString());
		}
	}

	private void updateCases(List<Case> casesToUpdate) {
		List<Database.SaveResult> updateCases = Database.update(casesToUpdate, false);
		Database.Error error;
		List<String> errorTexts = new List<String>();
		for (Database.SaveResult updateCase : updateCases) {
			if (!updateCase.isSuccess()) {
				error = updateCase.getErrors()[0];
				// Use the Custom logging mechanism developed at AusPost to log response.getBody()
				errorTexts.add(updateCase.getId() + '\n' + error.getMessage());
			}
		}
		if (!errorTexts.isEmpty()) {
			// Send an email to developer group with content of errorTexts
		}
	}

	//TODO Move this method to a separate class
	private static ServicesWrapper callout(String serviceEndpoint, String methodType, String body) {
		HttpRequest request = new HttpRequest();
		request.setEndpoint(serviceEndpoint);
		request.setMethod(methodType);
		request.setBody(body);
		request.setHeader('Content-Type', 'application/json');
		request.setTimeout(120000);
		HttpResponse response = new Http().send(request);
		ServicesWrapper serviceResult = (ServicesWrapper) JSON.deserialize(response.getBody(), ServicesWrapper.class);
		return serviceResult;
	}

	//TODO move this to a separate class
	public class ServicesWrapper {
		public Boolean success;
		public String secretKey;
		public String error;
	}
}