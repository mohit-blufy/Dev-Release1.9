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
    
    public static List<Enrollment__c> getByIdForEnrolCancellation(String enrolId){
        if(String.isNotBlank(enrolId)){
            try {
                List<Enrollment__c> listEnrollment = [SELECT Id, Name,Status__c,Enrollment_End_Date__c,Reason_for_Cancellation__c,Cancellation_Date__c, 
                                                      Cancellation_Comments__c,Class__c,Parent__c,Class__r.Name,Class__r.Type__c,
                                                      Class__r.Frequency__c,
                                                      (SELECT Id,Amount__c FROM Invoice_Line_Items__r WHERE Type__c =: ConstantClass.depositFeeType),
                                                      (SELECT Id,Next_Bill_Date__c,Subscription__c,Fee__c,Fee__r.Unit_Price__c,
                                                       Subscription_Start_Date__c,Status__c
                                                       FROM Subscription_Line_Items__r WHERE Status__c =: ConstantClass.activeStatus)    
                                                      FROM Enrollment__c 
                                                      WHERE Id =: enrolId AND Status__c =: ConstantClass.enrolledStatus 
                                                      WITH SECURITY_ENFORCED LIMIT 1];
                return listEnrollment;
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
    
    public static List<Enrollment__c> getEnrollmentByIdForCancellation(String enrolId){
        if(String.isNotBlank(enrolId)){
            try {
                List<Enrollment__c> listEnrollment = [SELECT Id, Name,Status__c,Enrollment_End_Date__c,Reason_for_Cancellation__c,
                                                      Cancellation_Date__c,Cancellation_Comments__c,Class__c,Parent__c,
                                                      Class__r.Name,Class__r.Type__c,Class__r.Frequency__c,
                                                      (SELECT Id,Amount__c FROM Invoice_Line_Items__r 
                                                       WHERE Type__c =: ConstantClass.depositFeeType),
                                                      (SELECT Id,Next_Bill_Date__c,Subscription__c,Fee__c,Fee__r.Unit_Price__c,
                                                       Subscription_Start_Date__c,Status__c FROM Subscription_Line_Items__r 
                                                       WHERE Status__c =: ConstantClass.activeStatus)    
                                                      FROM Enrollment__c 
                                                      WHERE Id =: enrolId AND Status__c =: ConstantClass.enrolledStatus 
                                                      WITH SECURITY_ENFORCED LIMIT 1];
                return listEnrollment;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Enrollment__c> updateByList(List<Enrollment__c> enrollList){
        if(enrollList.size() > 0){
            try{
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE,enrollList,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Enrollemet Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }catch(Exception e) {
                System.debug('Error While saving enrollemet records'+e.getMessage());   
            }
        }
        return null;
    }
    
    public static List<SObject> updateBySObjectList(List<SObject> listSObject){
        if(listSObject.size() > 0){
            try{
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE,listSObject,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Enrollemet Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }catch(Exception e) {
                System.debug('Error While saving enrollemet records'+e.getMessage());   
            }
        }
        return null;
    }
    
}