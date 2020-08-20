public class TeacherLeaveService {
    
    public static List<Teacher_Leave__c> getByTeacherId(set<String> setTeacherId){
        try{
            List<Teacher_Leave__c> listTeacherLeave = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c,Teacher__c 
                                                       FROM Teacher_Leave__c WHERE Teacher__c IN: setTeacherId AND 
                                                       Start_Date__c != null AND End_Date__c != null AND Status__c != 'Rejected'
                                                       WITH SECURITY_ENFORCED];
            return listTeacherLeave;
        } catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
    
    //updation of Teacher Leave Records    
    public static List<Session__c> updateTeacherLeaveRecords(List<Teacher_Leave__c> listTeacherLeave){
        if(listTeacherLeave.size() > 0){
            try{        
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listTeacherLeave,true);
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
}