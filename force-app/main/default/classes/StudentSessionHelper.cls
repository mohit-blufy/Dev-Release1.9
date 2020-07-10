public class StudentSessionHelper {
    
    public static void rollupEnrollmentsInsert(set<Id>enrolmentsIds){
        Map<Id,Enrollment__c> mapOfEnrollment = new  Map<Id,Enrollment__c>();
        Boolean isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Student_Session__c',  
                                                                                            new Set<String>{'Id','Enrollment__c'},false);
        Boolean isEnrollmentAccessible = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c',new Set<String>{'No_Scheduled_Job__c'},true);
        if(isStudentSessionAccessible){
            AggregateResult[] groupedResult = [SELECT COUNT(Id),Enrollment__c 
                                               FROM Student_Session__c 
                                               where Enrollment__c IN :enrolmentsIds group by Enrollment__c
                                              ];
            for(AggregateResult ar:groupedResult) {
                Id enrollmentId = (ID)ar.get('Enrollment__c');
                Integer count = (INTEGER)ar.get('expr0');
                Enrollment__c objEnrollment = new Enrollment__c(Id=enrollmentId);
                objEnrollment.No_Scheduled_Job__c = count;
                mapOfEnrollment.put(objEnrollment.id,objEnrollment);
            }
            if(isEnrollmentAccessible){
                update mapOfEnrollment.values();
            }
            else{
                system.debug('FLS not found for Enrollment ');
            }
        }
        else
            system.debug('CRUD or FLS not found for Student Sessions');
    }
    
    public static void rollupEnrollmentsUpdate(Set<Id>enrolmentsIds) {
        Boolean isEnrollmentAccessible = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c',new Set<String>{'Id','Status__c','Enrollment_Date__c'
            },false);
        
        Boolean isEnrollmentUpdatable = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c',  
                                                                                       new Set<String>{'No_of_canceled_Session__c','No_Attended_Session__c'},true);
        if(isEnrollmentAccessible){
            AggregateResult[] groupedResults = [SELECT COUNT(Id), status__c,Enrollment__c 
                                                FROM Student_Session__c 
                                                where Enrollment__c IN :enrolmentsIds And status__c IN ('Attended','Canceled') 
                                                group by status__c,Enrollment__c 
                                               ];
            System.debug('groupedResults'+groupedResults);
            Map<String,Integer> mapOfStatusAndCount = new  Map<String,Integer>();
            for(AggregateResult objAggr:groupedResults) {
                String statusValue = (String)objAggr.get('status__c');//29-Apr-2020 commented :(String)objAggr.get('status__c');
                String enrollmentId = (String)objAggr.get('Enrollment__c');//29-Apr-2020 commented:(String)objAggr.get('Enrollment__c');
                Integer countOfStatus = (Integer)objAggr.get('expr0');
                mapOfStatusAndCount.put(enrollmentId +'-'+statusValue,countOfStatus);
            }
            System.debug('mapOfStatusAndCount'+mapOfStatusAndCount);
            list<Enrollment__c> lstEnrollment = new list<Enrollment__c>();
            for(Id EnrollmentId : enrolmentsIds) {
                Enrollment__c objEnrollment = new Enrollment__c(Id=EnrollmentId,No_Attended_Session__c = 0,No_of_canceled_Session__c = 0);
                if(mapOfStatusAndCount.containsKey(EnrollmentId +'-'+'Attended')){
                    //objEnrollment.No_Attended_Session__c = mapOfStatusAndCount.get(EnrollmentId +'-'+'Attended');
                    objEnrollment.put('No_Attended_Session__c',mapOfStatusAndCount.get(EnrollmentId +'-'+'Attended'));
                }
                if(mapOfStatusAndCount.containsKey(EnrollmentId +'-'+'Canceled')){
                    //objEnrollment.No_of_canceled_Session__c = mapOfStatusAndCount.get(EnrollmentId +'-'+'Canceled');
                    objEnrollment.put('No_of_canceled_Session__c',mapOfStatusAndCount.get(EnrollmentId +'-'+'Canceled'));
                }
                lstEnrollment.add(objEnrollment);
            }
            if(isEnrollmentUpdatable)
                update lstEnrollment;
            else
                system.debug('FLS not found for Enrollment ');
        }
        else
            system.debug('CRUD or FLS not found for Enrollment ');
    }
    
}