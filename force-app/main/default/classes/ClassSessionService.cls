public class ClassSessionService {
    
    public static List<Class_Session__c> getClassSessionsByClssId(Set<String> setClassId){  
        try{
            List<Class_Session__c> listClassSession = [SELECT Id,Name,Duration__c,Start_Time__c,Class__c,Teacher__c,Room__c 
                                                       FROM Class_Session__c
                                                       WHERE Class__c IN: setClassId WITH SECURITY_ENFORCED 
                                                       ORDER BY Start_Time__c];
            return listClassSession;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;    
    }
    
}