public class HolidayService {
    
    public static List<Holiday__c> getByDate(Date startDate, Date endDate){
        try{
            if(startDate != null && endDate != null){
                return [Select Id,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c 
                        FROM Holiday__c 
                        WHERE Start_Date__c != null AND (Start_Date__c >=: startDate AND End_Date__c <=: endDate) 
                        WITH SECURITY_ENFORCED];
            }
            else{
                return [Select Id,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c 
                        FROM Holiday__c 
                        WHERE Start_Date__c != null AND End_Date__c != NULL
                        WITH SECURITY_ENFORCED];
            }
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        }      
        return null;
    }
    //Added on 17-08-20 to get holiday by year
    public static List<Holiday__c> getByYear(Date startDate){
        if(startDate !=  null){
            try {
                return [SELECT Id, Start_Time__c, Start_Date__c, 
                        End_Time__c, End_Date__c
                        FROM Holiday__c WHERE 
                        CALENDAR_YEAR(Start_Date__c) =: startDate.year()
                        WITH SECURITY_ENFORCED];
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }          
        }
        return null;   
    }
}