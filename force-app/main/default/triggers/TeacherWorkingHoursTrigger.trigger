trigger TeacherWorkingHoursTrigger on Teacher_Working_Hours__c (before insert,before update) {
    
    Map<String,list<String>> MapofLocationAndDays = new Map<String,list<String>>(); 
    Set<String> setOfLocations = new Set<String>();
    Set<String> setOfTeachers = new Set<String>();
    Set<String> setOfIds = new Set<String>(); // this set is used for Exclude current records when updating
    
    
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate ){
            for(Teacher_Working_Hours__c objRecord : Trigger.New){
                if(String.isNotEmpty(objRecord.Location__c) && String.isNotEmpty(objRecord.Teacher__c) 
                   && String.isNotEmpty(objRecord.Day__c) && objRecord.Active__c == true) {
                       System.debug('objRecord'+objRecord);
                       setOfLocations.add(objRecord.Location__c);
                       setOfTeachers.add(objRecord.Teacher__c);
                       setOfIds.add(objRecord.Id);
                   }
            }
            
            System.debug('@@setOfLocations'+setOfLocations);
            for(Teacher_Working_Hours__c objRecord : [SELECT Id, Location__c, Day__c, Teacher__c, Active__c 
                                                      FROM Teacher_Working_Hours__c
                                                      WHERE Location__c in : setOfLocations AND id Not IN :setOfIds AND Teacher__c in : setOfTeachers AND
                                                      Location__c !=NULL AND Teacher__c != NULL AND Day__c!= NULL AND Active__c = true ]){
                                                          List<String> Days = objRecord.day__c.split(';');
                                                          String locatonAndTeacher = objRecord.Location__c + '-' + objRecord.Teacher__c;
                                                          MapofLocationAndDays.put(locatonAndTeacher,Days);
                                                      }
        }
        System.debug('@@MapofLocationAndDays'+MapofLocationAndDays);
        if( !MapofLocationAndDays.isEmpty()){
            for(Teacher_Working_Hours__c objRecord : Trigger.New) {
                
                if(String.isNotEmpty(objRecord.Location__c) && String.isNotEmpty(objRecord.Teacher__c) 
                   && String.isNotEmpty(objRecord.Day__c) && objRecord.Active__c == true) {
                       String locatonAndTeacher = objRecord.Location__c + '-' + objRecord.Teacher__c;
                       List<String> Days = objRecord.day__c.split(';');
                       for(String day : Days){
                           if(MapofLocationAndDays.get(locatonAndTeacher).contains(day)){
                               objRecord.addError('Duplicate Record Found !!');
                           }
                       }
                   }
            }
        }
    }
}