/**
Name        :   ModuleLessonTriggerHelper
Date        :   14-07-20
Description :   This Class is a helper class of ModuleLessonTrigger
*/
public  class ModuleLessonTriggerHelper {
    
    public void fillDuration(List<Module_Lesson__c> moduleLessonList){
        Set<Id>lessonIds = new Set<Id>();
        if(moduleLessonList.size() > 0){
            for(Module_Lesson__c mObj : moduleLessonList){
                lessonIds.add(mObj.Lesson__c);
            }
            LessonService lessonObj = new LessonService();
            Map<Id,Lesson__c> lessonMap  = lessonObj.getLessonInMap(lessonIds);
            if(lessonMap.size() > 0){
                for(Module_Lesson__c mObj : moduleLessonList){
                    mObj.Duration__c = lessonMap.get(mObj.Lesson__c).Duration__c;
                }
            }
        }
    }
}
