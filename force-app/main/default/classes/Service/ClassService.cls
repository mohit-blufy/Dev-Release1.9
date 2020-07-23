/**
Name        :   ClassService
Date        :   11 JULY 2020
Description :   This class is use for to perform DML operation on Class Object
*/
public  class ClassService{   
    
    /**
    Name        :  getClassData
    Date        :  10-07-20
    Description :  This function is use for to get the class data based on class set Ids
    Dev         :  Asif
    */	
	public static List<Class__c> getClassData(Set<id> classId){
        if(!classid.isEmpty()){
            try {
                List<Class__c> clasList = new List<Class__c>();
                for(Class__c clsObj : [SELECT Id, Name, Course__c, 
                                        Current_Course_Module__c, Current_Course_Module__r.Sequence__c 
                                        FROM Class__c WHERE  Id IN: classId WITH SECURITY_ENFORCED]){
                    clasList.add(clsObj);
                }
                return clasList;
            }catch (System.QueryException e) {
                    System.debug(e.getMessage());
            }        
        }
        return null;
    }    
}
