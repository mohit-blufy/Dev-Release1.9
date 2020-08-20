public class AccountService {
    
    public static List<Account> getEnrollmentByParentIdAlongWithEnrolId(String accId,String enrolId){
        if(String.isNotBlank(accId)){
            try {
                List<Account> listAccount = [SELECT Id,(SELECT Id FROM Enrollments1__r 
                                                        WHERE Status__c =: ConstantClass.enrolledStatus
                                                        AND Id !=: enrolId)
                                             FROM Account WHERE Id =: accId WITH SECURITY_ENFORCED];
                return listAccount;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    
    public static List<Account> getCorporateOrCustomerById(String accId,Boolean isCorporateAccount){
        if(String.isNotBlank(accId)){
            try {
                List<Account> listAccount = new List<Account>();
                if(isCorporateAccount){
                    listAccount = [SELECT Id, Name, PersonEmail FROM Account WHERE Id=:accId WITH SECURITY_ENFORCED LIMIT 1];
                }
                else{
                    listAccount = [SELECT Id,FirstName, LastName, PersonEmail, Phone, Block__c, Unit__c, BillingStreet,
                                   BillingPostalCode, BillingCountry, Gender__c, PersonBirthDate, Relationship_with_contact__c
                                   FROM Account WHERE Id=:accId WITH SECURITY_ENFORCED LIMIT 1];
                    
                }
                return listAccount;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
    public static List<Account> getByTeacherRecTypeId(){
        try {
            return [SELECT Id, Name FROM Account 
                    WHERE recordtype.Id =: ConstantClass.teacherRecordTypeId
                    AND Teacher_user__c =: UserInfo.getUserId()
                   WITH SECURITY_ENFORCED];
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return null;
    }
    
    public static List<Account> getByTeacherLocationId(Set<Id> teacherLocationIds){
        try {
            return [SELECT Id,Name FROM Account 
                     WHERE recordtype.Id =: ConstantClass.locationRecordsTypeId 
                     AND Id IN: teacherLocationIds
                    WITH SECURITY_ENFORCED];
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return null;
    }
    
    public static List<Account> getByLocationRecTypeId(){
        try {
            return [SELECT Id,Name FROM Account 
                    WHERE recordtype.Id =: ConstantClass.locationRecordsTypeId
                    WITH SECURITY_ENFORCED];
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return null;
    }
}