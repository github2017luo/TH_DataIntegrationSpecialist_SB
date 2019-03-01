@isTest
private class BillingCalloutServiceTest {

    private static final String PROJECT_REF = '12345';
    private static final Integer AMOUNT = 1500;
    private static final Date TODAY_DATE = System.today();
    private static final Date TODAY_PLUS7 = TODAY_DATE.addDays(7);

    @testSetup private static void setup() {
        TestDataFactory.createBillingCredentials();
        String accId = TestDataFactory.createTestAccount();
        Opportunity opp = TestDataFactory.createTestOpportunity(accId, 'Submitted Project', TODAY_PLUS7, AMOUNT);

        Project__c project = new Project__c();
        project.Name = 'TestProject';
        project.Start_Date__c = TODAY_DATE;
        project.Status__c = 'Running';
        project.End_Date__c = TODAY_PLUS7;
        project.Billable_Amount__c = AMOUNT;
        project.ProjectRef__c = PROJECT_REF;
        project.Opportunity__c = opp.Id;
        insert project;
    }

    @isTest private static void checkSuccessCallout() {
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());

        Test.startTest();
        BillingCalloutService.callBillingService(AMOUNT, PROJECT_REF);
        Test.stopTest();

        List<Project__c> project = [SELECT Name, Status__c, ProjectRef__c FROM Project__c WHERE ProjectRef__c = :PROJECT_REF LIMIT 1];

        System.assert(project.size() != 0);
        System.assert(project.get(0).Status__c == 'Billed');
    }

    @isTest private static void checkFailureCallout() {
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());

        Test.startTest();
        BillingCalloutService.callBillingService(AMOUNT, PROJECT_REF);
        Test.stopTest();

        List<Project__c> project = [SELECT Name, Status__c, ProjectRef__c FROM Project__c WHERE ProjectRef__c = :PROJECT_REF LIMIT 1];

        System.assert(project.size() != 0);
        System.assert(project.get(0).Status__c == 'Running');
    }
}