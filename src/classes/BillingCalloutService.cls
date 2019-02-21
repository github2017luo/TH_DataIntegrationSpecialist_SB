global class BillingCalloutService {
    
    @future(callout=true)
    public static void callBillingService(Decimal amount, String projectRef) {
        BillingServiceProxy.project bsProject = new BillingServiceProxy.project();

        bsProject.billAmount = amount;
        bsProject.projectid = projectRef;
        ServiceCredentials__c credentials = ServiceCredentials__c.getValues('BillingServiceCredential');
        bsProject.username = credentials.Username__c;
        bsProject.password = credentials.Password__c;

        BillingServiceProxy.InvoicesPortSoap11 portSoap11 = new BillingServiceProxy.InvoicesPortSoap11();
        String result = portSoap11.billProject(bsProject);

        if(result == 'OK') {
            Project__c project = [SELECT Id, Status__c FROM Project__c WHERe ProjectRef__c = :projectRef LIMIT 1];
            project.Status__c = 'Billed';

            try {
                update project;
            } catch (DmlException dmle) {
                System.debug('Error during updating project to Billable: ' + dmle.getMessage());
            }
        } else {
            System.debug('Error during Billing Service callout.');
        }
    }
}