@IsTest
private class CaseHandlerTest {

	@TestSetup static void setupData() {
		//create a user with a profile that should be creating case
		User runAsUser;
		System.runAs(runAsUser) {
			//Create case
			Case case;
		}
	}

	@IsTest
	static void caseClosureTest() {
		//Select SOQL to get user created in setupData
		User runAsUser;
		System.runAs(runAsUser) {
			Test.startTest();
			//Select SOQL to get case created in setupData
			Case case;
			update new Case(Id=case.Id, Status = 'Closed');
			Test.stopTest();

			//Select SOQL to get AusPostHubMessage__c records
			List<AusPostHubMessage__c> ausPostHubMessages;
			System.assertNotEquals(null, ausPostHubMessages, 'a record must be created in AusPostHubMessage__c object on case closure');
			System.assertEquals('1', ausPostHubMessages.size(), 'only one case should be created on case closure');
		}
	}
}
