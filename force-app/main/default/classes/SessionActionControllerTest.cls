/**
Name		: SessionActionControllerTest
Date		: 23 March 2020
Author		:
Description :
*/
@isTest
public class SessionActionControllerTest {
    
    @testSetup static void sessionActionSetup(){
        BlufyTestUtil.init();
        
    }
    @isTest static void fetchSessionsDetailTest(){
        
        List<Session__c> sessionList = [SELECT Id, Teacher__r.location__r.Name, Teacher__r.Name, Class__r.Name,Type__c, Duration__c,Session_date__c, Start_Time__c FROM Session__c];
        List<Session__c> sessionNewList = SessionActionController.fetchSessionsDetail(sessionList[0].id);
        System.assertEquals(sessionNewList[0].Session_date__c, sessionList[0].Session_date__c);
    }
    @isTest static void getSessionStudentTest(){
        
        List<Session__c> sessionList = [SELECT Id, Teacher__r.location__r.Name, Teacher__r.Name, Class__r.Name, Duration__c, Session_date__c, Start_Time__c FROM Session__c];
        List<Student_Session__c> studentReturnedList = [SELECT Id, Session__r.Teacher__r.Name, Account__r.Name, Session__r.Class__r.Name, Status__c, Notes__c FROM Student_Session__c WHERE Session__c =: sessionList[0].id];
        List<Student_Session__c> studentList = SessionActionController.getSessionStudent(sessionList[0].id);
        
        //changeStudentStatus method
        SessionActionController.changeStudentStatus(studentList[0].id, studentList[0].status__c);
        //cancelStudentForSession method
        SessionActionController.cancelStudentForSession(studentList[0].id);
        //getSessionHistoryRecords method 
        
        SessionActionController.getSessionHistoryRecords(sessionList[0].id);
        
        SessionActionController.cancelSession(sessionList[0].id);
        System.assertEquals(sessionList[0].Id, studentList[0].session__c);
    }
}