public class StudentSessionService {

    //Insertion of Student Session Term Records
    public static List<Student_Session__c> insertStudentSessionRecords(List<Student_Session__c> listStudentSession){
        try{
            if(listStudentSession.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE,listStudentSession,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Student Session Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Student Session Error Message-->'+e.getMessage());
        }
        return null;
    }
    
    //Update of Student Session Records
    public static List<Student_Session__c> updateStudentSessionRecords(List<Student_Session__c> listStudentSession){
        try{
            if(listStudentSession.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listStudentSession,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Student Session Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Student Session Error Message-->'+e.getMessage());
        }
        return null;
    }

    public static List<Student_Session__c> getBySessionId(Set<Id> sessionIds){
        if(sessionIds.size() > 0){
            try{
                return [SELECT Session__c, Session__r.Teacher__r.Name,
                        Account__r.Name, Session__r.Class__r.Name, 
                        Status__c, Notes__c, Enrollment__c,
                        Session__r.Class__r.Course__r.Name
                        FROM Student_Session__c
                        WHERE Session__c IN :sessionIds
                        WITH SECURITY_ENFORCED];
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
}
