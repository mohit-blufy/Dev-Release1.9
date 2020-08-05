/**
* @author Divya Babani
* @date 20 Feb 2020
*
* 
*
* Object :-  Session__c
  Trigger:- After Update
  Desc:- to records of child object Student_Session__c once Session Status is cancelled
*/
trigger SessionTrigger on Session__c(after insert,after update) {
    if(Trigger.isUpdate && Trigger.isAfter){
        SessionTriggerHandler.updateStudentSession(Trigger.oldMap,Trigger.newMap);
    }

    //Added by Rajesh on 31st July 2020, For session rollup on class
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
      Set<String> clsIds = new Set<String>();
      for(Session__c sess: Trigger.new){
          if(sess.Class__c != null && (Trigger.isInsert || (Trigger.isUpdate && sess.Status__c != Trigger.oldMap.get(sess.Id).Status__c))){
            clsIds.add(sess.Class__c);
          }    
      }
      if(clsIds.size() > 0){
        SessionTriggerHandler.sessionRollUpOnClass(clsIds);
      }
    } 
}