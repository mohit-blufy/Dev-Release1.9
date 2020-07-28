public class ClassTermService {
    
    //Insertion of Class Term Records
    public static List<Class_Term__c> insertClassTermRecords(List<Class_Term__c> listClassTerm){
        try{
            if(listClassTerm.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listClassTerm,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Class Term Removed Fields-->'+securityDecision.getRemovedFields());
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
    
    //Updation of Class Term Records
    public static List<Class_Term__c> updateClassTermRecords(List<Class_Term__c> listClassTerm){
        try{
            if(listClassTerm.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listClassTerm,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Class Term  Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Class Term Error Message-->'+e.getMessage());
        }
        return null;
    }
}