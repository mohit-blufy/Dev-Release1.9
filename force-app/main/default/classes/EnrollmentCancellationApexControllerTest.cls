@isTest
public class EnrollmentCancellationApexControllerTest {
		
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    @isTest
    static void test1(){
        Account teacherObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Teacher' LIMIT 1];
        
        Class__c classObj = [SELECT Id,Type__c,Frequency__c,Last_Session_Date__c,Last_Session_Scheduled_Date__c,Next_Schedule_Date__c
                             FROM Class__c LIMIT 1];
        
        Enrollment__c enrolObj = [SELECT Id FROM Enrollment__c LIMIT 1];
        
        Student_Session__c stuSess = [SELECT Id FROM Student_Session__c LIMIT 1];
        
        Subscription__c subcrptnObj = [SELECT Id FROM Subscription__c LIMIT 1];
        
        Subscription_Line_Item__c subLinItmObj = [SELECT Id FROM Subscription_Line_Item__c LIMIT 1];
        
        Invoice_Line_Item__c invLinItm = [SELECT Id FROM Invoice_Line_Item__c LIMIT 1];
        
        //Credit_Note__c creditNote = [SELECT Id FROM Credit_Note__c LIMIT 1];
        
        Test.startTest();
        EnrollmentCancellationCmpApexController.WrapperClass wrpcls = EnrollmentCancellationCmpApexController.doInitApex(enrolObj.Id);
        EnrollmentCancellationCmpApexController.doProcessEnrolmentApex('Process Invoice',JSON.serialize(wrpcls));
        Test.stopTest();
        
        Enrollment__c enrolObj1 = [SELECT Id,Cancellation_Date__c FROM Enrollment__c WHERE Id =:enrolObj.Id];
        System.assertEquals(System.today(),enrolObj1.Cancellation_Date__c);
        
    }
    
     @isTest
    static void test11(){
        Account teacherObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Teacher' LIMIT 1];
        
        Class__c classObj = [SELECT Id,Type__c,Frequency__c,Last_Session_Date__c,Last_Session_Scheduled_Date__c,Next_Schedule_Date__c
                             FROM Class__c LIMIT 1];
        classObj.Type__c = ConstantClass.ongoingClsType;
        classObj.Frequency__c = ConstantClass.monthlyFrequency;
        classObj.Advance_Scheduling_Unit__c = ConstantClass.schedulingPicklistMonth;
        classObj.Advance_Scheduling__c = 2;
        update classObj;
        
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(classObj.Id,Time.newInstance(10,30,00,00),120);
        insert clsSess;
        
        Enrollment__c enrolObj = [SELECT Id FROM Enrollment__c LIMIT 1];
        
        
        Student_Session__c stuSess = [SELECT Id FROM Student_Session__c LIMIT 1];
        
        Subscription__c subcrptnObj = [SELECT Id FROM Subscription__c LIMIT 1];
        
        Subscription_Line_Item__c subLinItmObj = [SELECT Id FROM Subscription_Line_Item__c LIMIT 1];
        
        Invoice_Line_Item__c invLinItm = [SELECT Id FROM Invoice_Line_Item__c LIMIT 1];
        
        //Credit_Note__c creditNote = [SELECT Id FROM Credit_Note__c LIMIT 1];
        
        Test.startTest();
        EnrollmentCancellationCmpApexController.WrapperClass wrpcls = EnrollmentCancellationCmpApexController.doInitApex(enrolObj.Id);
        EnrollmentCancellationCmpApexController.doProcessEnrolmentApex('Process Invoice',JSON.serialize(wrpcls));
        Test.stopTest();
        
        Enrollment__c enrolObj1 = [SELECT Id,Enrollment_End_Date__c FROM Enrollment__c WHERE Id =:enrolObj.Id];
        System.assertEquals(System.today().addDays(30),enrolObj1.Enrollment_End_Date__c);
        
    }
    
    
}