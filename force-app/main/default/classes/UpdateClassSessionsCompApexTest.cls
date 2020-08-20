@isTest
public class UpdateClassSessionsCompApexTest {
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    static testmethod void validateSessionTriggerHandler(){
        Class__c cls = [Select Name from Class__c];
        
        Session__c sessObj = [Select Name, Location__c, Teacher__c, Class__c, Session_Date__c, Start_Time__c, Exception__c,
                              Status__c, Duration__c, Type__c, Room__c, Teacher__r.Name, Room__r.Name, Sequence__c
                              from Session__c where Class__c =: cls.Id];
        sessObj.Sequence__c = 1;
        update sessObj;
        
        Class_Session__c clsSess = [SELECT Id,Class__c,Start_Time__c,Duration__c,Room__c,Teacher__c FROM Class_Session__c 
                                    WHERE Class__c =: cls.Id];
        
        Test.startTest();
        List<UpdateClassSessionsCompApex.SessionDataWrapperClass> sessWrapList = UpdateClassSessionsCompApex.doInitApex(cls.Id);
        UpdateClassSessionsCompApex.doSaveApex(JSON.serialize(sessWrapList));
        UpdateClassSessionsCompApex.checkTeacherRoomAvailability(JSON.serialize(sessWrapList[0]),'');
        UpdateClassSessionsCompApex.checkTeacherRoomAvailability(JSON.serialize(sessWrapList[0]),'Teacher');
        UpdateClassSessionsCompApex.checkTeacherRoomAvailability(JSON.serialize(sessWrapList[0]),'Room');
        UpdateClassSessionsCompApex.doInitApex('');
        SessionService.updateSessionRecords(null);
        SessionService.insertSessionRecords(null);
        SessionService.getById(null);
        System.assertEquals(1,sessObj.Sequence__c);
        Test.stopTest();
    }
}