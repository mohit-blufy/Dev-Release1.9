Public with sharing class InvoiceDetailController{
    public Invoice__c invoice{get;set;}
    public Payment__c payment{get;set;}
    public String paymentNo{get;set;}
    
    public InvoiceDetailController(){
        invoice = new Invoice__c();
        payment = new Payment__c();
        string invId = Apexpages.currentPage().getParameters().get('Id');
        
        List<Invoice__c> invList = InvoiceService.getInvoiceById(invId);  
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