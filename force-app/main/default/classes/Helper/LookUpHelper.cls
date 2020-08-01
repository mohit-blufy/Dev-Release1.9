public class LookUpHelper {
    
    @AuraEnabled
    public static List<Sobject> getRecords(String objectApiName, String searchKey){
        try {
            String query = 'SELECT Id,Name FROM ';           
            if(objectApiName == 'Teacher__c'){
                query += 'Account';
                query += ' WHERE recordtype.Id = '+ '\''+ConstantClass.teacherRecordTypeId+'\'';
            }else{
                query += objectApiName;
            }
            if(String.isNotBlank(searchKey)){
                if(objectApiName == 'Teacher__c'){
                    query += ' AND Name like '+'\'%'+searchKey+'%\'';
                }else{
                    query += ' WHERE Name like '+'\'%'+searchKey+'%\'';
                }
                
            }        
            query += ' LIMIT 100';
            System.debug(query);
            return Database.query(query);
        }catch (System.QueryException e) {
            System.debug(e.getMessage());
        } 
        return null;
    }
}
