public class SubscriptionService {
    
    public static List<Subscription__c> getClassSessionsByClssId(Set<String> setParentAccId){  
        try{
            List<Subscription__c> listSubscription = [SELECT Id, Location__c, Status__c, Payment_Frequency__c,Customer__c 
                                                      FROM Subscription__c WHERE Customer__c IN: setParentAccId AND 
                                                      Status__c =: ConstantClass.activeStatus AND Payment_Frequency__c != null
                                                      WITH SECURITY_ENFORCED];
            return listSubscription;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;    
    }
    
    //Upsertion of Subscription Records
    public static List<Subscription__c> upsertSubscriptionRecords(List<Subscription__c> listSubscription){
        try{
            if(listSubscription.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, listSubscription,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Subscription Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    upsert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Subscription Error Message-->'+e.getMessage());
        }
        return null;
    }
}