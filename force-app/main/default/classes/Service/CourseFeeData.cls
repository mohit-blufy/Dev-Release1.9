public class CourseFeeData{
    private Boolean isAccessible;
    private CourseFee cf_coursefee;

    public CourseFeeData(){
        Boolean isCourseAccessible = FieldPremissionCrudUtility.checkReadPermission('Course__c',  
                                                                                       new Set<String>{'Id', 'Name', 'Status__c'},false);
        Boolean isFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('Fee__c',new Set<String>{'Id', 'Name', 'Amount__c','Unit_Price__c',
            																	 'Schedule__c','Units__c','Type__c','Frequency__c','Required__c','Override__c',
            																	 'Amount__c','GST_Applicable__c'},false);
        Boolean isCourseFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('Course_Fee__c',  
                                                                                         new Set<String>{'Id', 'Name','Course__c','Fee__c'},false);
    	
        if(isCourseAccessible && isFeeAccessible && isCourseFeeAccessible){
            isAccessible = true;
        }
    }

    public List<CourseFee> getByCourseId(String sId){        
        if (isAccessible){
            List<CourseFee> ls = new List<CourseFee>();
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Course__c,
                                                Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                                Fee__r.Required__c, Fee__r.Override__c,Fee__r.GST_Applicable__c
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null AND Fee__r.RecordTypeId=:ConstantClass.primaryFeeRecordTypeId]){
                ls.add(setCourseFee(crFee));
            }
            return ls;
        }
        else{
            return null;
        }        
    }

    public List<CourseFee> getByCourseIdOrType(String sId, String type, String frequency){        
        if (isAccessible){
            List<CourseFee> ls = new List<CourseFee>();        
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Course__c,
                                             Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, 
                                             Fee__r.Required__c, Fee__r.Override__c,Fee__r.GST_Applicable__c
                                      FROM Course_Fee__c 
                                      WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c =:type  AND Fee__r.RecordTypeId=:ConstantClass.primaryFeeRecordTypeId]){
                ls.add(setCourseFee(crFee));
            }
            return ls;
        }
        else{
            return null;
        }        
    }

    private CourseFee setCourseFee(Course_Fee__c crFee){
        CourseFee cf = new CourseFee();
        cf.Id  = crFee.Fee__c;
        cf.Name = crFee.Fee__r.Name;
        cf.CourseId = crFee.Course__c;
        cf.FeeId = crFee.Fee__c;

        Fee fe 		 = new Fee();
        fe.Id 		 = crFee.Fee__c;
        fe.Name		 = crFee.Fee__r.Name;
        fe.Type  	 = crFee.Fee__r.Type__c;
        fe.Frequency = crFee.Fee__r.Frequency__c;  
        fe.Amount 	 = crFee.Fee__r.Amount__c;
        fe.Schedule  = crFee.Fee__r.Schedule__c;  
        fe.Units  	 = crFee.Fee__r.Units__c;   
        fe.UnitPrice = crFee.Fee__r.Unit_Price__c;
       	fe.Overrid 	 = crFee.Fee__r.Override__c;
        fe.Required  = crFee.Fee__r.Required__c;
        fe.GSTApplicable = crFee.Fee__r.GST_Applicable__c;
        cf.Fee = fe;
        
        return cf;
    }
}