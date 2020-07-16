/**
Name        :   AccountTrigger
Date        :   08-07-20
Description :   This Trigger is use for insert teacher working hours which are inherit from location
Dev         :   Asif
*/
trigger AccountTrigger on Account (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        // AccountTriggerHelper accTriggerObj = new AccountTriggerHelper();
        AccountTriggerHelper.createTeacherWorkingHours(Trigger.New);
    }
    
}