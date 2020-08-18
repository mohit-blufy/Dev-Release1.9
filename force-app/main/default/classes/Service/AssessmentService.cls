public  class AssessmentService {

    public static List<Assessment__c> insertRecords(List<Assessment__c> assessList){
        if(assessList.size() > 0){
            try {
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE,assessList,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Assessment Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                    return securityDecision.getRecords();
                }
            } catch (Exception e) {
                System.debug('Student Session Error Message-->'+e.getMessage());
            }        
        }
        return null;
    }
}
