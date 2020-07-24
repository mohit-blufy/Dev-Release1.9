public class HolidayService {
   
	public static List<Holiday__c> getByDate(Date startDate, Date endDate){
        if(startDate != null && endDate != null){
            try {
                return [Select Id,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c 
                        FROM Holiday__c 
                        WHERE Start_Date__c != null AND (Start_Date__c >=: startDate AND End_Date__c <=: endDate) 
                        WITH SECURITY_ENFORCED];
            }catch (System.QueryException e) {
                System.debug(e.getMessage());
            }        
        }
        return null;
    }
}
    