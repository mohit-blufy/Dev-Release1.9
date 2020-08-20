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
        return listSessDataWrpCls;
    }
    
    @AuraEnabled 
    public static String doSaveApex(String listSessionString){
        try{
            List<Session__c> listSessionToUpdate = new List<Session__c>();
            List<SessionDataWrapperClass> listSession = (List<SessionDataWrapperClass>)JSON.deserialize(listSessionString, List<SessionDataWrapperClass>.class);
            if(listSession.size() > 0){
                for(SessionDataWrapperClass sessWrap : listSession){
                    listSessionToUpdate.add(fillSessionRecords(sessWrap));
                }
            }
            
            if(listSessionToUpdate.size() > 0){
                SessionService.updateSessionRecords(listSessionToUpdate);
            }
            return 'SUCCESS';
        }
        catch(Exception e){
            System.debug('e.getMessage()'+e.getMessage());
            System.debug('e.getLineNumber()'+e.getLineNumber());
            return e.getMessage()+e.getLineNumber();
        }
    }
    
    @AuraEnabled
    public static SessionDataWrapperClass checkTeacherRoomAvailability(String session,String type){
        try{
            SessionDataWrapperClass sess = (SessionDataWrapperClass)JSON.deserialize(session, SessionDataWrapperClass.class);
            SessionDataWrapperClass updatedSess = new SessionDataWrapperClass();
            
            if(sess != NULL){
                Session__c sessObj = fillSessionRecords(sess);
                sessObj = UtilityClass.checkAvailabilityTeacherOrRoom(sessObj, type);
                updatedSess = fillSessionDataWrapper(sessObj);
            }
            system.debug('updatedSess-->'+updatedSess);
            return updatedSess;
        }
        catch(Exception e){
            system.debug('Error-->'+e.getMessage()+e.getLineNumber());
        }
        return null;
    }
    
    public static Session__c fillSessionRecords(SessionDataWrapperClass sessWrap){
        Session__c sess =  new Session__c();
        sess.Id = sessWrap.sessId;
        sess.Teacher__c = (String.isNotBlank(sessWrap.tchrId) ? sessWrap.tchrId : null);
        sess.Type__c = sessWrap.sType;
        sess.Room__c = (String.isNotBlank(sessWrap.roomId) ? sessWrap.roomId : null);
        sess.Sequence__c = sessWrap.sessSequence;
        sess.Session_Date__c = sessWrap.stDate;
        sess.Duration__c = sessWrap.sessDuration;  
        sess.Exception__c = sessWrap.sException;
        if(String.isNotBlank(sessWrap.stTime)){
            List<String> listTimeValues = sessWrap.stTime.split(':');
            sess.Start_Time__c = Time.newInstance(Integer.valueOf(listTimeValues[0]),Integer.valueOf(listTimeValues[1]),00,00);
        }
        return sess;
    }
    
    public static SessionDataWrapperClass fillSessionDataWrapper(Session__c session){
        SessionDataWrapperClass sessDataWrpcls = new SessionDataWrapperClass();
        sessDataWrpcls.tchrId = session.Teacher__c;
        sessDataWrpcls.tchrName = session.Teacher__r.Name;
        sessDataWrpcls.roomId = session.Room__c;
        sessDataWrpcls.roomName = session.Room__r.Name;
        sessDataWrpcls.sessId = session.Id;
        sessDataWrpcls.sessSequence = session.Sequence__c;
        sessDataWrpcls.stDate = session.Session_Date__c;
        sessDataWrpcls.sessDuration = session.Duration__c;
        sessDataWrpcls.sException = session.Exception__c;
        sessDataWrpcls.sType = session.Type__c;
        if(String.isNotBlank(session.Type__c) && session.Type__c == ConstantClass.sessionExceptionType && 
           String.isNotBlank(session.Exception__c) && session.Exception__c.contains('Teacher')){
               sessDataWrpcls.isTeacherNotAvailable = true;
           }
        
        if(String.isNotBlank(session.Type__c) && session.Type__c == ConstantClass.sessionExceptionType && 
           String.isNotBlank(session.Exception__c) && session.Exception__c.contains('Room')){
               sessDataWrpcls.isRoomNotAvailable = true;
           }
        Date today = Date.today();
        DateTime strtTime = DateTime.newInstance(Date.today(),session.Start_Time__c);
        sessDataWrpcls.stTime = strtTime.format('HH:mm:ss.sss');
        return sessDataWrpcls;
    }
    
    public Class SessionDataWrapperClass{
        @AuraEnabled public String sessId{get;Set;}
        @AuraEnabled public Decimal sessSequence{get;Set;}
        @AuraEnabled public String  tchrId{get;set;}
        @AuraEnabled public String  tchrName{get;set;}
        @AuraEnabled public String  roomId{get;set;}
        @AuraEnabled public String  roomName{get;set;}
        @AuraEnabled public Date    stDate{get;set;}
        @AuraEnabled public String    stTime{get;set;}
        @AuraEnabled public String    sType{get;set;}
        @AuraEnabled public String    sException{get;set;}
        @AuraEnabled public Boolean    isTeacherNotAvailable{get;set;}
        @AuraEnabled public Boolean    isRoomNotAvailable{get;set;}
        @AuraEnabled public Decimal sessDuration{get;Set;}
        
        public SessionDataWrapperClass(){
            isTeacherNotAvailable = false;
            isRoomNotAvailable = false;
        } 
    }
}