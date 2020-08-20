/**
Name        :   AccountTriggerHelper
Date        :   08-07-20
Description :   This class is a helper of account trigger

*/
public  class AccountTriggerHelper {
   /**
    Name        :   createTeacherWorkingHours
    Date        :   08-07-20
    Description :   insert teaacher working hours
    
    */
    public static void createTeacherWorkingHours(List<Account> accList){
        if(accList.size() > 0){          
            Map<Id,List<Location_Working_Hours__c>> locationHoursMap = new Map<Id,List<Location_Working_Hours__c>>();
            List<Teacher_Working_Hours__c> teacherWorkingHoursList = new List<Teacher_Working_Hours__c>();
            set<Id> accIds = new set<Id>();
            //getting the teacher recordType id
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Teacher').getRecordTypeId();

            for(Account accObj : accList){
                if(accObj.RecordTypeId == accRecordTypeId){                    
                    accIds.add(accObj.Location__c);
                }
            }
            
            if(accIds.size() > 0){                
                List<Location_Working_Hours__c> locationList = LocationWorkingHoursService.getByLocationId(accIds);
                if(locationList.size() > 0){
                    for(Location_Working_Hours__c locationObj : locationList){
                        List<Location_Working_Hours__c> hoursList = new List<Location_Working_Hours__c>();
                        if(locationHoursMap.containsKey(locationObj.Location__c)){                
                            hoursList = locationHoursMap.get(locationObj.Location__c);
                            hoursList.add(locationObj);
                            locationHoursMap.put(locationObj.Location__c, hoursList);
                        }else{
                            hoursList.add(locationObj);
                            locationHoursMap.put(locationObj.Location__c, hoursList);
                        }
                    }
                    for(Account accObj : accList){
                        if(accObj.RecordTypeId == accRecordTypeId){
                            List<Location_Working_Hours__c> locationHoursList = locationHoursMap.get(accObj.Location__c);
                            if(locationHoursList.size() > 0){
                                for(Location_Working_Hours__c lObj : locationHoursList){
                                    Teacher_Working_Hours__c tObj  = new Teacher_Working_Hours__c();
                                    tObj.Active__c = true;
                                    tObj.Location__c = accObj.Location__c;
                                    tObj.Teacher__c  = accObj.Id;
                                    tObj.Start_Time__c = lObj.Start_Time__c;
                                    tObj.End_Time__c = lObj.End_Time__c;
                                    tObj.Day__c = lObj.Day__c;
                                    teacherWorkingHoursList.add(tObj);
                                }
                            }
                        }
                    }
                    if(teacherWorkingHoursList.size() > 0){                        
                        TeacherWorkingHoursService.insertByList(teacherWorkingHoursList);                        
                    }
                }            
            }
        }
    }
}