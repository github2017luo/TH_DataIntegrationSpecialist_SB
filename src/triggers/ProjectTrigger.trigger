trigger ProjectTrigger on Project__c (after update) {
    
    for(ID projectId : Trigger.newMap.keySet()) {
        if(Trigger.oldMap.get(projectId).Status__c != 'Billable' && 
           Trigger.newMap.get(projectId).Status__c == 'Billable') {
               
            Decimal amount = Trigger.newMap.get(projectId).Billable_Amount__c;
            String projectRef = Trigger.newMap.get(projectId).ProjectRef__c;
            BillingCalloutService.callBillingService(amount, projectRef);
        }
    }
    
}