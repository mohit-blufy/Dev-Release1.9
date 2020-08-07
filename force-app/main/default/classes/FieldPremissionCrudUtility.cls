public with sharing class FieldPremissionCrudUtility {
        
    public Static boolean checkReadPermission(String objApiName, Set<String> fieldsApiNameSet, Boolean isUpdate){
        system.debug('fieldsApiNameSet-> '+fieldsApiNameSet +' -- '+fieldsApiNameSet.size());
        
        if(String.isNotBlank(objApiName) && (objApiName.endsWith('__c') || objApiName.endsWith('__mdt')))
            objApiName = ConstantClass.nameSpace + objApiName;
        //check object's CRUD Permission
        if(!checkObjCRUD(objApiName, isUpdate)){
            return false;
        }
        boolean isAccessible = true;
        
        
        SObjectType obj = Schema.getGlobalDescribe().get(objApiName);
        if(obj != null && fieldsApiNameSet != null && fieldsApiNameSet.size()>0){
            DescribeSObjectResult objDef = obj.getDescribe();
            Map<String, SObjectField> fieldsMap = objDef.fields.getMap();
            for(String fieldName : fieldsApiNameSet){
                if(String.isNotBlank(fieldName) && fieldName.endsWith('__c'))
                    fieldName = ConstantClass.nameSpace + fieldName;
                system.debug('fieldName-->'+fieldName);
                if(fieldsMap.containsKey(fieldName)){
                    SObjectField field = fieldsMap.get(fieldName);
                    Schema.DescribeFieldResult fieldDes = field.getDescribe();
                    //check isAccessible
                    if(!fieldDes.isAccessible()){
                        isAccessible = false;
                        break;
                    }
                    //check isCreateable and isUpdateable 
                    if(isUpdate){                        
                       /* if(!fieldDes.isCreateable() || !fieldDes.isUpdateable()){
                            isAccessible = false;
                            break;
                        }*/
                        //Edited by Shubhi 05/05/2020
                        if(!(fieldDes.isCreateable() || fieldDes.isUpdateable())){
                            isAccessible = false;
                            break;
                        }
                    }
                }
            }
        }else{
            return false;
        }
        
        return isAccessible;
    }
    
    public static boolean checkObjCRUD(String objName, Boolean isUpdate){
      /*  boolean isCRUD = true;
        SObjectType obj = Schema.getGlobalDescribe().get(objName);
        if(obj != null){
            DescribeSObjectResult objDef = obj.getDescribe();
            if(objDef.isAccessible() == false){
                isCRUD = false;
            }
            if(isUpdate){
                if(objDef.isCreateable() == false || objDef.isUpdateable() == false || objDef.isDeletable() == false){
                    isCRUD = false;
                }
            }
        }else{
            return false;
        }
		return isCRUD;
		*/
        
        boolean isCRUD = false;
        system.debug('objName'+objName);
        SObjectType obj = Schema.getGlobalDescribe().get(objName);
        system.debug('obj'+obj);
        if(obj != null){
            DescribeSObjectResult objDef = obj.getDescribe();           
            isCRUD = objDef.isAccessible();
            
            if(isUpdate){
                if(objDef.isCreateable() || objDef.isUpdateable() || objDef.isDeletable()){
                    isCRUD = true;
                }
            }
        }else{
            return false;
        }
        return isCRUD;
    }
    
    
    public Static boolean checkReadPermission(String objApiName, Set<String> fieldsApiNameSet, Boolean isUpdate,Boolean isDelete){
        system.debug('fieldsApiNameSet-> '+fieldsApiNameSet +' -- '+fieldsApiNameSet.size());
        
        //check object's CRUD Permission
        if(!checkObjCRUD(objApiName, isUpdate,isDelete)){
            return false;
        }
        boolean isAccessible = true;
        
        if(String.isNotBlank(objApiName) && (objApiName.endsWith('__c') || objApiName.endsWith('__mdt')))
            objApiName = ConstantClass.nameSpace + objApiName;
        SObjectType obj = Schema.getGlobalDescribe().get(objApiName);
        if(obj != null && fieldsApiNameSet != null && fieldsApiNameSet.size()>0){
            DescribeSObjectResult objDef = obj.getDescribe();
            Map<String, SObjectField> fieldsMap = objDef.fields.getMap();
            for(String fieldName : fieldsApiNameSet){
                if(String.isNotBlank(fieldName) && fieldName.endsWith('__c'))
                    fieldName = ConstantClass.nameSpace+fieldName;
                
                if(fieldsMap.containsKey(fieldName)){
                    SObjectField field = fieldsMap.get(fieldName);
                    Schema.DescribeFieldResult fieldDes = field.getDescribe();
                     system.debug('fieldsApiNameSet-> '+fieldDes.isAccessible());
                    //check isAccessible
                    if(!fieldDes.isAccessible()){
                        isAccessible = false;
                        break;
                    }
                    //check isCreateable and isUpdateable 
                    if(isUpdate){
                        system.debug('fieldsApiNameSet-> '+fieldDes.isCreateable()+'   '+fieldDes.isUpdateable()) ;
                        if(!fieldDes.isCreateable() || !fieldDes.isUpdateable()){
                            isAccessible = false;
                            break;
                        }
                    }
                }
            }
        }else{
            return false;
        }
        
        return isAccessible;
    }
    
    public static boolean checkObjCRUD(String objName, Boolean isUpdate,Boolean isDelete){
        boolean isCRUD = true;
        SObjectType obj = Schema.getGlobalDescribe().get(objName);
        if(obj != null){
            DescribeSObjectResult objDef = obj.getDescribe();
            if(objDef.isAccessible() == false){
                isCRUD = false;
            }
            if(isUpdate){
                if(objDef.isCreateable() == false || objDef.isUpdateable() == false){
                    isCRUD = false;
                }
            }
            if(isDelete){
               if(objDef.isDeletable() == false){
                    isCRUD = false;
                } 
            }
        }else{
            return false;
        }
        return isCRUD;
    }
}