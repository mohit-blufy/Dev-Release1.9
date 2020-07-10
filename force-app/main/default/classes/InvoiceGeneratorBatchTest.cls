/**
	Name 		: InvoiceGeneratorBatchTest
	Date 		: 8 April 2020
	Author		:
	Description :
*/
@isTest
public class InvoiceGeneratorBatchTest {
    @testSetup static void testDataSetup(){
       /* Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //Insert account(Location)
        Account accObj1 = new Account();
        accObj1.Name = 'india';
        insert accObj1;
        
        //Insert account(Customer)
        Account accObj = new Account();
        accObj.LastName = 'Test';
        accObj.Active__c = 'Yes';
        accObj.RecordTypeId = RecordTypeIdAccount;
        accObj.Location__c = accObj1.id;
        insert accObj;
        
        //Insert Course 
        Course__c courseObj = new Course__c();
        courseObj.Name = 'Test';
        courseObj.status__c = 'Active';
        Insert courseObj;
        
        //Insert Class
        Class__c classobj = new Class__c();
        classobj.Course__c = courseObj.id;
        //classobj.Location__c = accObj1.id;
        classobj.Type__c = 'Fixed';
        classobj.Frequency__c = 'One-time';
        Insert classobj;
        
        //Insert Class_Term 
        Class_Term__c clsTermObj = new Class_Term__c();
        clsTermObj.Name = 'test';
        clsTermObj.Class__c = classobj.id;
        clsTermObj.Sessions__c = 2;
        Insert clsTermObj;
        
        //insert fee 
       	Fee__c feeObj = new Fee__c();
        feeObj.Amount__c = 4000;
        feeObj.Unit_Price__c = 12000;
        feeObj.Type__c = '	Tuition Fee';
        Insert feeObj;
        
        //Insert Enrollment records
        Enrollment__c enrollObj = new Enrollment__c();
        enrollObj.Class__c = classobj.id;
        //enrollObj.Location__c = accObj1.id;
        enrollObj.Student__c = accObj.id;
        Insert enrollObj;
        
        //Insert Subscription
        Subscription__c subscriptionObj = new Subscription__c();
        subscriptionObj.Customer__c = accObj.id;
        subscriptionObj.Status__c = 'Active';
        subscriptionObj.Payment_Frequency__c = 'Term';
        Insert subscriptionObj;
        
        //Update Subscription
        subscriptionObj.id = 'a0J2v00001A0xCFEAZ';
        Update subscriptionObj;
        
        //Insert Subscription_Line_Items__r
        Subscription_Line_Item__c subLineItemObj = new Subscription_Line_Item__c();
        subLineItemObj.Subscription__c = subscriptionObj.id;
        subLineItemObj.Status__c = 'Active';
        subLineItemObj.Fee__c = feeObj.id;
        subLineItemObj.Next_Bill_Date__c = System.today();
        subLineItemObj.Class_Term__c = clsTermObj.id;
        subLineItemObj.Enrollment__c = enrollObj.id;
        
        Insert subLineItemObj;
    }
    @isTest static void InvoiceGeneratorBatchTest(){
        Test.startTest();
        InvoiceGeneratorBatch batchObj = new InvoiceGeneratorBatch(System.today(),'Month');
        Database.executeBatch(batchObj);
        Test.stopTest();
       
    } */
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
      
        Test.startTest();
        InvoiceGeneratorBatch batchObj = new InvoiceGeneratorBatch(System.today(),'Month');
        Database.executeBatch(batchObj);
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM Invoice__c]);
    }   
}