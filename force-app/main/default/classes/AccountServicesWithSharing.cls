public with sharing class AccountServicesWithSharing {
    public AccountServicesWithSharing() {
        
    }
    
    public List<Account> getAccountRecords(){
        try {
            List<Account> act2 = [SELECT Id, Name, website 
                                  FROM Account WHERE Name like 'Asif' OR  Name like 'Blaze Comicss' WITH SECURITY_ENFORCED];
            if(act2.size() > 0){
                return act2;
            }
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        }
        return null;
    }
    public void insertAccountRecords(List<Account> newAccounts){
        // List<Account> newAccounts = new List<Account>();
        // Account a = new Account(Name='Asif');
        // Account b = new Account(Name='Blaze Comics', Rating='Warm');
        // newAccounts.add(a);
        // newAccounts.add(b);
        if(newAccounts.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.CREATABLE, newAccounts, true);
            
            // No exceptions are thrown and no rating is set
            insert securityDecision.getRecords();
            // return securityDecision.getRecords();
        }
        // return null;
    }
    
    public List<Account> updateAccountRecords(List<Account> accList){
        if(accList.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.UPDATABLE, accList, true);
            update securityDecision.getRecords();     
            return securityDecision.getRecords();        
        }
        return null;
        
        // try {
        //     List<Account> act2 = [SELECT Id, Name, website 
        //                 FROM Account WHERE Name like 'Asif' WITH SECURITY_ENFORCED];
        //     for(Account acObj : act2){
        //         accObj.website = 'https://www.google.com';
        //     }                
        //     update act2;
        // } catch (System.Query e) {
        //     System.debug(e.getMessage());
        // }
        
    }
    public void deleteAccountRecords(List<Account> accList){
        if(accList.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.CREATABLE, accList, true);
            //update securityDecision.getRecords();
            DELETE securityDecision.getRecords();
        }
        // try {
        //     List<Account> act2 = [SELECT Id, Name, website 
        //     FROM Account WHERE Name like 'Asif' WITH SECURITY_ENFORCED];
        //     Delete act2;
        // } catch (System.Query e) {
        //     System.debug(e.getMessage());
        // }        
    }
}