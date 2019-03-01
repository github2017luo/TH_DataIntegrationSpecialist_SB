@isTest
private class ProjectRESTServiceTest {

    private static final String PROJECT_REF = '12345';
    private static final String PROJECT_NAME = 'TestProject';
    private static final Integer AMOUNT = 1500;
    private static final String OPP_NAME = 'TestOpp';
    private static final Date TODAY_DATE = System.today();
    private static final Date TODAY_PLUS7 = TODAY_DATE.addDays(7);
  
    @testSetup static void setup() {
        String accId = TestDataFactory.createTestAccount();

        TestDataFactory.createTestOpportunity(accId, 'Submitted Project', TODAY_PLUS7, AMOUNT);
    }
    
    @isTest static void testProjectInsert() {
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = :OPP_NAME LIMIT 1];
        
        String oppId = opp.Id;

        Test.startTest();
        String restStatus = ProjectRESTService.postProjectData(PROJECT_REF, PROJECT_NAME, oppId, TODAY_DATE,
                                                                TODAY_PLUS7, AMOUNT, 'Running');
        
        System.assertEquals('OK', restStatus);
        
        Project__c project = [SELECT Name, Opportunity__c, ProjectRef__c, Start_Date__c, Status__c,
                                End_Date__c, Billable_Amount__c FROM Project__c WHERE ProjectRef__c = :PROJECT_REF LIMIT 1];
        
        System.assert(project != null);
        System.assertEquals(oppId, project.Opportunity__c);
        System.assertEquals(PROJECT_NAME, project.Name);
        
        restStatus = ProjectRESTService.postProjectData(PROJECT_REF, PROJECT_NAME, oppId, TODAY_DATE,
                                                        TODAY_PLUS7, AMOUNT, 'Billed');
        
        System.assertEquals('OK', restStatus);
        
        List<Project__c> projectUpd = [SELECT Name, Opportunity__c, ProjectRef__c, Start_Date__c, Status__c,
                                End_Date__c, Billable_Amount__c FROM Project__c WHERE ProjectRef__c = :PROJECT_REF];
        
        System.assert(projectUpd.size() == 1);
        System.assertEquals(PROJECT_NAME, projectUpd[0].Name);
        System.assertEquals('Billed', projectUpd[0].Status__c);

        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity WHERE Name = :OPP_NAME LIMIT 1];

        System.assertEquals('In progress', updatedOpp.DeliveryInstallationStatus__c);
    }

    @isTest static void testProjectInsertFail() {

        Test.startTest();
        String restStatus = ProjectRESTService.postProjectData(PROJECT_REF, PROJECT_NAME, 'ABCD12345', TODAY_DATE,
                                                                TODAY_PLUS7, AMOUNT, 'Running');
        Test.stopTest();

        System.assert(restStatus.contains('Invalid id'));
    }
}