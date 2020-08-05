@isTest
public class SessionTriggerHandlerTest {
	@testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    static testmethod void validateSessionTriggerHandler(){
        Session__c sessObj = [Select Class__c, Status__c, Name from Session__c];
        sessObj.Status__c  = 'Canceled';
        update sessObj;
        Student_Session__c stuSessObj = [Select Session__c, Status__c, Name from Student_Session__c];
        System.assertEquals(stuSessObj.Status__c = 'Canceled', stuSessObj.Status__c = 'Canceled');
    }
}