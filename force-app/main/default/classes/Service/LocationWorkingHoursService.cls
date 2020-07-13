/**
Name        :   LocationWorkingHoursService
Date        :   10 JULY 2020
Description :   This class is use for to perform DML operation on Location_Working_Hours__c Object
*/
public class LocationWorkingHoursService {
    
    /**
    Name        :  getLocationWorkingHoursRecords
    Date        :  10-07-20
    Description :  This function is use for to get the Location_Working_Hours__c records based on location Ids
    Dev         :  Asif
    */
    public List<Location_Working_Hours__c> getLocationWorkingHoursRecords(set<Id> accIds){
        if(accIds.size() > 0){
            try{
                List<Location_Working_Hours__c> locationList = [SELECT Id,Location__c, Start_Time__c, 
                                                                End_Time__c,Day__c 
                                                                FROM Location_Working_Hours__c 
                                                                WHERE Location__c IN: accIds AND Active__c = true
                                                                WITH SECURITY_ENFORCED ];
                return locationList;
            } catch(System.QueryException e){
                System.debug(e.getMessage());
            }
        }
        return null;
    }
}