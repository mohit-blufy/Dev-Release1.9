trigger EnrollmentTrigger on Enrollment__c (after update) {
    List<Enrollment__c> enrList = new List<Enrollment__c>();
    Set<Id> enrIdSet = new Set<Id>();

    for(Enrollment__c enr : trigger.new){
        if(enr.Status__c=='Enrolled' && trigger.oldMap.get(enr.Id).Status__c!=enr.Status__c){
            enrList.add(enr);
            enrIdSet.add(enr.Id);
        }
    }

    if(enrList.size() > 0){
        EnrollmentTriggerHelper.insertFeeAlloaction(enrList, enrIdSet);
    }
}