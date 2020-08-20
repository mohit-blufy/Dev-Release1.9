/**
Name        :   ModuleLessonTriggerHelper
Date        :   14-07-20
Description :   This Class is a helper class of ModuleLessonTrigger
Dev         :   Asif
*/
public  class ModuleLessonTriggerHelper {
    
    public static void fillDuration(List<Module_Lesson__c> moduleLessonList){
        Set<Id>lessonIds = new Set<Id>();
        Map<Id,Lesson__c> lessonMap = new Map<Id,Lesson__c>();
        if(moduleLessonList.size() > 0){
            for(Module_Lesson__c mObj : moduleLessonList){
                lessonIds.add(mObj.Lesson__c);
            }                        
            List<Lesson__c> lessonList  = LessonService.getById(lessonIds);
            if(lessonList.size() > 0){
                for(Lesson__c lessObj : lessonList){
                    lessonMap.put(lessObj.Id, lessObj);
                }
                for(Module_Lesson__c mObj : moduleLessonList){
                    mObj.Duration__c = lessonMap.get(mObj.Lesson__c).Duration__c;
                }
            }
        }
    }
}