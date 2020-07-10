trigger AccountTrigger on Account (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        AccountTriggerHelper accTriggerObj = new AccountTriggerHelper();
        accTriggerObj.createTeacherWorkingHours(Trigger.New);
    }
    
}