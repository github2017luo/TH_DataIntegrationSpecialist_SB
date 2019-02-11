@isTest
private class DownloadTaskServiceTest {
    @isTest
    private static void requestForTasksTest() {
        Test.setMock(HttpCalloutMock.class, new DownloadTaskMock('', true));
        Test.startTest();
        List<Database.SaveResult> taskList = DownloadTaskService.downloadTasks();
        Test.stopTest();
        
        System.assertEquals(3, taskList.size());
    }
    
    @isTest
    private static void requestForOneTaskTest() {
        String taskId = '88';
        Test.setMock(HttpCalloutMock.class, new DownloadTaskMock(taskId, true));
        Test.startTest();
        DownloadTaskService.downloadTask(Integer.valueOf(taskId));
        Test.stopTest();
        
		List<Task> requestedTasks = [SELECT Id, ExternalTaskId__c, Subject FROM Task WHERE ExternalTaskId__c = 88];

		System.assert(requestedTasks.size() == 1);
		System.assertEquals(Decimal.valueOf(taskId), requestedTasks.get(0).ExternalTaskId__c);        
    }
    
    @isTest
    private static void responseWithInvalidJSON() {
        String taskId = '88';
        Test.setMock(HttpCalloutMock.class, new DownloadTaskMock(taskId, false));
        Exception thrownException;
        Test.startTest();
        try {
        	DownloadTaskService.downloadTask(Integer.valueOf(taskId));
        } catch(TaskWrapper.WrongTaskSchemaException wtse) {
            thrownException = wtse;
        }
        Test.stopTest();
        System.assert(thrownException != null);
        System.assertEquals('TaskWrapper.WrongTaskSchemaException', thrownException.getTypeName());
    }
    
    @isTest
    private static void deleteTasksTest() {
        List<Task> tasksList = new List<Task>();
        Task testTask;
        Set<Integer> taskIds = new Set<Integer>();
        
        for(Integer i = 1; i <= 10; i++) {
            testTask = new Task();
            testTask.ExternalTaskId__c = i;
            testTask.Priority = 'Low';
            testTask.Status = 'In Progress';
            tasksList.add(testTask);
            if(Math.mod(i, 2) == 0) {
                taskIds.add(i);
            }
        }
        Database.SaveResult[] saveResults = Database.insert(tasksList);
        
        Test.startTest();
        DownloadTaskService.deleteTasks(taskIds);
        Test.stopTest();
        
        List<Task> remainTasks = [SELECT ExternalTaskId__c FROM Task];
        
        System.assert(remainTasks.size() == 5);
        
        for(Task task : remainTasks) {
            System.assert(!taskIds.contains(Integer.valueOf(task.ExternalTaskId__c)));
        }
        
    }
    
    public class DownloadTaskMock implements HttpCalloutMock {
        public String taskId;
        public Boolean isJSONvalid;
        public DownloadTaskMock(String taskId, Boolean isJSONvalid) {
            this.taskId = taskId;
            this.isJSONvalid = isJSONvalid;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if(!isJSONvalid) {
                res.setBody('{"usId":1,"id":'+ Integer.valueOf(taskId) +',"ti:"test1","completed":false}');
            } else if(String.isBlank(taskId)) {
                res.setBody('[{"userId":1,"id":1,"title":"test1","completed":false},{"userId":1,"id":2,"title":"test2","completed":true},{"userId":1,"id":3,"title":"test3","completed":false}]');
            } else {
                res.setBody('{"userId":1,"id":'+ Integer.valueOf(taskId) +',"title":"test1","completed":false}');
            }
            
            return res;
        }
    }

}