public  class ClassService extends Entity{
    private Boolean isAccessible;
    private CourseFee cf_courseFee;

    public ClassService() {

    }
    public List<Clas> getByCourseId(String sId){        
        if (isAccessible){
            List<Clas> ls = new List<Clas>();
            for(Class__c cls: [SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c, Location__r.Name, 
                                        Teacher__r.Name, Type__c, Frequency__c, Status__c, Capacity__c, Days_of_Week__c, Seats_Available__c,
                                        (SELECT Id, Name, Start_Date__c, End_Date__c,Sessions__c, Status__c 
                                        FROM  Class_Terms__r
                                        WHERE Status__c =:ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND
                                            Sessions__c > 0 AND  Start_Date__c != null AND  End_Date__c != null ORDER BY Sequence__c)
                                FROM  Class__c 
                                WHERE Course__c =:sId AND  Type__c != null AND Frequency__c != null 
                                      AND (Status__c =: ConstantClass.clsOpenStatus OR (Status__c =: ConstantClass.clsClosedStatus AND Allow_Overbooking__c = True))]){
                ls.add(fillClas(cls));
            }
            return ls;
        }else{
            return null;
        }        
    }
	//Added by Asif on 10-07-20
	public List<Class__c> getClassData(Set<id> classId){
        if(!classid.isEmpty()){
            try {
                List<Class__c> clasList = new List<Class__c>();
                for(Class__c clsObj : [SELECT Id, Name, Course__c, Current_Course_Module__c, Current_Course_Module__r.Sequence__c FROM Class__c WHERE  Id IN: classId WITH SECURITY_ENFORCED]){
                    clasList.add(clsObj);
                }
                return clasList;
            }catch (System.QueryException e) {
                    System.debug(e.getMessage());
            }        
        }
        return null;
    }
    private Clas fillClas(Class__c cls){
        Clas c = new Clas();
        c.Id     = cls.Id;
        c.Name   = cls.Name;
        c.Type   = cls.Type__c; 
        c.Status = cls.Status__c;
        c.StartDate  = cls.Start_Date__c;
        c.EndDate    = cls.End_Date__c;        
        c.Frequency  = cls.Frequency__c;        
        c.Capacity   = cls.Capacity__c; 
        c.DaysOfWeek = cls.Days_of_Week__c; 
        c.SeatsAvailable = cls.Seats_Available__c;
        return c;
    }
}
