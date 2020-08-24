/**
Name        :   UserInterfaceConfigService
Date        :   28 JULY 2020
Description :   This class is use for to get the User_Interface_Settings__mdt data
*/
public class UserInterfaceConfigService {

    /**
    getAssessmentData on 28-07-20 get User_Interface_Settings__mdt 
    */
    public static List<User_Interface_Settings__mdt> getAssessmentData(){
        try {
            List<User_Interface_Settings__mdt> userList = [SELECT MasterLabel, Active__c, Data_Type__c, 
                                                                Field_API_Name__c, Required__c,
                                                                Section__c, Type__c, Sequence__c,
                                                                Object_API_Name__c                                                                  
                                                                FROM User_Interface_Settings__mdt
                                                                WHERE Active__c = true
                                                                AND Section__c =: ConstantClass.section                                                               
                                                                WITH SECURITY_ENFORCED]; 
            return userList;
        } catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;                  
    }
}