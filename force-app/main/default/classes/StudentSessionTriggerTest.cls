/**
*Name		: StudentSessionTriggerTest
*Date		: 20 April 2020
*Description :
*
**/
@isTest
public class StudentSessionTriggerTest {
    @testSetup
    private static  void createData() {
        BlufyTestUtil.init();
    }
    private static testMethod void studentSessionTriggerUpdation1(){
        list<Student_Session__c>lstStudentSession = [ SELECT Id, Status__c, Session__c, Enrollment__c FROM Student_Session__c];
        for(Student_Session__c objStudentSession : lstStudentSession){
            objStudentSession.Status__c = 'Attended';
        }
        update lstStudentSession;
        
        System.assertEquals(1,[SELECT Id FROM Student_Session__c WHERE Status__c = 'Attended'].size());
        
    }
    private static testMethod void studentSessionTriggerUpdation2(){
        list<Student_Session__c>lstStudentSession = [ SELECT Id, Status__c, Session__c, Enrollment__c FROM Student_Session__c];
        for(Student_Session__c objStudentSession : lstStudentSession){
            objStudentSession.Status__c = 'Canceled';
        }
        update lstStudentSession;
        
        System.assertEquals(1,[SELECT Id FROM Student_Session__c WHERE Status__c = 'Canceled'].size());
    }
    
}