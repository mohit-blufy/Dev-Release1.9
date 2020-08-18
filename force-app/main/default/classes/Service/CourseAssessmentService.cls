public  class CourseAssessmentService {
    
    public static List<Course_Assessment__c> getByCourseId(Set<String> courseId){
        if(courseId.size() > 0){
            try{
                return [SELECT Name,Course__c 
                FROM Course_Assessment__c 
                WHERE Course__c IN: courseId
                WITH SECURITY_ENFORCED];
            }catch(System.QueryException e){
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
}
