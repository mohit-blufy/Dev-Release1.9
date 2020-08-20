/**
Name        :   ModuleLessonService
Date        :  
Description :   This class is use for to perform DML operation on Module_Lesson__c Object
*/
public class ModuleLessonService {
    
    /**
    getModuleLessons  get the Module_Lesson__c data based on moduleIds set Ids    
    */	
    public static list<Module_Lesson__c> getByModuleId(Set<Id> moduleIds){
        try{
            if(!moduleIds.isEmpty()){
                list<Module_Lesson__c> modLessonList = new list<Module_Lesson__c	>();
                for(Module_Lesson__c moduleLesObj : [SELECT Id, Name, Duration__c, Lesson__c,
                                                    Lesson_Name__c, Module__c, Sequence__c
                                                    FROM Module_Lesson__c WHERE Module__c IN: moduleIds 
                                                    WITH SECURITY_ENFORCED]){
                        
                    modLessonList.add(moduleLesObj);
                }
                return modLessonList;
            }
        }catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
}