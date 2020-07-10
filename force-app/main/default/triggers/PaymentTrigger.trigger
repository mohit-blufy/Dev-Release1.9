/*
	Name		:	PaymentTrigger
	Date		:	04/20/2020
	Author		: 	Arpit vijayvergiya
	Description	:	

*/
trigger PaymentTrigger on Payment__c (after insert,after update,after delete, after undelete) {
    Set<String> setOfInvIds = new Set<String>();
    List<Payment__c> paymentList = trigger.isDelete ? trigger.old : trigger.new;
    Map<Id,Payment__c> oldMap = trigger.oldmap;
    
    for(Payment__c objPay : paymentList){
        if(oldMap != NULL && oldMap.get(objPay.id).invoice__c != objPay.Invoice__c){
        	// when trigger is update
            if(objPay.Invoice__c != NULL){
            	setOfInvIds.add(objPay.Invoice__c);
            }
            if(oldMap.get(objPay.id).invoice__c != NULL){
            	setOfInvIds.add(oldMap.get(objPay.id).invoice__c);    
            }
        }else if(objPay.Invoice__c != NULL){
            	setOfInvIds.add(objPay.Invoice__c);
        }
        
    }
    
    if(setOfInvIds.size()>0){
        PaymentTriggerHelper.amountRollUpOnInvoice(setOfInvIds);
    }
    
}