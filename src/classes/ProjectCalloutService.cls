public class ProjectCalloutService {
    
    @InvocableMethod
	public static void postOpportunityToPMS(List<ID> opps){
        
        String oppId = opps[0];
        Opportunity opportunity = [SELECT Name, CloseDate, Amount, Account.Name, StageName FROM Opportunity WHERE Id = :oppId];
        OppJSON oppToJSON = new OppJSON();
        oppToJSON.opportunityId = opportunity.Id;
        oppToJSON.opportunityName = opportunity.Name;
        oppToJSON.accountName = opportunity.Account.Name;
        oppToJSON.closeDate = opportunity.CloseDate;
        oppToJSON.amount = opportunity.Amount;
        
        String oppToSend = JSON.serialize(oppToJSON);
        
        callEndpoint(oppId, oppToSend);
        
        System.enqueueJob(new QueueablePMSCall(oppId, oppToSend));
    }
    
    @future(callout=true)
    public static void callEndpoint(String oppId, String body) {
            
		HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ProjectService');
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        ServiceTokens__c tokenCS = ServiceTokens__c.getValues('ProjectServiceToken');
        String token = tokenCS.Token__c;
        request.setHeader('token', token);
        request.setBody(body);
            
        Http http = new Http();
        HttpResponse response = http.send(request);
            
 		Opportunity opportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId];

  		if(response.getStatus() == 'OK' || response.getStatusCode() == 201) {
            opportunity.StageName = 'Submitted Project';
        } else if(response.getStatusCode() == 500) {
            opportunity.StageName = 'Resubmit Project';
        }

        try {
            update opportunity;
        } catch(DmlException dmle) {
            System.debug('Error during update Opportunity stage: ' + dmle.getStackTraceString());
        }
    }
    
    public class OppJSON {
        public String opportunityId;
        public String opportunityName;
        public String accountName;
        public Date closeDate;
        public Decimal amount;
    }
    
    public class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts {
        String oppId;
        String body;
        public QueueablePMSCall(String oppId, String body) {
            this.oppId = oppId;
            this.body = body;
        }
        public void execute(QueueableContext ctx) {
            callEndpoint(this.oppId, this.body);
        }
    }
}