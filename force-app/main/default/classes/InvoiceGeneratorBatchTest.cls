/**
	Name 		: InvoiceGeneratorBatchTest
	Date 		: 8 April 2020
	Author		:
	Description :
*/
@isTest
public class InvoiceGeneratorBatchTest {
    @testSetup static void testDataSetup(){
        BlufyTestUtil.init();
    }
    private static testMethod void InvoiceGeneratorBatchTest() {
      
        Test.startTest();
        InvoiceGeneratorBatch batchObj = new InvoiceGeneratorBatch(System.today(),'Term');
        Database.executeBatch(batchObj);
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM Invoice__c]);
        
        
    }
    private static testMethod void InvoiceGeneratorBatchTest2() {
      	Subscription__c sub = [SELECT Id,Location__c,Customer__c,Payment_Frequency__c,Subscription_Start_Date__c,
                               Subscription_End_Date__c,Status__c
                               FROM Subscription__c WHERE Payment_Frequency__c = 'Monthly'];
        Test.startTest();
        MonthlyInvoiceScheduler sh1 = new MonthlyInvoiceScheduler();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);  
        InvoiceGeneratorBatch batchObj1 = new InvoiceGeneratorBatch(System.today(),'Monthly');
        Database.executeBatch(batchObj1);
        InvoiceFactory invFac = new InvoiceFactory(sub,date.today());
       // MonthlyFullInvoiceHandler mFullInv = new MonthlyFullInvoiceHandler()
        Test.stopTest();
        System.assertEquals('Monthly',sub.Payment_Frequency__c);
    }   
}