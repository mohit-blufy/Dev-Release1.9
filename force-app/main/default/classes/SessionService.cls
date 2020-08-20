public class SessionService {
    
    //Get Sessions By Class Id
    public static List<Session__c> getSessionsByClassId(String classId){
        try{
            List<Session__c> listSession = [SELECT Id,Name,Session_Date__c,Start_Time__c,End_Time__c,Status__c,Teacher__c,Teacher__r.Name,
                                            Room__c,Room__r.Name,Sequence__c FROM Session__c WHERE Class__c =: classId
                                            AND Status__c =: ConstantClass.ScheduledStatus WITH SECURITY_ENFORCED];
            return listSession;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
    
    //Insertion of Session Records
    public static List<Session__c> insertSessionRecords(List<Session__c> listSession){
        try{
            if(listSession.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listSession,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Session Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Session Error Message-->'+e.getMessage());
        }
        return null;
    }
    
    //updation of Session Records    
    public static List<Session__c> updateSessionRecords(List<Session__c> listSession){
        if(listSession.size() > 0){
            try{        
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listSession,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Session Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
            
            catch(Exception e){
                System.debug('Session Error Message-->'+e.getMessage());
            }
        }
        return null;
    }
    
    //get of Session Records
    public static List<Session__c> getById(set<Id> sessionId){
        try{
            List<Session__c> listSession = [SELECT Id, Location__c,
                                            Teacher__c, Teacher__r.location__c, 
                                            Session_Date__c, Start_Time__c,
                                            Notes__c, Type__c
                                            FROM Session__c 
                                            WHERE id IN: sessionId
                                            WITH SECURITY_ENFORCED];
            return listSession;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;         
    }
    
    public static List<Session__c> getSessionsByTeacherId(Set<String> setTeacherId){
        try{
            List<Session__c> listSession = [SELECT Id, Name, Status__c,Start_Time__c,End_Time__c,Session_Date__c,Teacher__c 
                                            FROM Session__c WHERE Teacher__c IN: setTeacherId AND 
                                            Session_Date__c != null AND Status__c = 'Scheduled' WITH SECURITY_ENFORCED];
            return listSession;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null; 
    }
    
    public static List<Session__c> getSessionsByRoomId(Set<String> setRoomId){
        try{
            List<Session__c> listSession = [SELECT Id, Name, Status__c,Start_Time__c,End_Time__c,Session_Date__c,Room__c 
                                            FROM Session__c WHERE Room__c IN: setRoomId AND Session_Date__c != null 
                                            AND Status__c = 'Scheduled' WITH SECURITY_ENFORCED];
            return listSession;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null; 
    }
    
    //Added by Rajesh on 31st July 2020, For session rollup on class
    public static List<AggregateResult> getSessionsAgreeByClassIds(Set<String> clsIds){
        try{
            List<String> excludeTypeList = new List<String>{ConstantClass.sessionType, ConstantClass.sessionIndividualType};
                return [SELECT Count(Id) sessionCount, Class__c, Status__c 
                        FROM Session__c WHERE Class__c IN: clsIds AND Type__c NOT IN:excludeTypeList WITH SECURITY_ENFORCED
                        GROUP BY Class__c, Status__c];  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null; 
    }
    
    public static List<Session__c> getSessionsByTeacherLeave(Teacher_Leave__c teacherLeave){
        try{
            List<Session__c> listSession = [SELECT Id,Name,Session_Date__c,Start_Time__c,End_Time__c,Status__c,Teacher__c,Teacher__r.Name
                                            FROM Session__c WHERE Teacher__c =:teacherLeave.Teacher__c AND Status__c !=: ConstantClass.cancelledStatus
                                            AND Session_Date__c >=: teacherLeave.Start_Date__c AND Session_Date__c <=: teacherLeave.End_Date__c
                                           ];
            return listSession;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null; 
    }
}