public  class CourseModuleData extends Entity{
    private Boolean isAccessible;
    private Set<String> fieldsApiName = new Set<String>{'Course__c','Duration__c', 'Module__c', 'Sequence__c'};
    private String objectApiName = 'Course_Module__c';
    public CourseModuleData() {                          
        isAccessible = FieldPremissionCrudUtility.checkReadPermission(objectApiName,fieldsApiName,false);        
    }

    public List<Course_Module__c> getCourseModule(Set<Id> courseId){
        try{
            if(!courseId.isEmpty()){
                List<Course_Module__c> courseModList = new List<Course_Module__c>();
                for(Course_Module__c courseModuleObj : [SELECT Id, Name, Course__c,
                                                                Duration__c, Module__c, Sequence__c
                                                                FROM Course_Module__c WHERE Course__c IN:courseId WITH SECURITY_ENFORCED ]){
                    courseModList.add(courseModuleObj);
                }
                return courseModList;
            }
        }catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
    // public List<CourseModule> getCourseModule(String courseId){
    //     if(String.isNotBlank(courseId) && isAccessible){
    //         List<CourseModule> courseModList = new List<CourseModule>();
    //         for(Course_Module__c courseModuleObj : [SELECT Id, Name, Course__c,
    //                                                          Duration__c, Module__c, Sequence__c
    //                                                          FROM Course_Module__c WHERE Course__c =:courseId ]){
                
    //             courseModList.add(setCourseModule(courseModuleObj));                                 
    //         }
    //         return courseModList;
    //     }
    //     return null;
    // }
    // private CourseModule setCourseModule(Course_Module__c courseModuleObj){
    //     CourseModule coursObj = new CourseModule();
    //     coursObj.Id = courseModuleObj.Id;
    //     coursObj.Name = courseModuleObj.Name;
    //     coursObj.Duration = courseModuleObj.Duration__c;
    //     coursObj.Sequence = courseModuleObj.Sequence__c;
    //     coursObj.ModuleId = courseModuleObj.Module__c;
    //     coursObj.CourseId = courseModuleObj.Course__c; 
    //     return coursObj;
    // }
}