/**
Name        :   CourseModuleService
Date        :   
Description :   This class is use for to perform DML operation on Course_Module__c Object
*/
public class CourseModuleService {
    
    /**
    Name        :  getCourseModule
    Date        :  
    Description :  This function is use for to get the Course_Module__c data based on courseId set Ids
    Dev         :  Asif
    */	
    public static List<Course_Module__c> getCourseModule(Set<Id> courseId){
        try{
            if(!courseId.isEmpty()){
                List<Course_Module__c> courseModList = new List<Course_Module__c>();
                for(Course_Module__c courseModuleObj : [SELECT Id, Name, Course__c,
                                                        Duration__c, Module__c, Sequence__c
                                                        FROM Course_Module__c WHERE Course__c IN:courseId
                                                        WITH SECURITY_ENFORCED ]){
                    courseModList.add(courseModuleObj);
                }
                return courseModList;
            }
        }catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
}
