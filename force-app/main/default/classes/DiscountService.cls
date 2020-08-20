public class DiscountService {
    
    public static List<Discount__c> getAllGlobalDiscounts(){
        try{
            List<Discount__c> listDiscount = [SELECT Id, Name, Value__c, Type__c, Format__c, Code__c, Start_Date__c, End_Date__c,
                                              Override__c FROM Discount__c 
                                              WHERE Format__c != null AND Active__c = True AND Value__c != null AND 
                                              Global__c = true AND (Start_Date__c <= Today AND  End_Date__c >= Today)
                                              WITH SECURITY_ENFORCED];
            return listDiscount;
        }catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
}