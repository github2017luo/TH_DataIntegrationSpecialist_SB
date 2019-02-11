public class DownloadTaskService {
    public static void downloadTask(Integer taskId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://jsonplaceholder.typicode.com/todos/'  + taskId);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        TaskWrapper wrapper = new TaskWrapper(res.getBody());
        wrapper.insertRecord();
    }
    
    public static List<Database.SaveResult> downloadTasks() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://jsonplaceholder.typicode.com/todos/');
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        List<TaskSchema> tasksSchemas = 
            (List<TaskSchema>)JSON.deserialize(res.getBody().replaceAll('"id"', '"taskId"'), List<TaskSchema>.class);
        
        List<Task> tasksToInsert = new List<Task>();
        for (TaskSchema tSchema : tasksSchemas) {
            TaskWrapper tWrapper = new TaskWrapper(tSchema);
            tasksToInsert.add(tWrapper.getRecord());
        }
        
        return Database.insert(tasksToInsert, false);
    }
    
    @future
    public static void deleteTasks(Set<Integer> tasksIds) {
        delete [SELECT Id FROM Task WHERE ExternalTaskId__c IN: tasksIds];
    }
    

}