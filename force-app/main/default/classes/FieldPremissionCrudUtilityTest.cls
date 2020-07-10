@isTest
public class FieldPremissionCrudUtilityTest {
    static testmethod void validateFiedlPremissionControllerMethod1() {
        Set<String> fieldsApiName = new Set<String>{'Sequence__c', 'Class__c', 'Session_Date__c', 'Start_Time__c', 'Status__c'};  		
        Boolean isAccessbile = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, true);
        System.assertEquals(true,isAccessbile);
    }
    static testmethod void validateFiedlPremissionControllerMethod2() {
        Set<String> fieldsApiName = new Set<String>{'Name','Sequence__c', 'Class__c', 'Session_Date__c', 'Start_Time__c', 'Status__c'};  		
        Boolean isAccessbile = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, true);
        System.assertEquals(false,isAccessbile);              
    }
}