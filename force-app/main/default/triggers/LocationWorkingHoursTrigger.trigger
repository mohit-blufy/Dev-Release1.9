trigger LocationWorkingHoursTrigger on Location_Working_Hours__c (before insert,before update) {
    Map<String,list<String>> mapOfLocationAndDays = new Map<String,list<String>>();
    Set<String> setLocations = new Set<String>();
    Set<String> setOfIds = new Set<String>(); // this set is used for Exclude current records when updating
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Location_Working_Hours__c objLocation : Trigger.New){
                if(String.isNotEmpty(objLocation.Location__c) && String.isNotEmpty(objLocation.Day__c) && objLocation.Active__c == true){
                    setLocations.add(objLocation.Location__c);
                    setOfIds.add(objLocation.id);
                }
            }
            
            list<Location_Working_Hours__c>lstLocations = [SELECT Id, Name, Location__c, Day__c 
                                                           FROM Location_Working_Hours__c
                                                           WHERE Location__c in :setLocations AND Id Not in :setOfIds AND Active__c = true And Day__c != NULL	
                                                          ];
            for(Location_Working_Hours__c objLocation :lstLocations){
                List<String> Days = objLocation.day__c.split(';');
                mapOfLocationAndDays.put(objLocation.Location__c,Days);
            }
            
            if( !mapOfLocationAndDays.isEmpty()){
                for(Location_Working_Hours__c objLocation : Trigger.New) {
                    if(String.isNotEmpty(objLocation.Location__c) && String.isNotEmpty(objLocation.Day__c) && objLocation.Active__c == true){
                        List<String> Days = objLocation.day__c.split(';');
                        for(String objDays : Days){
                            if(mapOfLocationAndDays.get(objLocation.Location__c).contains(objDays)){
                                objLocation.Day__c.addError('Duplicate Record Found');
                                break;
                            }
                        }
                    }
                }	
            }
        }
    }
}