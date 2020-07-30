/**
Name        :   LocationWorkingHoursService
Date        :   10 JULY 2020
Description :   This class is use for to perform DML operation on Location_Working_Hours__c Object
*/
public class LocationWorkingHoursService {
    
    /**
    getByLocationId on 10-07-20 get Location_Working_Hours__c  records based on location Ids
    */
    public static List<Location_Working_Hours__c> getByLocationId(set<Id> locationIds){
        if(locationIds.size() > 0){
            try{
                List<Location_Working_Hours__c> locationList = [SELECT Id, Name, Day__c,Start_Time__c,
                                                                End_Time__c, Active__c, Location__c 
                                                                FROM Location_Working_Hours__c 
                                                                WHERE Location__c IN: locationIds AND Active__c = true
                                                                WITH SECURITY_ENFORCED ];
                return locationList;
            } catch(System.QueryException e){
                System.debug(e.getMessage());
            }
        }
        return null;
    }
}