public class SessionModuleData extends Entity{
    private Boolean isAccessible;
    private Set<String> fieldsApiName = new Set<String>{'Module_Lesson__c','Session__c'};
    private String objectApiName = 'Session_Module__c';
    public SessionModuleData() {
        isAccessible = FieldPremissionCrudUtility.checkReadPermission(objectApiName,fieldsApiName,true);    
    }

    public void insertSessonModuleRecords(List<Session_Module__c> sessionModuleList){
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
    // public void insertSessonModuleRecords(List<SessionModule> sessionModuleList){
    //     if(sessionModuleList.size() > 0 && isAccessible){
    //         List<Session_Module__c> sessionModList = new List<Session_Module__c>();
    //         for(SessionModule sessionModObj : sessionModuleList){
    //             sessionModList.add(setSessionModule(sessionModObj));
    //         }
    //         if(sessionModList.size() > 0){
    //             try {
    //                 insert sessionModList;
    //             } catch (Exception ex) {
    //                 System.debug('Error while inserting records'+ ex.getMessage());
    //             }
    //         }
    //     }
    // }
    // private Session_Module__c setSessionModule(SessionModule sessObj){
    //     Session_Module__c sessionModuleObject = new Session_Module__c();
    //     sessionModuleObject.Module_Lesson__c = sessObj.ModuleLessonId;
    //     sessionModuleObject.Session__c = sessObj.SessionId;
    //     return sessionModuleObject;
    // } 
}