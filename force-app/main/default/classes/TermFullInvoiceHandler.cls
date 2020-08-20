/*
	Name		:	TermFullInvoiceHandler
	Date		:	24th March 2020
	Author		:	Arpit vijayvergiya
	Description	:	This class has the business logic for invoice line item creation , when we are charging for the full term.
*/
public class TermFullInvoiceHandler extends iBlufyInvoiceEngine {
    //public Subscription_Line_Item__c objLineItem;
    public TermFullInvoiceHandler(Subscription_Line_Item__c objLineItem){
        super.objLineItem = objLineItem;
    }
    
    public override List<Invoice_Line_Item__c> createInvoiceLineItems(Invoice__c objInv,LineItemCalculateWrapper objWrap){
        List<Invoice_Line_Item__c> listOfLineItems = new List<Invoice_Line_Item__c>();
        
        Decimal amount = objLineItem.Class_Term__r.Sessions__c * objLineItem.Fee__r.Unit_Price__c;
        Invoice_Line_Item__c objInvoiceItem =   InvoiceFactory.createInvLineItem(objLineItem,'Fee',amount,objInv.id);
        listOfLineItems.add(objInvoiceItem);
        
        If(objWrap.mapOfClassTerm.containsKey(objLineItem.Enrollment__r.class__c)){
            List<Class_Term__c> listOfTerms = objWrap.mapOfClassTerm.get(objLineItem.Enrollment__r.class__c);
            System.debug('listOfTerms '+listOfTerms);
            if(listOfTerms.size() > 0){
                for(Class_term__c objTerm : listOfTerms){
                    // check if any class term is available which has class term start date and sequence greater the
                    // to current class term of subscription line item, if found set new one and next bill date accoridingly 
                    // else set next bill date and class term null on the subscription line item.
                    // 
                    if(objTerm.Start_Date__c!= NULL && objTerm.Start_Date__c > objLineItem.Class_Term__r.Start_Date__c && 
                       objTerm.Sequence__c > objLineItem.Class_Term__r.Sequence__c ){
                           System.debug('effective term '+objTerm);
                           objLineItem.put(ConstantClass.nameSpace+'Class_Term__c',objTerm.Id);
                           //objLineItem.Class_Term__c = objTerm.Id;
                           //System.debug('advance billing '+objTerm.Class__r.Advance_Billing__c);
                           Integer unit = (Integer)(-1*objTerm.Class__r.Advance_Billing__c);
                           String unitType = objTerm.Class__r.Advance_Billing_Unit__c;
                           //System.debug('unit '+unit);
                           //System.debug('unitType '+unitType);
                           Date nextDate = null;
                           if(unitType == 'Day(s)'){
                               nextDate = objTerm.Start_Date__c.addDays(unit);
                           }else if(unitType == 'Week(s)'){
                               unit *= 7;
                               nextDate = objTerm.Start_Date__c.addDays(unit);
                           }else if(unitType == 'Month(s)'){
                               nextDate = objTerm.Start_Date__c.addMonths(unit);
                           }
                           objLineItem.put(ConstantClass.nameSpace+'Next_Bill_Date__c',nextDate);
                           //objLineItem.Next_Bill_Date__c = nextDate;
                           break;
                       }else{
                           // set blank
                            objLineItem = InvoiceFactory.resetClassTermAndBillDate(objLineItem);
                       }
                }
            }else{
                // set blank
                objLineItem = InvoiceFactory.resetClassTermAndBillDate(objLineItem);
            }
        }else{
            //set blank
            objLineItem = InvoiceFactory.resetClassTermAndBillDate(objLineItem);
        }
        
        return listOfLineItems;
    }
}