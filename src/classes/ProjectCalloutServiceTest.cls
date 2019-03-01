@isTest
private class ProjectCalloutServiceTest {

    private static final String OPP_NAME = 'TestOpp';

    @testSetup static void setup() {

        String accId = TestDataFactory.createTestAccount();

        TestDataFactory.createTestOpportunity(accId, 'Closed Won', System.today(), 1200);
        
        ServiceTokens__c token = new ServiceTokens__c(Name='ProjectServiceToken',Token__c='test');
		insert token;
    }
	
    @isTest static void positiveCalloutTest() {
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name = :OPP_NAME];
        List<ID> ids = new List<Id>(new Map<Id, Opportunity>(opps).keySet());
        
        Test.startTest();
        ProjectCalloutService.postOpportunityToPMS(ids);
        Test.stopTest();

        for(Opportunity opp : [SELECT StageName FROM Opportunity WHERE Name = :OPP_NAME]) {
            System.assertEquals('Submitted Project', opp.StageName);
        } 
	}
    
    @isTest static void failCalloutTest() {
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());

        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name = :OPP_NAME];
        List<ID> ids = new List<Id>(new Map<Id, Opportunity>(opps).keySet());
        
        Test.startTest();
        ProjectCalloutService.postOpportunityToPMS(ids);
        Test.stopTest();

        for(Opportunity opp : [SELECT StageName FROM Opportunity WHERE Name = :OPP_NAME]) {
            System.assertEquals('Resubmit Project', opp.StageName);
        }
    }
}