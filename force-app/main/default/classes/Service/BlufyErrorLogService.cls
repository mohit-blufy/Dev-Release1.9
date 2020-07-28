public class BlufyErrorLogService {
    
    //Insertion of Student Session Term Records
    public static List<Blufy_Error_Log__c> insertBlufyErrorLogRecords(List<Blufy_Error_Log__c> listBlufyErrorLog){
        try{
            if(listBlufyErrorLog.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE,listBlufyErrorLog,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Error Message-->'+e.getMessage());
        }
        return null;
    }

}
