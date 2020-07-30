/**
    24-JULY-20 for SessionModuleHelper
*/
@isTest
public class TestSessionModuleHelper {
    @isTest  
    static void testInsertModule(){
        BlufyTestUtil.init();
        List<Session__c>sessionList = [SELECT Id,Location__c, Teacher__c, Class__c, Session_Date__c,  Duration__c, type__c FROM Session__c];
        system.assert(sessionList.size() > 0, 'Falied to create session');
        SessionModuleHelper.insertSessionModule(sessionList);
    }
}
