@isTest
private class BillingCalloutServiceTest {

    private static final String PROJECT_REF = '12345';
    private static final Integer AMOUNT = 1500;

    @testSetup private static void setup() {
        TestDataFactory.createBillingCredentials();

        String accId = TestDataFactory.createTestAccount();

        Date todayDate = System.today();
        Date oppCloseDate = todayDate.addDays(5);

        Opportunity opp = TestDataFactory.createTestOpportunity(accId, 'Submitted Project', oppCloseDate, AMOUNT);

        Project__c project = new Project__c();
        project.Name = 'TestProject';
        project.Start_Date__c = todayDate;
        project.Status__c = 'Running';
        project.End_Date__c = oppCloseDate;
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