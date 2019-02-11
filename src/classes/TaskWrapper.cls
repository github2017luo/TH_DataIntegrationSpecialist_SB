public class TaskWrapper {

    private TaskSchema tSchema;
    private Task record;
    private String jsonValue;
    
    public TaskWrapper(String jsonValue) {
        this.jsonValue = jsonValue.replace('"id"', '"taskId"');
        try {
            tSchema = (TaskSchema)JSON.deserialize(this.jsonValue, TaskSchema.class);
        } catch (Exception ex) {
            throw new WrongTaskSchemaException(ex.getMessage());
        }
    }
    
    public TaskWrapper(TaskSchema tSchema) {
        this.tSchema = tSchema;
    }
    
    private Task generateRecord() {
        Task task = new Task();
        task.Status = tSchema.completed ? 'Completed' : 'Not Started';
        task.Subject = tSchema.title;
        task.ExternalTaskId__c = tSchema.taskId;
        this.record = task;
        return task;
    }
    
    public Task insertRecord() {
        generateRecord();
        if (String.isBlank(record.Id)) 
            insert record;
        
        return record;
    }
    
    public Task getRecord() {
        if (record == null) {
            generateRecord();
        }
        return record;
    }
    
    public class WrongTaskSchemaException extends Exception {}
}