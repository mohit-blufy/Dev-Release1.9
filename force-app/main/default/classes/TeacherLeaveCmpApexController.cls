public class TeacherLeaveCmpApexController {
    
    @AuraEnabled
    public static List<SessionDataWrapperClass> doInitApex(String recordId){
        List<SessionDataWrapperClass> listSessDataWrpCls = new List<SessionDataWrapperClass>();
        List<Teacher_Leave__c> listTeacherLeave = TeacherLeaveService.getByTeacherId(new Set<String>{recordId});
        if(listTeacherLeave != NULL && listTeacherLeave.size() > 0){
            Teacher_Leave__c teacherLeave = listTeacherLeave[0];
            for(Session__c session : SessionService.getSessionsByTeacherLeave(teacherLeave)){
                                         listSessDataWrpCls.add(fillSessionDataWrapper(session));             
                                     }
        }
        return  listSessDataWrpCls;
    } 
    
    @AuraEnabled
    public static String doSaveApex(String recordId,List<SessionDataWrapperClass> listSession){
        try{
            List<Session__c> listSessionToUpdate = new List<Session__c>();
            for(SessionDataWrapperClass sessWrpData : listSession){
                Session__c session = new Session__c();
                session.Id = sessWrpData.sessId;
                session.Teacher__c = sessWrpData.tchrId;
                listSessionToUpdate.add(session);
            }
            
            if(listSessionToUpdate.size() > 0){
                SessionService.updateSessionRecords(listSessionToUpdate);
                Teacher_Leave__c teacherLeave = new Teacher_Leave__c();
                teacherLeave.Id = recordId;
                teacherLeave.Status__c = ConstantClass.approvedStatus;
                TeacherLeaveService.updateTeacherLeaveRecords(new List<Teacher_Leave__c>{teacherLeave});
            }
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
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