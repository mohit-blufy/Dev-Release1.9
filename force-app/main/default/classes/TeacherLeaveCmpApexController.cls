public class TeacherLeaveCmpApexController {
    static Boolean isTeacherLeaveAccessible = FieldPremissionCrudUtility.checkReadPermission('Teacher_Leave__c',  
                                                                                             new Set<String>{'Id', 'Teacher__c','End_Date__c','Start_Date__c'},false);
    static Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c',  
                                                                                        new Set<String>{'Id','Name','Session_Date__c','Start_Time__c','End_Time__c','Status__c','Teacher__c'},false);
    static Boolean isTeacherLeaveAccessibleForInstUpdte = FieldPremissionCrudUtility.checkReadPermission('Teacher_Leave__c',  
                                                                                                         new Set<String>{'Teacher__c','End_Date__c','Start_Date__c'},true,false);
    static Boolean isSessionAccessibleForInstUpdte = FieldPremissionCrudUtility.checkReadPermission('Session__c',  
                                                                                                    new Set<String>{'Session_Date__c','Start_Time__c','Status__c','Teacher__c'},true,false);
    @AuraEnabled
    public static List<SessionDataWrapperClass> doInitApex(String recordId){
        List<SessionDataWrapperClass> listSessDataWrpCls = new List<SessionDataWrapperClass>();
        if(isTeacherLeaveAccessible && isSessionAccessible){
            List<Teacher_Leave__c> listTeacherLeave = [SELECT Id,Teacher__c,End_Date__c,Start_Date__c FROM Teacher_Leave__c WHERE Id =:recordId];
            if(listTeacherLeave != NULL && listTeacherLeave.size() > 0){
                Teacher_Leave__c teacherLeave = listTeacherLeave[0];
                for(Session__c session : [SELECT Id,Name,Session_Date__c,Start_Time__c,End_Time__c,Status__c,Teacher__c,Teacher__r.Name
                                          FROM Session__c WHERE Teacher__c =:teacherLeave.Teacher__c AND Status__c !=: ConstantClass.sessionCancel
                                          AND Session_Date__c >=: teacherLeave.Start_Date__c AND Session_Date__c <=: teacherLeave.End_Date__c
                                         ]){
                                             listSessDataWrpCls.add(fillSessionDataWrapper(session));             
                                         }
            }
            return  listSessDataWrpCls;
        }
        return  null;
    }
    
    public static SessionDataWrapperClass fillSessionDataWrapper(Session__c session){
        SessionDataWrapperClass sessDataWrpcls = new SessionDataWrapperClass();
        sessDataWrpcls.tchrId = session.Teacher__c;
        sessDataWrpcls.tchrName = session.Teacher__r.Name;
        sessDataWrpcls.sessId = session.Id;
        sessDataWrpcls.sessName = session.Name;
        sessDataWrpcls.status = session.Status__c;
        sessDataWrpcls.stDate = session.Session_Date__c;
        sessDataWrpcls.sessDay = ((Datetime)session.Session_Date__c).format('EEEE');
        sessDataWrpcls.stTime = session.Start_Time__c;
        sessDataWrpcls.endTime = session.End_Time__c;
        return sessDataWrpcls;
    }
    
    @AuraEnabled
    public static String doSaveApex(String recordId,List<SessionDataWrapperClass> listSession){
        try{
            List<Session__c> listSessionToUpdate = new List<Session__c>();
            List<Teacher_Leave__c> listTeacherLeaveToUpdate = new List<Teacher_Leave__c>();
            if(isTeacherLeaveAccessibleForInstUpdte && isSessionAccessibleForInstUpdte){
                for(SessionDataWrapperClass sessWrpData : listSession){
                    Session__c session = new Session__c();
                    session.Id = sessWrpData.sessId;
                    session.Teacher__c = sessWrpData.tchrId;
                    listSessionToUpdate.add(session);
                }
                
                if(listSessionToUpdate.size() > 0){
                    update listSessionToUpdate;
                    Teacher_Leave__c teacherLeave = new Teacher_Leave__c();
                    teacherLeave.Id = recordId;
                    teacherLeave.Status__c = ConstantClass.approvedStatus;
                    listTeacherLeaveToUpdate.add(teacherLeave);
                }
                
                if(listTeacherLeaveToUpdate.size() > 0)
                    update listTeacherLeaveToUpdate;
                
                return 'SUCCESS';
            }
            return 'FLS NOT FOUND.';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    public Class SessionDataWrapperClass{
        @AuraEnabled public String sessId{get;Set;}
        @AuraEnabled public String  tchrId{get;set;}
        @AuraEnabled public String  tchrName{get;set;}
        @AuraEnabled public String  sessName{get;set;}
        @AuraEnabled public String  status{get;set;}
        @AuraEnabled public Date    stDate{get;set;}
        @AuraEnabled public String  sessDay{get;set;}
        @AuraEnabled public Time    stTime{get;set;}
        @AuraEnabled public Time    endTime{get;set;}        
    }
    
}