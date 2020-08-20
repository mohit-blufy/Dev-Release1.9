public class InvoiceLineItemService {
    
    //Insertion of Invoice Line Item Records
    public static List<Invoice_Line_Item__c> insertInvoiceLineItemRecords(List<Invoice_Line_Item__c> listInvoiceLineItem){
        try{
            if(listInvoiceLineItem.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listInvoiceLineItem,true);
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
}