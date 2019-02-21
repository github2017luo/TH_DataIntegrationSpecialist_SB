@isTest
private class ProjectRESTServiceTest {
  
    @testSetup static void setup() {

        String accId = TestDataFactory.createTestAccount();
        
        Date tempDate = System.today();
        Date oppCloseDate = tempDate.addDays(5);

        TestDataFactory.createTestOpportunity(accId, 'Submitted Project', oppCloseDate, 1500);
    }
    
    @isTest static void testProjectInsert() {
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='TestOpp' LIMIT 1];
        
        String oppId = opp.Id;
        Date startDate = System.today();
        Date endDate = startDate.addDays(7);
        Double amount = 1500;

        Test.startTest();
        String restStatus = ProjectRESTService.postProjectData('123456', 'TestProject', oppId, startDate,
                                          endDate, amount, 'Running');
        
        System.assertEquals('OK', restStatus);
        
        Project__c project = [SELECT Name, Opportunity__c, ProjectRef__c, Start_Date__c, Status__c,
                                End_Date__c, Billable_Amount__c FROM Project__c WHERE ProjectRef__c = '123456' LIMIT 1];
        
        System.assert(project != null);
        System.assertEquals(oppId, project.Opportunity__c);
        System.assertEquals('TestProject', project.Name);
        
        restStatus = ProjectRESTService.postProjectData('123456', 'TestProject', oppId, startDate,
                                          endDate, amount, 'Billed');
        
        System.assertEquals('OK', restStatus);
        
        List<Project__c> projectUpd = [SELECT Name, Opportunity__c, ProjectRef__c, Start_Date__c, Status__c,
                                End_Date__c, Billable_Amount__c FROM Project__c WHERE ProjectRef__c = '123456'];
        
        System.assert(projectUpd.size() == 1);
        System.assertEquals('TestProject', projectUpd[0].Name);
        System.assertEquals('Billed', projectUpd[0].Status__c);

        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity WHERE Name='TestOpp' LIMIT 1];

        System.assertEquals('In progress', updatedOpp.DeliveryInstallationStatus__c);
    }

    @isTest static void testProjectInsertFail() {
        Date startDate = System.today();
        Date endDate = startDate.addDays(7);
        Double amount = 1500;

        Test.startTest();
        String restStatus = ProjectRESTService.postProjectData('123456', 'TestProject', 'ABCD12345', startDate,
                endDate, amount, 'Running');

        Test.stopTest();

        System.assert(restStatus.contains('Invalid id'));
    }
}