/*
* Author : 
* created on : 25/06/2020
*
* Objects : Class__c, Course_Module__c, Course__c
* Description : This Batch Class is used to auto update module lesson on class object when Auto Update Module checkbox is checked.
*/

global with sharing class ClassAutoUpdateModuleBatchApex {/*implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',  
                                                                                   new Set<String>{'Id','Name','Auto_Update_Module__c','Starting_Module_Lesson__c','Current_Module_Lesson__c','Next_Module_Lesson__c'},false);
        Boolean isCourseModuleAccessible = FieldPremissionCrudUtility.checkReadPermission('Course_Module__c',  
                                                                                          new Set<String>{'Id','Name','Sequence__c'},false);
        Boolean isCourseAccessible = FieldPremissionCrudUtility.checkReadPermission('Course__c',  
                                                                                    new Set<String>{'Id','Name'},false);
        if(isCourseModuleAccessible && isClassAccessible && isCourseAccessible){
            // ****Retrieving Classes which having Auto Update Module checkbox is checked true**** //
            String query = 'SELECT Id,Name,Auto_Update_Module__c,Starting_Module_Lesson__c,Course__c,';
            query 		+= 'Current_Course_Module__c,Next_Module_Lesson__c FROM Class__c ';
            query 		+= 'WHERE Auto_Update_Module__c = true';
            return Database.getQueryLocator(query);
        }
        return null;
    }
    global void execute(Database.BatchableContext bc, List<Class__c> clsList){
        try{
            // ****Fetching all course's Id from class list**** //
            List<Id> crsIds = new List<Id>();
            for (Integer i=0; i < clsList.size(); i++){
                crsIds.add(clsList[i].Course__c);
            }
            
            // ****Retrieving Module Courses from the above course Ids**** //
            List<Course_Module__c> crsModuleList = [SELECT Id,Name,Sequence__c,Course__c from Course_Module__c where Course__c IN : crsIds ORDER BY Course__c,Sequence__c];
            // ****Used Map for storing Id and Sequence__c from Course Module object with corresponding Course Id**** //
            Map<Id,Map<Id,Integer>> crsModIdSeqMap = new Map<Id,Map<Id,Integer>>();
            Map<Id,Map<Integer,Id>> crsModSeqIdMap = new Map<Id,Map<Integer,Id>>();
            for (Course_Module__c crsModule : crsModuleList){
                //**** If Course Module is already defined in a course ****
                if(crsModIdSeqMap.containsKey(crsModule.Course__c)){
                    Map<Id,Integer> crsModuleMap = crsModIdSeqMap.get(crsModule.Course__c);
                    crsModuleMap.put(crsModule.Id, crsModule.Sequence__c.intValue());
                }
                //**** If initially Starting_Module_Lesson__c is not defined in class****
                else{
                    Map<Id,Integer> crsModuleMap = new Map<Id,Integer>();
                    crsModuleMap.put(crsModule.id,crsModule.Sequence__c.intValue());
                    crsModIdSeqMap.put(crsModule.Course__c,crsModuleMap);
                }
                if(crsModSeqIdMap.containsKey(crsModule.Course__c)){
                    Map<Integer,Id> crsModMap = crsModSeqIdMap.get(crsModule.Course__c);
                    crsModMap.put(crsModule.Sequence__c.intValue(), crsModule.Id);
                }
                else{
                    Map<Integer,Id> crsModMap = new Map<Integer,Id>();
                    crsModMap.put(crsModule.Sequence__c.intValue(),crsModule.id);
                    crsModSeqIdMap.put(crsModule.Course__c,crsModMap);
                }
            }
            
            for(Class__c cls : clsList){
                //**** If Current_Course_Module__c is defined in a class by the user****
                if(String.isNotBlank(cls.Current_Course_Module__c)){
                    //**** Retrieving defined Current_Course_Module__c field corresponding Sequence from Course_Module__c ****
                    Integer currentSeq = (crsModIdSeqMap.get(cls.Course__c)).get(cls.Current_Course_Module__c);
                    //**** If Starting_Module_Lesson__c, Current_Course_Module__c and Next_Module_Lesson__c is defined in a class  **** 
                    if((crsModSeqIdMap.get(cls.Course__c)).containsKey(currentSeq+1)){
                        cls.Current_Course_Module__c = (crsModSeqIdMap.get(cls.Course__c)).get(currentSeq+1);                    
                        cls.Next_Module_Lesson__c = (crsModSeqIdMap.get(cls.Course__c)).containsKey(currentSeq+2) ? (crsModSeqIdMap.get(cls.Course__c)).get(currentSeq+2) : null;
                    } else{
                        cls.Current_Course_Module__c = null; 
                        cls.Next_Module_Lesson__c    = null;
                    }
                    //**** If Starting_Module_Lesson__c and Current_Course_Module__c is not defined in class **** 
                } 
                if(String.isBlank(cls.Starting_Module_Lesson__c)) {
                    cls.Starting_Module_Lesson__c = (crsModSeqIdMap.get(cls.Course__c)).containsKey(1) ? (crsModSeqIdMap.get(cls.Course__c)).get(1) : null;
                    cls.Current_Course_Module__c  = (crsModSeqIdMap.get(cls.Course__c)).containsKey(1) ? (crsModSeqIdMap.get(cls.Course__c)).get(1) : null; 
                    cls.Next_Module_Lesson__c     = (crsModSeqIdMap.get(cls.Course__c)).containsKey(2) ? (crsModSeqIdMap.get(cls.Course__c)).get(2) : null;
                }
            } 
            if (clsList.size() > 0){
                update clsList;
            }	
        }
        catch(Exception e){
            System.debug('Error Message@@@'+e.getMessage());
            System.debug('Line Number@@@'+e.getLineNumber());
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
	}*/
}