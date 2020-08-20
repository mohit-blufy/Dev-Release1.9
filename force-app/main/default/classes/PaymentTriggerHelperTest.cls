@isTest
public class PaymentTriggerHelperTest {
		
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    static testmethod void validatePaymentTriggerHelper(){
        
        Account studentObj  = [Select Name from Account where recordtypeid =: ConstantClass.stuCustomerRecordTypeId Limit 1];
        
        Payment__c paymnt = [SELECT Id,Amount__c,Status__c,Type__c,Invoice__c,Enrollment__c,Parent__c
                            FROM Payment__c LIMIT 1];
        
		Invoice__c invoiceObj = BlufyTestUtil.createInvoice(studentObj.Id,ConstantClass.paidStatus,Date.today());
        insert invoiceObj;   
        
        Invoice_Line_Item__c invLinItm = BlufyTestUtil.createInvoiceLineItem(invoiceObj.Id,null,
                                                                             ConstantClass.depositFeeType,100);
        insert invLinItm;
        
        paymnt.Invoice__c = invoiceObj.Id;
        update paymnt;
        
        Test.startTest();
        system.assertEquals(200,paymnt.Amount__c);
        Test.stopTest();
        
    }
}