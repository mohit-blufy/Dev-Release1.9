public class CourseService {
    
    public static List<Course__c> getCourseById(Set<String> setCourseId){
         try{
             List<Course__c> listCourse =  [SELECT Id, Name,(SELECT Id,Name,Duration__c, Module__c,Sequence__c
                                                             FROM Course_Modules__r ORDER BY Sequence__c)
                                            FROM Course__c WHERE Id IN: setCourseId WITH SECURITY_ENFORCED ];
             return listCourse;
        }catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }

}