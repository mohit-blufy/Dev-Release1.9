public class MonthlyFullInvoiceHandler extends iBlufyInvoiceEngine {
    
   // public Subscription_Line_Item__c objLineItem;
    public MonthlyFullInvoiceHandler(Subscription_Line_Item__c objLineItem){
        this.objLineItem = objLineItem;
    }
    
    public override List<Invoice_Line_Item__c> createInvoiceLineItems(Invoice__c objInv,LineItemCalculateWrapper objWrap){
        List<Invoice_Line_Item__c> listOfLineItems = new List<Invoice_Line_Item__c>();
        Integer noOfSession =0;
        List<Session__c> sessions = objWrap.mapOfClassSession.containsKey(objLineItem.Enrollment__r.Class__c) ?  
            						objWrap.mapOfClassSession.get(objLineItem.Enrollment__r.Class__c) : new List<Session__c>();
        
        if(objLineItem.Subscription_Start_Date__c != NULL && objLineItem.Subscription_Start_Date__c.month() == objLineItem.Next_Bill_Date__c.month() 
           && objLineItem.Subscription_Start_Date__c.year() == objLineItem.Next_Bill_Date__c.year()){
              System.debug('inside subscription is starting late in month');
               for(Session__c session : sessions){
                   if(session.session_Date__c >= objLineItem.Subscription_Start_Date__c ){
                       noOfSession+=1;
                   }
               }
           }else if(objLineItem.Subscription_Expiry_Date__c != NULL && objLineItem.Subscription_Expiry_Date__c.month() == objLineItem.Next_Bill_Date__c.month() 
                    && objLineItem.Subscription_Expiry_Date__c.year() == objLineItem.Next_Bill_Date__c.year()){
                		System.debug('inside subscription is ending in month');
                        for(Session__c session : sessions){
                            if(session.session_Date__c <= objLineItem.Subscription_Expiry_Date__c ){
                                noOfSession+=1;
                            }
               			} 
                        objLineItem.put('Status__c','InActive');
                        //objLineItem.Status__c = 'InActive';
                    }else{
                        noOfSession = sessions.size();
                    }
        	Decimal Amount = noOfSession * objLineItem.Fee__r.Unit_Price__c;
            Invoice_Line_Item__c objInvoiceItem = InvoiceFactory.createInvLineItem(objLineItem,'Fee',amount,objInv.id);  //new Invoice_Line_Item__c();
            listOfLineItems.add(objInvoiceItem);
        	
        	// set next bill date
        	objLineItem.put('Next_Bill_Date__c',objLineItem.Next_Bill_Date__c.addMonths(1));    
        //objLineItem.Next_Bill_Date__c = objLineItem.Next_Bill_Date__c.addMonths(1);
            return listOfLineItems;
    }
}