public class TermService {
    
    public static List<Term__c> getAllTerms(){  
        try{
            List<Term__c> listTerm = [SELECT Id,Name,Sessions__c,Start_Date__c,End_Date__c,Sequence__c 
                                      FROM Term__c 
                                      WHERE Sessions__c != null AND Start_Date__c != null AND 
                                      		End_Date__c != null AND Sequence__c != null 
                                      		AND Status__c=:ConstantClass.openStatus
                                      WITH SECURITY_ENFORCED
                                      ORDER By Sequence__c];
            return listTerm;  
        }catch (System.QueryException e){
            System.debug('TermService Error Message-->'+e.getMessage());
            return null; 
        }   
    }
}