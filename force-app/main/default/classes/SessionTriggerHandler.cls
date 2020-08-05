/**
* @author Divya Babani
* @date 20 Feb 2020
*
* 
*
* Object :-  Session__c
  Trigger:- SessionTrigger
  Desc:- to records of child object Student_Session__c once Session Status is cancelled
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
                    && sessionObj.Status__c == ConstantClass.cancelledStatus){
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
                                newStudentSessionToUpdate.add(new Student_Session__c(Status__c = ConstantClass.cancelledStatus,
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

    //Added by Rajesh on 31st July 2020, For session rollup on class
    public static void sessionRollUpOnClass(Set<String> clsIds){
        Map<String, Integer> clsSessionMap = new Map<String, Integer>();
        for(AggregateResult result : SessionService.getSessionsAgreeByClassIds(clsIds)){
            String clsId      = (String)result.get('Class__c');
            String status       = (String)result.get('Status__c');
            Integer countSess = (Integer)result.get('sessionCount');

            String key = clsId+':'+status;
            clsSessionMap.put(key,countSess );
        } 
        
        List<Class__c> updateClasList = new List<Class__c>();
        for(String clsId: clsIds){
            Class__c cls = new Class__c(Id=clsId, Total_Sessions__c=0, Scheduled_Sessions__c=0, Completed_Sessions__c=0, Cancelled_Sessions__c=0);
            String schKey   = clsId+':'+ConstantClass.ScheduledStatus;
            String cmpKey   = clsId+':'+ConstantClass.sessionCompleted;
            String cncldKey = clsId+':'+ConstantClass.cancelledStatus;

            if(clsSessionMap.get(schKey) != null){
                cls.Total_Sessions__c = clsSessionMap.get(schKey);
                cls.Scheduled_Sessions__c = clsSessionMap.get(schKey);
            }
            if(clsSessionMap.get(cmpKey) != null){
                cls.Total_Sessions__c    += clsSessionMap.get(cmpKey);
                cls.Completed_Sessions__c = clsSessionMap.get(cmpKey);
            }
            if(clsSessionMap.get(cncldKey) != null){
                cls.Cancelled_Sessions__c = clsSessionMap.get(cncldKey);
            }

            updateClasList.add(cls);
        }

        if(updateClasList.size() > 0)
            ClassService.updateClassRecords(updateClasList);
    }
}