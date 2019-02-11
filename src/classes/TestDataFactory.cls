@isTest
public class TestDataFactory {

    public static ID createTestAccount() {
        Account acc = new Account(Name='TestAcc');
        Database.SaveResult dbResultAcc = Database.insert(acc, false);
        return dbResultAcc.getId();
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
            System.debug('Error during inserting test opportunity: ' + dmle.getStackTraceString());
            return null;
        }
        return opp;
    }

}