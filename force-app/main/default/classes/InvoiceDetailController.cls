Public with sharing class InvoiceDetailController{
    public Invoice__c invoice{get;set;}
    public Payment__c payment{get;set;}
    public String paymentNo{get;set;}
    
    public InvoiceDetailController(){
        invoice = new Invoice__c();
        payment = new Payment__c();
        string invId = Apexpages.currentPage().getParameters().get('Id');
        
        List<Invoice__c> invList = [Select Id,Name,Due_Date__c,Invoice_Date__c,Customer__c,Customer__r.Name,Customer__r.Billingstreet,Customer__r.BillingCountry,Customer__r.BillingPostalcode,
                                    Customer__r.personEmail,Customer__r.personMobilePhone,Status__c,Remarks__c,Discount_Amount__c,Total_Amount__c,GST_Tax_Amount__c,
                                    Location__r.Name,Location__r.PersonEmail,Location__r.PersonMobilePhone,Location__r.Billingstreet,Location__r.BillingCity,
                                    Location__r.BillingState,Location__r.BillingPostalcode,Location__r.Phone, Location__r.Website,
                                    Total_Paid_Amount__c,Outstanding_Amount__c,(Select Id,Fee__r.Name,Amount__c,GST_Amount__c,Type__c,Enrollment__c, Enrollment__r.Student__r.Name from Invoice_Line_Items__r 
                                                                                WHERE Type__c !=: ConstantClass.discountType ORDER BY CreatedDate Asc), 
                                    (Select Id,Name,Status__c,createdDate,Amount__c From Payments__r)
                                    FROM Invoice__c 
                                    WHERE Id=:invId LIMIT 1];  
        if(invList.size()>0){
            if(invList[0].Total_Paid_Amount__c == NULL)
                invList[0].Total_Paid_Amount__c = 0;
            
            if(invList[0].Invoice_Line_Items__r.size() > 0){
                for(Invoice_Line_Item__c invItm : invList[0].Invoice_Line_Items__r){
                    if(invItm.GST_Amount__c == NULL)
                        invItm.GST_Amount__c = 0;
                }
            }
            invoice = invList[0];
        }       
    }
}