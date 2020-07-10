trigger StudentSessionTrigger on Student_Session__c (after insert,after update) {
    Set<Id> enrolmentsIds = new Set<Id>();
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            for(Student_Session__c objStudentSession : Trigger.new){
                enrolmentsIds.add(objStudentSession.Enrollment__c);
            }
            if(enrolmentsIds.size()>0){
                StudentSessionHelper.rollupEnrollmentsInsert(enrolmentsIds);
            }
        }
        else if( Trigger.isUpdate ){
            for(Student_Session__c objStudentSession : Trigger.new){
                if(objStudentSession.status__c != Null && (Trigger.oldMap.get(objStudentSession.id).Status__c != objStudentSession.Status__c))
                    enrolmentsIds.add(objStudentSession.Enrollment__c);
            }
            if(enrolmentsIds.size()>0){
               StudentSessionHelper.rollupEnrollmentsUpdate(enrolmentsIds);
            }
        }
    }
}