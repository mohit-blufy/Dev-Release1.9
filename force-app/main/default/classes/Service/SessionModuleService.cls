/**
Name        :   SessionModuleService 
Date        :   
Description :   This class is use for to perform DML operation on Session_Module__c Object
*/
public  class SessionModuleService {

    /**
    Name        :  insertSessonModuleRecords
    Date        : 
    Description :  This function is use for to insert Session_Module__c records
    Dev         :  Asif
    */	
    public static void insertSessonModuleRecords(List<Session_Module__c> sessionModuleList){
        if(sessionModuleList.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                    AccessType.CREATABLE, sessionModuleList, true);

            try {
                insert securityDecision.getRecords();  
            } catch (Exception e) {
                System.debug('Error->'+e.getMessage());
            }
                     
        }

    }
}
