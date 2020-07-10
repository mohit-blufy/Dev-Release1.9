/**
Name		: LocationWorkingTriggerTest
Date		: 20 April 2020
Description :

*/
@isTest
public class LocationWorkingTriggerTest {
    
    
    @testSetup
    private static  void createData() {
        Account objLocation =  new Account(name = 'India', recordtypeid = ConstantClass.locationRecordsTypeId);
        insert objLocation;
        Location_Working_Hours__c locationObj = new Location_Working_Hours__c(location__c = objLocation.id, Day__c = 'Mon;Tue', Active__c = true,
                                                                              Start_Time__c = Time.newInstance(10, 00, 00, 00), 
                                                                              End_Time__c = Time.newInstance(23, 00, 00, 00) );
        insert locationObj;
        
        Location_Working_Hours__c locationObj2 = new Location_Working_Hours__c(location__c = objLocation.id, Day__c = 'Sat;Sun', Active__c = true,
                                                                               Start_Time__c = Time.newInstance(10, 00, 00, 00), 
                                                                               End_Time__c = Time.newInstance(23, 00, 00, 00) );
        insert locationObj2;
    }
    private static testMethod void locationWorkingInsertionTest(){
        List<Account> lstLocations = [Select id, lastName from Account  limit 1 ];
        
        Location_Working_Hours__c locationObj2 = new Location_Working_Hours__c(location__c = lstLocations[0].id, Day__c = 'Sat;Sun', Active__c = true,
                                                                               Start_Time__c = Time.newInstance(10, 00, 00, 00), 
                                                                               End_Time__c = Time.newInstance(23, 00, 00, 00) );
        
        
        try{
            database.saveresult result=database.insert(locationObj2);
            
        }catch (Exception e) { 
            System.debug('An error happened, as predicted!');
        }
        
        System.assertEquals(2,[SELECT ID FRoM Location_Working_Hours__c].size());
    }
    private static testMethod void locationWorkingUpdationTest(){
        List<Location_Working_Hours__c> lstToUpdate  = new List<Location_Working_Hours__c>();
        List<Account> lstLocations = [Select id, lastName from Account  limit 1 ];
        List<Location_Working_Hours__c> lstLocationHours = [SELECT Id, Name, Location__c, Day__c FROM Location_Working_Hours__c Where location__c in :lstLocations ];
        
        for(Location_Working_Hours__c objLocation :lstLocationHours) {
            objLocation.Day__c = 'Mon;Tue;Sun';
            lstToUpdate.add(objLocation);
        }
        try{
            update lstToUpdate;
        }catch (Exception e) { 
            System.debug('An error happened, as predicted!');
        }
        System.assertEquals(2,[SELECT ID FRoM Location_Working_Hours__c].size());
    }
}