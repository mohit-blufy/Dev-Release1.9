/**
* @author Divya Babani
* @date 20 Feb 2020
*
* 
*
* Object :-  Session__c
  Trigger:- SessionTrigger
  Desc:- to records of child object Student_Session__c once Session Status is canceled
*/
public class SessionTriggerHandler {
    public static void updateStudentSession(Map<id,Session__c> oldSessionMap,Map<id,Session__c> newSessionMap){
        Set<Id> sessionIds = new  Set<Id>();
        Map<Id,List<Student_Session__c>> studentSessionToUpdate = new Map<Id,List<Student_Session__c>>();
        List<Student_Session__c> newStudentSessionToUpdate = new List<Student_Session__c>();
        try{
            //get ids of session whose status is cancelled
            for (Session__c sessionObj: newSessionMap.values()) {
                if(oldSessionMap.get(sessionObj.id).Status__c != sessionObj.Status__c
                    && sessionObj.Status__c == 'Canceled'){
                    sessionIds.add(sessionObj.id);
                }
            }
            //get ids of session whose status is cancelled

            //get map of session child object StudentSession to chnage status of them as Parent
            if(sessionIds.size() > 0){
                studentSessionToUpdate = getStudentSessions(sessionIds);
                if(!studentSessionToUpdate.isEmpty()){
                    for(Id  sessionIdObj: sessionIds){
                        if(studentSessionToUpdate.containsKey(sessionIdObj)){
                            for (Student_Session__c studentSessionRecord : studentSessionToUpdate.get(sessionIdObj))
                            {
                                newStudentSessionToUpdate.add(new Student_Session__c(Status__c = 'Canceled',
                                                                                id = studentSessionRecord.id,
                                                                                Session__c = sessionIdObj)
                                                              );
                            }
                        }
                    }
                }
            }
            if(newStudentSessionToUpdate.size() > 0){
                update newStudentSessionToUpdate;
            }
        }catch(Exception e){
            system.debug('Exception==='+e.getMessage());
        }
    }

    //Divya: to get Student Sessions Map by session id
    public static Map<Id, List<Student_Session__c>> getStudentSessions(Set<Id> sessionIds){
        Map<Id, List<Student_Session__c>> studentSessionWithSessionMap = new Map<Id, List<Student_Session__c>>();
        for(Student_Session__c studentSessionObj : [SELECT Id,Session__c, Status__c 
                                                    from Student_Session__c
                                                    WHERE Session__c IN :sessionIds ]){
            if(!studentSessionWithSessionMap.containsKey(studentSessionObj.Session__c)){
                studentSessionWithSessionMap.put(studentSessionObj.Session__c, new List<Student_Session__c>());
            }
            studentSessionWithSessionMap.get(studentSessionObj.Session__c).add(studentSessionObj);

        }
        return studentSessionWithSessionMap;
    }
    //Divya: to get Student Sessions Map by session id
}