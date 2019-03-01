@isTest
public class TestDataFactory {

    public static ID createTestAccount() {
        Account acc = new Account(Name='TestAcc');
        try {
            insert acc;
            return acc.Id;
        } catch (DmlException dmle) {
            System.debug('Error during inserting test opportunity: ' + dmle.getMessage());
        }
        return null;
    }

    public static Opportunity createTestOpportunity(ID accountId, String stageName, Date closeDate, Integer amount) {
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp';
        opp.AccountId = accountId;
        opp.StageName = stageName;
        opp.CloseDate = closeDate;
        opp.amount = amount;

        try{
            insert opp;
        } catch(DmlException dmle) {
            System.debug('Error during inserting test opportunity: ' + dmle.getMessage());
            return null;
        }
        return opp;
    }

    public static void createBillingCredentials() {
        ServiceCredentials__c credentials = new ServiceCredentials__c(Name = 'BillingServiceCredential', Username__c = 'testUsername', Password__c = 'testPassword');
        insert credentials;
    }
}