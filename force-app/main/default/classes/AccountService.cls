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
    
    //Upsertion of Class Records
    public static List<Account> upsertClassRecords(List<Account> listAccount){
        try{
            if(listAccount.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, listAccount,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Class Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    upsert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Class Error Message-->'+e.getMessage());
        }
        return null;
    }
}