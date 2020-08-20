public class InvoiceService {
    
    public static List<Invoice__c> getInvoiceById(String invoiceId){ 
        try{
            List<Invoice__c> listInvoice = new List<Invoice__c>();
            if(String.isNotBlank(invoiceId)){
                listInvoice = [Select Id,Name,Due_Date__c,Invoice_Date__c,Customer__c,Customer__r.Name,
                               Customer__r.Billingstreet,Customer__r.BillingCountry,Customer__r.BillingPostalcode,
                               Customer__r.personEmail,Customer__r.personMobilePhone,Status__c,Remarks__c,
                               Discount_Amount__c,Total_Amount__c,GST_Tax_Amount__c,Location__r.Name,
                               Location__r.PersonEmail,Location__r.PersonMobilePhone,Location__r.Billingstreet,
                               Location__r.BillingCity,Location__r.BillingState,Location__r.BillingPostalcode,
                               Location__r.Phone, Location__r.Website,Total_Paid_Amount__c,Outstanding_Amount__c,
                               (Select Id,Fee__r.Name,Amount__c,GST_Amount__c,Type__c,Enrollment__c,
                                Enrollment__r.Student__r.Name from Invoice_Line_Items__r 
                                WHERE Type__c !=: ConstantClass.discountType ORDER BY CreatedDate Asc), 
                               (Select Id,Name,Status__c,createdDate,Amount__c From Payments__r)
                               FROM Invoice__c 
                               WHERE Id=: invoiceId WITH SECURITY_ENFORCED LIMIT 1];
            }
            return listInvoice;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    } 
    
    //Insertion of Invoice Records
    public static List<Invoice__c> insertInvoiceRecords(List<Invoice__c> listInvoice){
        try{
            if(listInvoice.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listInvoice,true);
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
    
    //Updation of Invoice Records
    public static List<Invoice__c> updateInvoiceRecords(List<Invoice__c> listInvoice){
        try{
            if(listInvoice.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listInvoice,true);
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
    
    //Dynamic query for SObjects
    public static List<SObject> getExecutedQueryRecords(String query){
        try{
            if(String.isNotBlank(query)){
                List<SObject> listSObject = Database.query(query);
                return listSObject;
            }  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
}