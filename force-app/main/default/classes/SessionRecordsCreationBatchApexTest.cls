@isTest
public class SessionRecordsCreationBatchApexTest {
    
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    @isTest
    static void test1(){
        Account teacherObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Teacher' LIMIT 1];
        
        Class__c classObj = [SELECT Id,Type__c,Frequency__c,Last_Session_Date__c,Last_Session_Scheduled_Date__c,Next_Schedule_Date__c
                             ,Last_Scheduled_ClassTerm__c
                             FROM Class__c LIMIT 1];
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(classObj.Id,Time.newInstance(10,30,00,00),120);
        insert clsSess;
        
        Session__c sessionObj = [SELECT Id FROM Session__c LIMIT 1];
        sessionObj.Sequence__c = 1;
        sessionObj.Class__c = classObj.Id;
        update sessionObj;
        
        classObj.Type__c = ConstantClass.ongoingClsType;
        classObj.Frequency__c = ConstantClass.monthlyFrequency;
        classObj.Last_Session_Date__c = System.today().addMonths(2);
        classObj.Last_Session_Scheduled_Date__c = System.today();
        classObj.Next_Schedule_Date__c = system.today();
        classObj.Advance_Scheduling__c = 3;
        classObj.Advance_Scheduling_Unit__c = 'Month(s)';
        classObj.Auto_Schedule__c = true;
        classObj.Teacher__c = teacherObj.Id;
        classObj.Days_of_Week__c = 'Mon';
        update classObj;
        
        Test.startTest();
        SessionRecordsCreationBatchApex obj = new SessionRecordsCreationBatchApex();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Class__c classOb = [SELECT Id,Last_Session_Scheduled_Date__c FROM Class__c WHERE Id =:classObj.Id]; 
        System.assertEquals(System.today(),classOb.Last_Session_Scheduled_Date__c);
        
    }
    
     @isTest
    static void test2(){
        Account teacherObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Teacher' LIMIT 1];
        
        Class__c classObj = [SELECT Id,Type__c,Frequency__c,Last_Session_Date__c,Last_Session_Scheduled_Date__c,Next_Schedule_Date__c
                             FROM Class__c LIMIT 1];
        
        Session__c sessionObj = [SELECT Id FROM Session__c LIMIT 1];
        sessionObj.Sequence__c = 1;
        sessionObj.Class__c = classObj.Id;
        update sessionObj;
        
        classObj.Type__c = ConstantClass.ongoingClsType;
        classObj.Frequency__c = ConstantClass.monthlyFrequency;
        classObj.Last_Session_Date__c = System.today().addMonths(2);
        classObj.Last_Session_Scheduled_Date__c = System.today();
        classObj.Next_Schedule_Date__c = system.today();
        classObj.Advance_Scheduling__c = 3;
        classObj.Advance_Scheduling_Unit__c = 'Month(s)';
        classObj.Auto_Schedule__c = true;
        classObj.Teacher__c = teacherObj.Id;
        //classObj.Days_of_Week__c = 'Mon';
        update classObj;
        
        Test.startTest();
        SessionRecordsCreationBatchApex obj = new SessionRecordsCreationBatchApex();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Class__c classOb = [SELECT Id,Type__c FROM Class__c WHERE Id =:classObj.Id]; 
        System.assertEquals(ConstantClass.ongoingClsType,classOb.Type__c);
        
    }
}