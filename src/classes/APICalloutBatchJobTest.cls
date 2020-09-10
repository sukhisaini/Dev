@IsTest
private class APICalloutBatchJobTest {

	@TestSetup
	static void setupData() {
		//Create case record with status as closed
		//Create AusPostHubMessage__c record with IsSuccess as false and parentId as above case
		AusPostHubMessage__c ausPostHubMessage;
	}

	@IsTest
	static void batchRunWithSuccessTest() {
		Test.setMock(HttpCalloutMock.class, new AWSServicesMockResponseGenerator());
		Test.startTest();
		Database.executeBatch(new APICalloutBatchJob());
		Test.stopTest();

		//Select SOQL to get Case record with id as parentId of ausPostHubMessage record
		Case case;
		System.assertEquals('PDHE9Is7G3J9+soRTuW', case.secretKey, 'Secret Key is not updated after a successful callout');

		//Select SOQL to get AusPostHubMessage__c record created in setupData
		AusPostHubMessage__c ausPostHubMessage;
		System.assertEquals(true, ausPostHubMessage.IsSuccess,
			'After a successful callout the record must get updated with IsSuccess as true');
	}
}