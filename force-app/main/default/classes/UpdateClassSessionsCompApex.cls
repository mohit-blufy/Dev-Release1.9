public class UpdateClassSessionsCompApex {
    
    @AuraEnabled
    public static List<SessionDataWrapperClass> doInitApex(String recordId){
        List<SessionDataWrapperClass> listSessDataWrpCls = new List<SessionDataWrapperClass>();
        List<Session__c> listSession = SessionService.getSessionsByClassId(recordId);
        if(listSession != NULL && listSession.size() > 0){
            for(Session__c session : listSession){
                listSessDataWrpCls.add(fillSessionDataWrapper(session));             
            }
            return listSessDataWrpCls;
        }
        return null;
    }
    
    public static SessionDataWrapperClass fillSessionDataWrapper(Session__c session){
        SessionDataWrapperClass sessDataWrpcls = new SessionDataWrapperClass();
        sessDataWrpcls.tchrId = session.Teacher__c;
        sessDataWrpcls.tchrName = session.Teacher__r.Name;
        sessDataWrpcls.roomId = session.Room__c;
        sessDataWrpcls.roomName = session.Room__r.Name;
        sessDataWrpcls.sessId = session.Id;
        sessDataWrpcls.sessSequence = session.Sequence__c;
        sessDataWrpcls.status = session.Status__c;
        sessDataWrpcls.stDate = session.Session_Date__c;
        sessDataWrpcls.sessDay = ((Datetime)session.Session_Date__c).format('EEEE');
        Date today = System.today();
        DateTime strtTime = DateTime.newInstance(today,session.Start_Time__c);
        sessDataWrpcls.stTime = strtTime.format('hh:mm:ss.sss');
        sessDataWrpcls.endTime = session.End_Time__c;
        return sessDataWrpcls;
    }
    
    public Class SessionDataWrapperClass{
        @AuraEnabled public String sessId{get;Set;}
        @AuraEnabled public Decimal sessSequence{get;Set;}
        @AuraEnabled public String  tchrId{get;set;}
        @AuraEnabled public String  tchrName{get;set;}
        @AuraEnabled public String  roomId{get;set;}
        @AuraEnabled public String  roomName{get;set;}
        @AuraEnabled public String  status{get;set;}
        @AuraEnabled public Date    stDate{get;set;}
        @AuraEnabled public String  sessDay{get;set;}
        @AuraEnabled public String    stTime{get;set;}
        @AuraEnabled public Time    endTime{get;set;}        
    }
}