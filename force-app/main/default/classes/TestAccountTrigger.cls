/**
    24-JULY-20 for AccountTrigger
*/
@isTest
public class TestAccountTrigger {
    @isTest  
    static void testTrigger(){
        BlufyTestUtil.init();
        List<Class__c> clsListObj = [Select Name from Class__c LIMIT 1];
        System.assertEquals(1, clsListObj.size());
        //List<Session__c>sessionList = [SELECT Id,Location__c, Teacher__c, Class__c, Session_Date__c,  Duration__c, type__c FROM Session__c];
        //SessionModuleHelper.insertSessionModule(sessionList);
    }
}