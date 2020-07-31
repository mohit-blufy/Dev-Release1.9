public class CourseFeeService{
    
    public static List<Course_Fee__c> getByCourseId(String sId){  
        try{
            List<Course_Fee__c> listCourseFee = new List<Course_Fee__c>();
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Course__c,
                                                Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                                Fee__r.Required__c, Fee__r.Override__c,Fee__r.GST_Applicable__c
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null 
                                      AND Fee__r.RecordTypeId=:ConstantClass.primaryFeeRecordTypeId WITH SECURITY_ENFORCED]){
                                        listCourseFee.add(crFee);
            }
            return listCourseFee;  
        }
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;    
    }

    public static List<Course_Fee__c> getByCourseIdOrType(String sId, String type, String frequency){        
        try{
            List<Course_Fee__c> listCourseFee = new List<Course_Fee__c>();        
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Course__c,
                                             Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                             Fee__r.Required__c, Fee__r.Override__c,Fee__r.GST_Applicable__c
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c =:type  
                                      AND Fee__r.RecordTypeId=:ConstantClass.primaryFeeRecordTypeId
                                      WITH SECURITY_ENFORCED]){
                                        listCourseFee.add(crFee);
            }
            return listCourseFee;
        }    
        catch (System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;      
    }

    //Insertion of Course Fee Records
    public static void insertCourseFeeRecords(List<Course_Fee__c> listCourseFee){
        try{
            if(listCourseFee.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, listCourseFee,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    insert securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Error Message-->'+e.getMessage());
        }
    }

    //Updation of Course Fee Records
    public static void updateCourseFeeRecords(List<Course_Fee__c> listCourseFee){
        try{
            if(listCourseFee.size() > 0){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listCourseFee,true);
                if(securityDecision.getRemovedFields().keySet().size() > 0){
                    System.debug('Removed Fields-->'+securityDecision.getRemovedFields());
                }
                else{
                    update securityDecision.getRecords();
                }
            }
        }
        catch(Exception e){
            System.debug('Error Message-->'+e.getMessage());
        }
    }

}