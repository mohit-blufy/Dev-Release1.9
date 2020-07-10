public class FeeData extends Entity{
    private Boolean isAccessible;
    public FeeData(){
        isAccessible = true;
    }
    public Fee getById(String sId){
        if (isAccessible){
            Fee fe = new Fee();
            for(Fee__c fee: [SELECT Id, Name, Type__c, Frequency__c, Amount__c, Schedule__c, Units__c, Unit_Price__c   
                             FROM Fee__c WHERE ID =: sId AND Amount__c > 0 AND  Unit_Price__c != null]){
                fe.Id  = fee.ID;
                fe.Name = fee.Name;
                fe.Type  = fee.Type__c;
                fe.Frequency = fee.Frequency__c;  
                fe.Amount = fee.Amount__c;
                fe.Schedule  = fee.Schedule__c;  
                fe.Units  = fee.Units__c;   
                fe.UnitPrice = fee.Unit_Price__c;
            }
            return fe;
        }
        else{
            return null;
        }        
    }
}