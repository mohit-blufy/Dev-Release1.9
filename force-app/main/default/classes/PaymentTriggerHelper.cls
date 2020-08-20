/*
Name			:	PaymentTriggerHelper;
Date			:	04/20/2020
Author			:	Arpit vijayvergiya
Description		:

*/
public class PaymentTriggerHelper {
    public static void amountRollUpOnInvoice(Set<String> invIds){
        Map<String,Decimal> mapOfInvAmount = new Map<String,Decimal>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        
        for(AggregateResult result : PaymentService.getPaymentByAggResult(invIds)){
                                          String invId = (String)result.get(ConstantClass.nameSpace+'Invoice__c');
                                          String type = (String)result.get(ConstantClass.nameSpace+'Type__c');
                                          System.debug('type '+type);
                                          Decimal amount = (Decimal)result.get('totalAmount');
                                          string key =  type== 'Refund' ? invId+'-Refund' : invId+'-Paid';
                                          System.debug('key '+key);
                                          Decimal finalAmount =  mapOfInvAmount.containsKey(key) ? mapOfInvAmount.get(key)+amount : amount; 
                                          mapOfInvAmount.put(key,finalAmount);                                
                                      }
        
        for(String invId : invIds){
            Invoice__c objInv = new Invoice__c(Id= invId);
            Decimal  refundAmount = mapOfInvAmount.containsKey(invId+'-Refund') ? mapOfInvAmount.get(invId+'-Refund'): 0;
            Decimal paidAmount = mapOfInvAmount.containsKey(invId+'-Paid') ? mapOfInvAmount.get(invId+'-Paid'): 0;
            objInv.put(ConstantClass.nameSpace + 'Total_Paid_Amount__c',paidAmount);
            objInv.put(ConstantClass.nameSpace + 'Total_Refund_Amount__c',refundAmount);
            System.debug('objInv '+objInv);
            invoiceList.add(objInv); 
        }
        
        if(invoiceList.size() > 0){
            InvoiceService.updateInvoiceRecords(invoiceList);
        }   
    }
}