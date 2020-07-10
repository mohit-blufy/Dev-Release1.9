/*
Name            :   InvoiceFactory
Date            :   03/23/2020
Author          :   Arpit vijayvergiya
Description     :   This class acts as midileware which takes will decide right invoice handler.
*/
public class InvoiceFactory {
    /*
As per blufy model , a subscription can have multiple subscription line item so, each line item can fall down into different
Invoice handler.
*/
    public List<iBlufyInvoiceEngine> listOfInvoiceHandler;
    public Set<String> setOFClassIds;
    public Invoice__c objInv;
    public Subscription__c objSub;
    private Date executionDate;
    
    public InvoiceFactory (Subscription__c sub , Date executionDate/*, Term__c nextTerm, Date nextMonthStartDate*/){
        this.objSub = sub;
        this.executionDate = executionDate;
        listOfInvoiceHandler = new List<iBlufyInvoiceEngine>();
        setOFClassIds = new Set<String>();
        setInvoice(sub);    
        
        for(Subscription_Line_Item__c objLineItem : sub.Subscription_Line_Items__r){
            setOFClassIds.add(objLineItem.Enrollment__r.class__c);
            listOfInvoiceHandler.add(getHandler(sub.Payment_Frequency__c,objLineItem));
        } 
    }
    
    private IBlufyInvoiceEngine getHandler(String frequency, Subscription_Line_Item__c objLineItem){
        System.debug('frequency '+frequency);
        IBlufyInvoiceEngine handler;
        if(frequency == 'Term'){
            handler = new TermFullInvoiceHandler(objLineItem);
        }else if(frequency == 'Monthly'){
            handler = new MonthlyFullInvoiceHandler(objLineItem);
        }
        return handler;
    }
    
    public Invoice__c getInvoice(){
        return this.objInv;
    }
    
    
    
    
    /*
     * return sessions related to class and time limit
    *  timeLimit e.g. Next_Month, THIS_Month
    */
    public static Map<String,List<Session__c>> getClassSessions(Set<String> classIds, String timeLimit){
        Map<String,List<Session__c>> classSessionsMap = new Map<String,List<Session__c>>();
        String query = 'SELECT Id, Session_Date__c, Class__c FROM Session__c WHERE Session_Date__c ='+timeLimit +' AND Class__c =: classIds';
        for(Session__c objSession : Database.query(query)){
            List<Session__c> sessionsList = classSessionsMap.containsKey(objSession.Class__c) ? classSessionsMap.get(objSession.Class__c) : 
                                            new List<Session__c>();
            sessionsList.add(objSession);
            classSessionsMap.put(objSession.Class__c,sessionsList);            
        }
        return classSessionsMap;
    }
    
    
    /*
     * return class term map
    */
    
    public static Map<String,List<Class_Term__c>> getClassTermMap(Set<String> setOfClassIDs){
        System.debug('@@@setOfClassIDs'+setOfClassIDs);
        Map<String,List<Class_Term__c>> mapOfclassTerm = new Map<String,List<Class_Term__c>>();
        for(Class_Term__c objTerm : [SELECT Sessions__c, Sequence__c,Start_Date__c,Class__c, Class__r.Advance_Billing__c,
                                     Class__r.Advance_Billing_Unit__c 
                                     FROM Class_Term__c WHERE Class__c IN: setOfClassIDs  
                                     ORDER By Start_Date__c]){
            List<Class_Term__c> listOfTerm = mapOfClassTerm.containsKey(objTerm.Class__c) ? mapOfClassTerm.get(objTerm.Class__c) :
                                                new List<Class_Term__c>();
                                         listOfTerm.add(objTerm);
                                         mapOfClassTerm.put(objTerm.Class__c,listOfTerm);
       }
        
        return mapOfClassTerm;
    }
    
    //Util common methods
    public void setInvoice(Subscription__c sub){
        this.objInv = UtilityClass.fillInvoice(sub.Customer__c, sub.Location__c,sub.Id,'Recurring','Due');
        this.objInv.Invoice_Date__c = executionDate;//System.today();
        this.objInv.Due_Date__c = executionDate;//System.today();
    }
    
    public static Invoice_Line_Item__c createInvLineItem(Subscription_Line_Item__c objLineItem,String type,Decimal amount,String invId){
       Invoice_Line_Item__c objInvoiceItem = UtilityClass.fillInvLineItem(invId, objLineItem.Enrollment__c, objLineItem.id, 
                                                                          objLineItem.Fee__c, null,type, amount, true);
        /* Invoice_Line_Item__c objInvoiceItem = new Invoice_Line_Item__c(Subscription_Line_Item__c = objLineItem.id,
                                                                      Enrollment__c = objLineItem.Enrollment__c,
                                                                      Fee__c = objLineItem.Fee__c,Invoice__c = invId,
                                                                      Type__c = type,Amount__c = amount);*/
        
        return objInvoiceItem;
    }
    
    public static Subscription_Line_Item__c resetClassTermAndBillDate(Subscription_Line_Item__c objLineItem){
        objLineItem.put('Class_Term__c',NULL);
        objLineItem.put('Next_Bill_Date__c',NULL);
        return objLineItem;
    }
}