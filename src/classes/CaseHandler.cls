public without sharing class CaseHandler extends TriggerHandler {
	private String userId;
	public CaseHandler() {
		super(Trigger.new, Trigger.oldMap);
		userId = UserInfo.getUserId();
	}

	public override void afterUpdate() {
		processCaseClosure();
	}

	private void processCaseClosure() {
		List<AusPostHubMessage__c> ausPostHubMessages = new List<AusPostHubMessage__c>();
		Case oldCase;
		for (Case newCase : (List<Case>) newRecords) {
			oldCase = (Case) oldRecordsMap.get(newCase.Id);
			if (oldCase.IsClosed != newCase.IsClosed && newCase.IsClosed) {
				ausPostHubMessages.add(createAusPostHubMessage(newCase.Id));
			}
		}
		insert ausPostHubMessages;
	}

	private AusPostHubMessage__c createAusPostHubMessage(String caseId) {
		return new AusPostHubMessage__c(
			ParentId__c = caseId,
			Endpoint__c = 'endpointGoesHere',
			MethodType__c = 'POST',
			Body__c = getJSONBody(caseId),
			IsSuccess__c = false,
			FailureReason__c = '');
	}

	private String getJSONBody(String caseId) {
		return '{"id" : "' + caseId + '", "agentid" : "' + userId + '"}';
	}
}
