@RestResource(urlMapping='/project')
global class ProjectRESTService {
    
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId,
                                      Date StartDate, Date EndDate, Double Amount, String Status) {
    
    	List<Project__c> projects = [SELECT Id, Name, Opportunity__c, ProjectRef__c, Start_Date__c, Status__c,
                                End_Date__c, Billable_Amount__c FROM Project__c WHERE ProjectRef__c = :ProjectRef];
        
        SavePoint sp = Database.setSavepoint();
        
        try {
            Project__c project = new Project__c();
            project.Name = ProjectName;
            project.Start_Date__c = StartDate;
            project.Status__c = Status;
            project.End_Date__c = EndDate;
            project.Billable_Amount__c = Amount;

            if(projects.size() == 0) {
                project.ProjectRef__c = ProjectRef;
                project.Opportunity__c = OpportunityId;
            } else {
                project.Id = projects[0].Id;
            }

            upsert project;

            Opportunity opp = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity 
                               WHERE Id = :OpportunityId LIMIT 1];
                                              
            opp.DeliveryInstallationStatus__c = 'In Progress';
            update opp;
            
        } catch (Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();
        }
        return 'OK';
    }
}