@isTest
public class OpportunityTriggerTest {
    
    @testSetup
    private static void testSetup() {
        
        Account acc = new Account();
        acc.Name = 'testAcc';
        insert acc;
        
    }
    
	@isTest
    private static void insertHighValueOpp() {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1];
        
        Opportunity opp = new Opportunity();
        opp.CloseDate = System.today().addDays(5);
        opp.Name = 'TestOpp';
        opp.ForecastCategoryName = 'Pipeline';
        opp.Probability = 0.3;
        opp.StageName = 'Qualification';
        opp.AccountId = acc.Id;
        opp.Amount = 90000;
        
        Database.SaveResult saveResult = Database.insert(opp, false);
        
        System.assert(saveResult.isSuccess());
        
        opp = [SELECT Id, Description FROM Opportunity WHERE Id = :saveResult.getId() LIMIT 1];
        
        System.assertEquals('THIS IS HIGH VALUE OPPORTUNITY. Take extra care!', opp.Description);
        
        Task highValueTask = [SELECT WhatId, Priority, Subject FROM Task WHERE WhatId = :acc.Id LIMIT 1];
        
        System.assert(highValueTask != null);
        System.assertEquals('High', highValueTask.Priority);
        System.assertEquals('Verify Account validity', highValueTask.Subject);
        
    }
}