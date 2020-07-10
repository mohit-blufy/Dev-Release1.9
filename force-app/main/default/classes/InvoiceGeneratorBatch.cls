/**
*   Name        :   InvoiceGeneratorBatch
*   Date        :   03/23/2020
*   Author      :   Arpit vijayvergiya
*   Description :   This Batch is used to create Invoice & InvoiceLineItems with the help of Subscription and SubscriptionLineItem records.
*
**/
global with sharing class InvoiceGeneratorBatch implements Database.Batchable<sObject>{
    
    private Date nextBillDate;
    private String type;
    private String monthCycle;
    private Boolean isInvoiceAccessible;
    private Boolean isSubscriptionLineItemAccessible;
    private Boolean isInvoiceLineItemAccessible;
    private Boolean isCreditNoteAccessible;
    private Boolean isPaymentAccessible;
    Set<String> invoicefieldsName;
    Set<String> subscriptionLineItemfieldsName;
    Set<String> invoiceLineItemfieldsName;
    // use this constructor if we want to execute on a date base and Term base,
    global InvoiceGeneratorBatch(Date executionDate, String type){
        Boolean isBlufyConfigAccessible = FieldPremissionCrudUtility.checkReadPermission('Blufy_Config__mdt',  
                                                                                                new Set<String>{'Id','Monthly_Invoice_Cycle__c'},false);
        if(isBlufyConfigAccessible){
            nextBillDate = executionDate;
            this.type = type;
            if(type == 'Month'){
                List<Blufy_Config__mdt> systemConfig = [SELECT Monthly_Invoice_Cycle__c FROM Blufy_Config__mdt WHERE DeveloperName='Default'];
                if(systemConfig.size() > 0){
                    this.monthCycle = systemConfig[0].Monthly_Invoice_Cycle__c;
                }
            }
        }else{
            System.debug('Blufy Config Metadata not Accessible');
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id, Name, Location__c, Customer__c, Status__c, Amount__c, GST_Tax_Amount__c, Total_Amount__c, Next_Bill_Date__c,';
        query += 'Payment_Frequency__c,(SELECT Id, Name, Fee__c, Amount__c, Enrollment__c, Enrollment__r.class__c, Next_Bill_Date__c,'; 
        query += ' Status__c, Class_Term__r.End_Date__c, Class_Term__r.Sessions__c, Class_Term__r.Start_Date__c, Class_Term__r.Sequence__c';
        query += ',Fee__r.Unit_Price__c, Subscription_Start_Date__c, Subscription_Expiry_Date__c FROM Subscription_Line_Items__r WHERE Status__c = \'Active\'';
        if(this.type == 'Term'){
            query += ' AND next_bill_date__c = :nextBillDate';    
        }else if(this.type == 'Month' && String.isNotBlank(this.monthCycle)){
            query += ' AND next_bill_date__c = '+this.monthCycle;     
        }
        query += ') FROM Subscription__c where ';
        query += 'Status__c = \'Active\' AND Payment_Frequency__c != null';
        
        // query += ' AND ID = \'a0J2v00001AANYeEAP\'';
        
        System.debug('query '+query);
        
        return Database.getQueryLocator(query);
        
        
    }
    global void execute(Database.BatchableContext BC,list<Subscription__c> lstSubscriptions){
        
        List<InvoiceFactory> listOfInvoiceFactory = new List<InvoiceFactory>();
        Set<String> setOfClassIds = new Set<String>();
        Map<String, Invoice__c> mapOfSubInv  = new Map<String,Invoice__c>();
        List<Invoice_Line_Item__c> listofInvItems = new List<Invoice_Line_Item__c>();
        LineItemCalculateWrapper objWrap = new LineItemCalculateWrapper();
        List<Subscription_Line_Item__c> subsciptionLineItemsList = new List<Subscription_Line_Item__c>();
        Set<String> customerIds =  new Set<String>();
        Set<String> setOfUtilizedCreditNotes = new Set<String>();
        isInvoiceAccessible = false;
        isSubscriptionLineItemAccessible = false;
        isInvoiceLineItemAccessible = false;
        
        invoicefieldsName = new set<String>{'Subscription__c', 'Customer__c', 'Due_Date__c', 'Location__c', 'Invoice_Date__c', 'Status__c', 'Invoice_Type__c'};
            isInvoiceAccessible = FieldPremissionCrudUtility.checkReadPermission('Invoice__c',invoicefieldsName , true);
        if(isInvoiceAccessible){
            for(Subscription__c objSub : lstSubscriptions){
                InvoiceFactory objFactory = new InvoiceFactory(objSub,nextBillDate); //,nextTerm,currentMonthEndDate.addDays(1)
                customerIds.add(objSub.customer__c);
                listOfInvoiceFactory.add(objFactory);
                setOfClassIds.addAll(objFactory.setOFClassIds);
                mapOfSubInv.put(objSub.Id,objFactory.getInvoice());    
            }
            
            if(this.type == 'Term'){
                objWrap.mapOfClassTerm = InvoiceFactory.getClassTermMap(setOfClassIDs);
            }else if(this.type == 'Month' && String.isNotBlank(this.monthCycle)){
                objWrap.mapOfClassSession  = InvoiceFactory.getClassSessions(setOfClassIds,this.monthCycle); 
            }
            //Database.SaveResult[] result = Database.insert(mapOfSubInv.values(),false);
            
            INSERT mapOfSubInv.values();
        }
        subscriptionLineItemfieldsName = new Set<String>{'Fee__c','Amount__c', 'Enrollment__c', 'Class_term__c', 'Next_Bill_Date__c', 'Status__c', 'Subscription_Start_Date__c', 'Subscription_Expiry_Date__c'};
            invoiceLineItemfieldsName = new Set<String>{'Subscription_Line_Item__c', 'Enrollment__c', 'Fee__c', 'Type__c', 'Amount__c'};
                
                isSubscriptionLineItemAccessible = FieldPremissionCrudUtility.checkReadPermission('Subscription_Line_Item__c', subscriptionLineItemfieldsName, true);
        isInvoiceLineItemAccessible = FieldPremissionCrudUtility.checkReadPermission('Invoice_Line_Item__c', invoiceLineItemfieldsName, true);
        
        if(isSubscriptionLineItemAccessible && isInvoiceLineItemAccessible){
            for(InvoiceFactory objFactory : listOfInvoiceFactory){
                for(iBlufyInvoiceEngine invoiceEngine : objFactory.listOfInvoiceHandler){
                    listofInvItems.addAll(invoiceEngine.createInvoiceLineItems(mapOfSubInv.get(objFactory.objSub.id),objWrap));
                    subsciptionLineItemsList.add(invoiceEngine.objLineItem);
                }
            }
            
            INSERT listOfInvItems;
            
            UPDATE subsciptionLineItemsList;
        }
        
        
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}