public class AutoCompleteCmpController {
	@auraEnabled(cacheable=true)
    public static List<SObject> getRecords(String searchString, String objectApiName, String idFieldApiName, String valueFieldApiName, String extendedWhereClause, Integer maxRecords){
        Set<String> fieldsApiName = new Set<String>{'Id', 'Name'};
        if(String.isNotBlank(objectApiName) && objectApiName.endsWith('__c'))
            objectApiName = ''+objectApiName;
        Boolean isAccessible = FieldPremissionCrudUtility.checkReadPermission(objectApiName,fieldsApiName,false);    
        if(isAccessible){
            searchString = String.escapeSingleQuotes(searchString);
            objectApiName = String.escapeSingleQuotes(objectApiName);
            idFieldApiName = String.escapeSingleQuotes(idFieldApiName);
            valueFieldApiName = String.escapeSingleQuotes(valueFieldApiName);
            
            if(extendedWhereClause == null){
                extendedWhereClause = '';
            }
            System.debug('@@@@-->'+extendedWhereClause);
            String query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+' FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+String.escapeSingleQuotes(searchString)+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
            if(objectApiName.equalsIgnoreCase('Account')){
                if(extendedWhereClause.startsWith('001'))
                    extendedWhereClause = ' AND Parent__c = \'' +extendedWhereClause+ '\' AND Recordtype.Name =\'Customer\' ';
                //query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+',LastName,PersonEmail FROM '+objectApiName+' WHERE Recordtype.Name =\'Customer\' AND '+valueFieldApiName+' LIKE \'%'+searchString+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
                query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+',LastName,PersonEmail FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+String.escapeSingleQuotes(searchString)+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
            }       
            System.debug('@@@@-->'+query);
            return Database.query(query);
        }
        return null;
    }
}