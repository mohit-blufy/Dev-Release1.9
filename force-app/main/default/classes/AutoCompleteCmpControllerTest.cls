@isTest
public class AutoCompleteCmpControllerTest {
    public static testmethod void validateAutoCompleteCmpController(){
        Account customerObj = new Account(Salutation = 'Mr.', FirstName = 'Acc', LastName = 'Test', BillingStreet = 'Test',
                                          personEmail = 'Test@gmail.com', Phone = '1234567890', RecordTypeId =ConstantClass.customerRecTypeId, 
                                          Block__c = 'Qwe', Unit__c = '101', BillingPostalCode = '123456', BillingCountry = 'India');
        insert customerObj;
 
        Test.startTest();
        AutoCompleteCmpController.getRecords(customerObj.LastName, 'Account', 'Id', 'Name', Null, 1);
        System.assertEquals('Test',customerObj.LastName);
        Test.stopTest();
    }
}