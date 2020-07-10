/**
* @author Divya Babani
* @date 20 Feb 2020
*
* 
*
* Object :-  Session__c
  Trigger:- After Update
  Desc:- to records of child object Student_Session__c once Session Status is canceled
*/
trigger SessionTrigger on Session__c(after update) {
    if(Trigger.isUpdate && Trigger.isAfter){
        SessionTriggerHandler.updateStudentSession(Trigger.oldMap,Trigger.newMap);
    }
}