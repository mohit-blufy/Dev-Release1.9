public class BlufyConfigService {
	
    public static List<Blufy_Config__mdt> getByDeveloperName(String developerName){
        if(String.isNotBlank(developerName)){
            try {
                List<Blufy_Config__mdt> listBlufyConfig = [SELECT Monthly_Invoice_Cycle__c FROM Blufy_Config__mdt WHERE DeveloperName =: developerName 
                                                    WITH SECURITY_ENFORCED];
                return listBlufyConfig;
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
}