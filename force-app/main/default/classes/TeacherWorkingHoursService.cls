/** 
Name        :   TeacherWorkingHoursService
Date        :   10 JULY 2020
Description :   This class is use for to perform DML operation on Teacher_Working_Hours__c Object
*/
public class TeacherWorkingHoursService {
    /**
    insertByList on  10-07-20  insert Teacher_Working_Hours__c records
    */
    public static void insertByList(List<Teacher_Working_Hours__c> teacherWorkingHoursList){
        if(teacherWorkingHoursList.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                    AccessType.CREATABLE, teacherWorkingHoursList, true);

            try {
                insert securityDecision.getRecords();  
            } catch (Exception e) {
                System.debug('Error->'+e.getMessage());
            }
                     
        }
    }
    /**
    getByLocationId on  24-07-20  get Teacher_Working_hours__c  records based on location Ids
    */
    public static List<Teacher_Working_Hours__c> getByLocationId(set<Id> locationIds){
        if(locationIds.size() > 0){
            try{
                List<Teacher_Working_Hours__c> teacherHurList = [SELECT Id, Start_time__c, End_time__c, 
                                                                Location__c, Teacher__c, Day__c
                                                                FROM Teacher_Working_Hours__c 
                                                                WHERE location__c IN: locationIds AND Active__c  = true
                                                                WITH SECURITY_ENFORCED ];
                return teacherHurList;
            } catch(System.QueryException e){
                System.debug(e.getMessage());
            }
        }
        return null;
    }
    
    public static List<Teacher_Working_Hours__c> getByTeacherId(set<String> setTeacherId){
        try{
            List<Teacher_Working_Hours__c> teacherHurList = [SELECT Id, Day__c, End_Time__c,
                                                             Start_Time__c, Active__c, Teacher__c, Location__c 
                                                             FROM Teacher_Working_Hours__c WHERE Active__c = true AND
                                                             Teacher__c IN: setTeacherId WITH SECURITY_ENFORCED];
            return teacherHurList;
        } catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }

    public static List<Teacher_Working_Hours__c>  getByLocationIdAndTeacherRecordsTypeId(set<String> locationIds){
        if(locationIds.size() > 0){
            try{
                List<Teacher_Working_Hours__c> teacherHurList = [SELECT Id, Teacher__r.id,
                                                                teacher__r.Name 
                                                                FROM Teacher_Working_Hours__c 
                                                                WHERE location__c IN: locationIds AND 
                                                                teacher__r.recordtype.Id =: ConstantClass.teacherRecordTypeId
                                                                WITH SECURITY_ENFORCED ];
                return teacherHurList;
            } catch(System.QueryException e){
                System.debug(e.getMessage());
            }
        }
        return null;
    }
}