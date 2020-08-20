@isTest
public class BlufyErrorLogServiceTest {
    static testmethod void  testDataSetup(){
        Blufy_Error_Log__c blufyErrLg = new Blufy_Error_Log__c();
        blufyErrLg.Process_Name__c= 'test session';
        blufyErrLg.Description__c= 'test session';
        blufyErrLg.Title__c= 'Test Creation';
        BlufyErrorLogService.insertBlufyErrorLogRecords(new List<Blufy_Error_Log__c>{blufyErrLg});
        system.assertEquals('Test Creation', blufyErrLg.Title__c);
    }
}