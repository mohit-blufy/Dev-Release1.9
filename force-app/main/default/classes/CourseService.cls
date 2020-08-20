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
    
    public static List<Course__c> getByStringQuery(String query){
        if(String.isNotBlank(query)){
            try{
                return Database.query(query+' WITH SECURITY_ENFORCED');
            }catch(Exception e){
                System.debug('Error while excute dynamic query in Course services '+e.getMessage());
            }
        }
        return null;
    }
    
    public static List<Course__c> getAllCourseWithActiveStatus(){
        try{
            List<Course__c> listCourse =  [select Id, Name  from Course__c WHERE Status__c =: ConstantClass.activeStatus 
                                           WITH SECURITY_ENFORCED ORDER BY Name];
            return listCourse;
        }catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
}