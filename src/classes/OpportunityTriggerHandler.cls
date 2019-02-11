public class OpportunityTriggerHandler {
    public static void beforeInsert(List<Opportunity> records) {
        List<Task> tasksToInsert = new List<Task>();
        
        for (Opportunity record : records) {
            OpportunityValueWrapper vOpp = new OpportunityValueWrapper(record);
            if (!vOpp.validateOpportunityAccount()) {
                return;
            }
            
            if (vOpp.isHighValue()) {
                vOpp.addHighValueDescription();
                tasksToInsert.add(
                    createVerifyAccountTask(vOpp.getRecord())
                );
            } else if (vOpp.isExtremelyLowValue()) {
                vOpp.cancelOpportunity();
            }
        }
        
        insert tasksToInsert;
    }
    
    public static Task createVerifyAccountTask(Opportunity opp) {
        Task task = new Task();
        task.WhatId = opp.AccountId;
        task.Priority = 'High';
        task.Subject = 'Verify Account validity';
        return task;
    }
}