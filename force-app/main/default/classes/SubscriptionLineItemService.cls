public class SubscriptionLineItemService {
	
    //Insertion of Subscription Line Item Records
    public static List<Subscription_Line_Item__c> insertSubsLineItemRecords(List<Subscription_Line_Item__c> listSubsLineItem){
        try{
            if(listSubsLineItem.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listSubsLineItem,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Subscription Line Item Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Subscription Line Item Error Message-->'+e.getMessage());
        }
        return null;
    }
    
    //Updation of Subscription Line Item Records
    public static List<Subscription_Line_Item__c> updateSubsLineItemRecords(List<Subscription_Line_Item__c> listSubsLineItem){
        try{
            if(listSubsLineItem.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listSubsLineItem,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Subscription Line Item Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Subscription Line Item Error Message-->'+e.getMessage());
        }
        return null;
    }

}