/**
Name        :   TeacherWorkingHoursService
Date        :   10 JULY 2020
Description :   This class is use for to perform DML operation on Teacher_Working_Hours__c Object
*/
public class TeacherWorkingHoursService {
    /**
    Name        :  insertTeacherWorkingHours
    Date        :  10-07-20
    Description :  This function is use for to insert Teacher_Working_Hours__c records
    Dev         :  Asif
    */
    public static void insertTeacherWorkingHours(List<Teacher_Working_Hours__c> teacherWorkingHoursList){
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
}