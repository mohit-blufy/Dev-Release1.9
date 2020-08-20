/*
* Author : 
* created on : 25/06/2020
*
* Objects : Class__c, Course_Module__c, Course__c
* Description : This Batch Class is used to auto update module lesson on class object when Auto Update Module checkbox is checked.
*/

global with sharing class ClassAutoUpdateModuleBatchApex implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        // ****Retrieving Classes which having Auto Update Module checkbox is checked true**** //
        String query = ' SELECT Id,Name,Auto_Update_Module__c,Starting_Module_Lesson__c,Course__c, ';
        query 		+= ' Current_Course_Module__c,Next_Module_Lesson__r.Sequence__c,Next_Module_Lesson__c FROM Class__c ';
        query 		+= ' WHERE Auto_Update_Module__c = true AND Next_Module_Lesson__c != NULL ';
        query       += ' AND Last_Session_Date__c = TODAY AND Current_Course_Module__c != NULL WITH SECURITY_ENFORCED ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Class__c> listClass){
        System.debug('listClass-->'+listClass);
        try{
            Map<String,Decimal> mapClassIdToNxtModSeq = new Map<String,Decimal>(); 
            Map<String,List<Course_Module__c>> mapCourseIdToCourseMod = new Map<String,List<Course_Module__c>>();
            List<Class__c> listClassToUpdate = new List<Class__c>();
            
            for(Class__c cls : listClass){
                mapCourseIdToCourseMod.put(cls.Course__c,null);
                mapClassIdToNxtModSeq.put(cls.Id,cls.Next_Module_Lesson__r.Sequence__c);
            }
            
            if(mapCourseIdToCourseMod.keySet().size() > 0){
                List<Course__c> listCourse = CourseService.getCourseById(mapCourseIdToCourseMod.keySet());
                if(listCourse.size() > 0){
                    for(Course__c course : listCourse){
                        if(mapCourseIdToCourseMod.containskey(course.Id) && course.Course_Modules__r.size() > 0){
                            mapCourseIdToCourseMod.put(course.Id,course.Course_Modules__r); 
                        }
                    }
                }
            }
            
            if(mapCourseIdToCourseMod.keySet().size() > 0 && mapClassIdToNxtModSeq.keySet().size() > 0){
                for(Class__c cls : listClass){
                    if(mapCourseIdToCourseMod.containsKey(cls.Course__c) && mapClassIdToNxtModSeq.containsKey(cls.Id)
                       && mapCourseIdToCourseMod.get(cls.Course__c) != NULL){
                           List<Course_Module__c> listCourseModule = mapCourseIdToCourseMod.get(cls.Course__c);
                           cls.Current_Course_Module__c = cls.Next_Module_Lesson__c;
                           cls.Next_Module_Lesson__c = null;
                           for(Course_Module__c courMod : listCourseModule){
                               if(mapClassIdToNxtModSeq.get(cls.Id) < courMod.Sequence__c){
                                   cls.Next_Module_Lesson__c = courMod.Id;
                                   break;
                               }
                           }
                           listClassToUpdate.add(cls);
                       }
                }
            }
                    System.debug('listClassToUpdate-->'+listClassToUpdate);

            if(listClassToUpdate.size() > 0){
                ClassService.updateClassRecords(listClassToUpdate);
            }
        }
        catch(Exception e){
            System.debug('Error Message@@@'+e.getMessage());
            System.debug('Line Number@@@'+e.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}