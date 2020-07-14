/**
Name        :   ModuleLessonTrigger
Date        :   14-07-20
Description :   This Trigger is use for insert duration__c from lesson object
*/
trigger ModuleLessonTrigger on Module_Lesson__c (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ModuleLessonTriggerHelper mltObj = new ModuleLessonTriggerHelper();
            mltObj.fillDuration(Trigger.new);
        }
    }
}