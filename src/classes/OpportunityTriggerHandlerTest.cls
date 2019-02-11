@isTest
private class OpportunityTriggerHandlerTest {
	@testSetup
    private static void testSetup() {
        
        Account acc = new Account();
        acc.Name = 'testAcc';
        insert acc;
        
    }
    
    @isTest
    private static void testHighValueOpp() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1];
        
        List<Opportunity> opps = new List<Opportunity>();
        
        Opportunity opp = new Opportunity();
        opp.CloseDate = System.today().addDays(5);
        opp.Name = 'TestOpp';
        opp.ForecastCategoryName = 'Pipeline';
        opp.Probability = 0.3;
        opp.StageName = 'Qualification';
        opp.AccountId = acc.Id;
        opp.Amount = 20000;
        
        opps.add(opp);
        
        OpportunityTriggerHandler.beforeInsert(opps);
        
        System.assertEquals('THIS IS HIGH VALUE OPPORTUNITY. Take extra care!', opps.get(0).Description);        
    }
    
    @isTest
    private static void testLowValueOpp() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1];
        
        List<Opportunity> opps = new List<Opportunity>();
        
        Opportunity opp = new Opportunity();
        opp.CloseDate = System.today().addDays(5);
        opp.Name = 'TestOpp';
        opp.ForecastCategoryName = 'Pipeline';
        opp.Probability = 0.3;
        opp.StageName = 'Qualification';
        opp.AccountId = acc.Id;
        opp.Amount = 0;
        
        opps.add(opp);
        
        OpportunityTriggerHandler.beforeInsert(opps);
        
        System.assertEquals('Opportunity of extremely low value. Not worth considering.', opps.get(0).Description);
        System.assertEquals('Closed Lost', opps.get(0).StageName);
    }
    
    @isTest
    private static void testOppWithoutAccount() {
    
        List<Opportunity> opps = new List<Opportunity>();
        
        Opportunity opp = new Opportunity();
        opp.CloseDate = System.today().addDays(5);
        opp.Name = 'TestOpp';
        opp.ForecastCategoryName = 'Pipeline';
        opp.Probability = 0.3;
        opp.StageName = 'Qualification';
        opp.Amount = 0;
        
        opps.add(opp);
        
        try {
        	OpportunityTriggerHandler.beforeInsert(opps);
        } catch(Exception ex) {
            System.assert(ex != null);
        }
        
    }
}