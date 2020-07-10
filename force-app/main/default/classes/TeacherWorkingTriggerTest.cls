/**
Name		: TeacherWorkingTriggerTest
Date		: 20 April 2020
Description :

*/
@isTest
public class TeacherWorkingTriggerTest {
    @testSetup
    private static  void createData() {
        Account objLocation =  new Account(Name = 'India', recordtypeid = ConstantClass.locationRecordsTypeId);
        insert objLocation;
        Account objTeacher = new Account(Lastname = 'Denail', recordtypeid = ConstantClass.teacherRecordTypeId, Location__c = objLocation.id);
        insert objTeacher;
        
        Teacher_Working_Hours__c objTeacherWorkHours = new Teacher_Working_Hours__c();
        objTeacherWorkHours.Location__c = objLocation.id;
        objTeacherWorkHours.Teacher__c = objTeacher.id;
        objTeacherWorkHours.Day__c = 'Mon;Tue;Wed';
        objTeacherWorkHours.Active__c = true;
        objTeacherWorkHours.Start_Time__c = Time.newInstance(10, 00, 00, 00);
        objTeacherWorkHours.End_Time__c = Time.newInstance(23, 00, 00, 00);
        insert objTeacherWorkHours;
        
        Teacher_Working_Hours__c objTeacherWorkHours2 = new Teacher_Working_Hours__c();
        objTeacherWorkHours2.Location__c = objLocation.id;
        objTeacherWorkHours2.Teacher__c = objTeacher.id;
        objTeacherWorkHours2.Day__c = 'Sun';
        objTeacherWorkHours2.Active__c = true;
        objTeacherWorkHours2.Start_Time__c = Time.newInstance(10, 00, 00, 00);
        objTeacherWorkHours2.End_Time__c = Time.newInstance(23, 00, 00, 00);
        insert objTeacherWorkHours2;
        
    }
    private static testMethod void TeacherWorkingInsertionTest(){
        List<Account> lstLocations = [Select id, lastName from Account where recordtypeid =:  ConstantClass.locationRecordsTypeId limit 1 ];
        List<Account> lstTeachers  = [Select id, lastName from Account where recordtypeid =:  ConstantClass.teacherRecordTypeId  limit 1 ];
        Teacher_Working_Hours__c objTeacherWorkHours = new Teacher_Working_Hours__c();
        objTeacherWorkHours.Location__c = lstLocations[0].id;
        objTeacherWorkHours.Teacher__c = lstTeachers[0].id;
        objTeacherWorkHours.Day__c = 'Mon;Tue;Sun';
        objTeacherWorkHours.Active__c = true;
        objTeacherWorkHours.Start_Time__c = Time.newInstance(10, 00, 00, 00);
        objTeacherWorkHours.End_Time__c = Time.newInstance(23, 00, 00, 00);
        try{
            insert objTeacherWorkHours;
        }catch (Exception e) { 
            System.debug('An error happened, as predicted!');
        }
        
        System.assertEquals(2,[SELECT ID FRoM Teacher_Working_Hours__c].size());
    }
    private static testMethod void TeacherWorkingUpdationTest(){
        List<Teacher_Working_Hours__c> lstToUpdate = new List<Teacher_Working_Hours__c>();
        List<Account> lstLocations = [Select id, lastName from Account where recordtypeid =:  ConstantClass.locationRecordsTypeId limit 1 ];
        List<Account> lstTeachers  = [Select id, lastName from Account where recordtypeid =:  ConstantClass.teacherRecordTypeId  limit 1 ];
        
        List<Teacher_Working_Hours__c>lstTeacherWoringHours = [SELECT Id, Location__c, Day__c, Teacher__c 
                                                               FROM Teacher_Working_Hours__c
                                                               WHERE Teacher__c In: lstTeachers AND
                                                               Location__C In: lstLocations And Active__c = true
                                                              ];
        for(Teacher_Working_Hours__c objRecord: lstTeacherWoringHours) {
            objRecord.day__c = 'Tue;Mon;Sun;Wed';
            lstToUpdate.add(objRecord);
        }
        try{
            update lstToUpdate;
        }catch (Exception e) { 
            System.debug('An error happened, as predicted!');
        }
        System.assertEquals(2,[SELECT ID FRoM Teacher_Working_Hours__c].size());
    }
    
}