trigger TeacherWorkingHoursTrigger on Teacher_Working_Hours__c (before insert,before update) {
    
    Map<String,list<String>> MapofLocationAndDays = new Map<String,list<String>>(); 
    Set<String> setOfLocations = new Set<String>();
    Set<String> setOfTeachers = new Set<String>();
    Set<String> setOfIds = new Set<String>(); // this set is used for Exclude current records when updating
    Map<String,Map<String,Location_Working_Hours__c>> dayHoursMap = new Map<String,Map<String,Location_Working_Hours__c>>();
    
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

            for(Location_Working_Hours__c lObj : [SELECT Id, Day__c, Start_Time__c, End_Time__c, Location__c 
                                                    FROM Location_Working_Hours__c
                                                    WHERE Location__c IN : setOfLocations AND Active__c = true]){
                if(String.isNotBlank(lObj.day__c)){
                    List<String> Days = lObj.day__c.split(';');
                    Map<String,Location_Working_Hours__c> locationHoursMap = new Map<String,Location_Working_Hours__c>();
                    for(String day : Days){
                        locationHoursMap.put(day,new Location_Working_Hours__c(Start_Time__c = lObj.Start_Time__c, End_Time__c = lObj.End_Time__c));
                    }
                    dayHoursMap.put(lObj.Location__c,locationHoursMap);
                }
            }
        }
        System.debug('@@MapofLocationAndDays'+MapofLocationAndDays);
        if( !MapofLocationAndDays.isEmpty()){
            for(Teacher_Working_Hours__c objRecord : Trigger.New) {
                
                if(String.isNotEmpty(objRecord.Location__c) && String.isNotEmpty(objRecord.Teacher__c) 
                   && String.isNotEmpty(objRecord.Day__c) && objRecord.Active__c == true) {
                       String locatonAndTeacher = objRecord.Location__c + '-' + objRecord.Teacher__c;
                       List<String> Days = objRecord.day__c.split(';');
                       Map<String,Location_Working_Hours__c> locationHoursMap = dayHoursMap.get(objRecord.Location__c);
                       for(String day : Days){
                           if(MapofLocationAndDays.get(locatonAndTeacher).contains(day)){
                               objRecord.addError('Duplicate Record Found !!');
                           }
                           Location_Working_Hours__c lwhObj = locationHoursMap.get(day);
                           system.System.debug('lwhObj.Start_Time__c -> '+lwhObj.Start_Time__c );
                           system.System.debug('objRecord.Start_Time__c -> '+objRecord.Start_Time__c );
                           system.System.debug('objRecord.End_Time__c '+objRecord.End_Time__c );
                           system.System.debug('lwhObj.End_Time__c-> '+lwhObj.End_Time__c );
                           if(lwhObj.Start_Time__c > objRecord.Start_Time__c || objRecord.End_Time__c > lwhObj.End_Time__c){
                                objRecord.addError('Teacher working Hour Must Be Within Location Working Hours');
                           }
                       }
                   }
            }
        }
    }
}