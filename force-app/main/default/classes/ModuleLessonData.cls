public  class ModuleLessonData extends Entity {
    private Boolean isAccessible;
    private Set<String> fieldsApiName = new Set<String>{'Duration__c', 'Lesson__c','Lesson_Name__c', 'Module__c', 'Sequence__c'};
    private String objectApiName = 'Module_Lesson__c';
    public ModuleLessonData() {
        isAccessible = FieldPremissionCrudUtility.checkReadPermission(objectApiName, fieldsApiName,false); 
    }
    public list<Module_Lesson__c> getModuleLessons(Set<Id> moduleIds){
        try{
            list<Module_Lesson__c	> modLessonList = new list<Module_Lesson__c	>();
            for(Module_Lesson__c moduleLesObj : [SELECT Id, Name, Duration__c, Lesson__c,
                                                                 Lesson_Name__c, Module__c, Sequence__c
                                                                 FROM Module_Lesson__c WHERE Module__c IN: moduleIds 
                                                                  WITH SECURITY_ENFORCED]){
                     
                modLessonList.add(moduleLesObj);
            }
            return modLessonList;
        }catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
    // public list<ModuleLesson> getModuleLessons(Set<Id> moduleIds, Integer sequence){
    //     if(moduleIds.size() > 0 && isAccessible){
    //         list<ModuleLesson> modLessonList = new list<ModuleLesson>();
    //         for(Module_Lesson__c moduleLesObj : [SELECT Id, Name, Duration__c, Lesson__c,
    //                                                      Lesson_Name__c, Module__c, Sequence__c
    //                                                      FROM Module_Lesson__c WHERE Module__c IN: moduleIds 
    //                                                      AND  Sequence__c <=: sequence]){
             
    //             modLessonList.add(setModuleLessonData(moduleLesObj));
    //         }
    //         return modLessonList;
    //     }
    //     return null;
    // }

    // private ModuleLesson setModuleLessonData(Module_Lesson__c modulLessonObj){
    //     ModuleLesson modLessonObj = new ModuleLesson();
    //     modLessonObj.Id = modulLessonObj.Id;
    //     modLessonObj.Name = modulLessonObj.Name;
    //     modLessonObj.LessonId = modulLessonObj.Lesson__c;
    //     modLessonObj.LessonName = modulLessonObj.Lesson_Name__c;
    //     modLessonObj.ModuleId = modulLessonObj.Module__c;
    //     modLessonObj.Duration = modulLessonObj.Duration__c;
    //     modLessonObj.Sequence =modulLessonObj.Sequence__c;
    //     return modLessonObj;
    // }
}