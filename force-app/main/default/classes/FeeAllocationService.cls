public class FeeAllocationService {

    public static List<Fee_Allocation__c>  insertRecords(List<Fee_Allocation__c> obList){
        if(obList.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                    AccessType.CREATABLE, obList, true);

            try {
                insert securityDecision.getRecords();  
                return securityDecision.getRecords();
            } catch (Exception e) {
                System.debug('Error->'+e.getMessage());
            }
                    
        }
        return null;
    }
}