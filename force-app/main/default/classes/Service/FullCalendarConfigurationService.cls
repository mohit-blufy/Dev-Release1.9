public class FullCalendarConfigurationService {
    public static List<Full_Calendar_Configuration__mdt> getMetadata(){       
        try {
            return [SELECT Mode_Button_Color__c, Scheduler_License_Key__c, Selected_Mode_Button_Color__c, 
                    Selected_View_Button_Color__c, View_Button_Color__c, Non_Business_Hours_Color__c, 
                    Modal_Header_Footer_Color__c, Business_Hours_Color__c, Calendar_Border_Color__c  
                    FROM Full_Calendar_Configuration__mdt  
                    WITH SECURITY_ENFORCED
                    LIMIT 1];           
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        }                
        return null;
    }
}
