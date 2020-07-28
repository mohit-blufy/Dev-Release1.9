public class EnrollmentService {
    
    public static List<Enrollment__c> getById(Set<Id> Ids){
        if(!Ids.isEmpty()){
            try {
                List<Enrollment__c> objectList = new List<Enrollment__c>();
                for(Enrollment__c Obj : [SELECT Id,Name,Start_Date__c,Enrollment_End_Date__c,Class__r.Days_of_Week__c,Class__r.Course__c,Class__r.Exclude_Public_Holidays__c,
                                         (SELECT Id,Amount__c,Invoice__c,Type__c,Fee__r.Frequency__c,Fee__r.Schedule__c,Fee__r.Type__c 
                                          FROM Invoice_Line_Items__r 
                                          WHERE Fee__r.Type__c=:ConstantClass.tutionFeeType)
                                         FROM Enrollment__c 
                                         WHERE Id IN: Ids AND Class__r.Days_of_Week__c != null AND Start_Date__c != null 
                                         AND Enrollment_End_Date__c != null WITH SECURITY_ENFORCED]){
                                             objectList.add(Obj);
                                         }
                return objectList;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Enrollment__c> getEnrollmentRelatedObjectsById(Set<String> setEnrolmentId){
        if(!setEnrolmentId.isEmpty()){
            try {
                List<Enrollment__c> listEnrollment = [SELECT Id,Name,Type__c,Start_Date__c,Class__r.Type__c,Class__r.Frequency__c,Class__r.Advance_Billing__c,
                                                      Class__r.Advance_Billing_Unit__c,Parent__c ,Enrollment_Date__c,Class__r.Location__c,
                                                      (SELECT Id,Invoice__c,Type__c,Fee__c,Fee__r.Frequency__c,Fee__r.Schedule__c,Fee__r.Type__c 
                                                       FROM Invoice_Line_Items__r WHERE Fee__r.Type__c =: ConstantClass.tutionFeeType),
                                                      (SELECT Id,Session__c,Session__r.Class_Term__c,Status__c,
                                                       Session__r.Class_Term__r.Start_Date__c
                                                       FROM Student_Sessions__r)
                                                      FROM Enrollment__c WHERE Id IN: setEnrolmentId WITH SECURITY_ENFORCED];
                return listEnrollment;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
}
