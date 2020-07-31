public class CourseDiscountService {
    
    public static List<Course_Discount__c> getCourseDiscountByCourseId(String courseId){
        try{
            return [SELECT Id, Name, Discount__c, Discount__r.Name, Discount__r.Days_Before_Class__c, Discount__r.Value__c, Discount__r.Override__c, Discount__r.Required__c,
                    Discount__r.Type__c, Discount__r.Format__c, Discount__r.Start_Date__c, Discount__r.End_Date__c 
                    FROM Course_Discount__c WHERE Course__c =:courseId AND Discount__r.Format__c != null  AND Discount__r.Global__c=False AND 
                    Discount__r.Active__c = True AND Discount__r.Value__c != null WITH SECURITY_ENFORCED];
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        }        
        return null; 
    }
}