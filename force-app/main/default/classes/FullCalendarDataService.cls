global with sharing class FullCalendarDataService {         
    static String status = ConstantClass.sessionCancel;
    static String sessionType = ConstantClass.sessionType;
    static Set<String> fieldsApiName ;
    static boolean isSessionAccessible;  
    static boolean isLocationWorkingHoursAccessible; 
    static boolean isTeacherWorkingHoursAccessible;     
    static boolean isHolidayAccessible;
    static boolean isTeacherLeaveAccessible;
    
    private static String getSOQLQuery(){      
        return 'SELECT Id, Name, Sequence__c, Class__c, Session_Date__c, Start_Time__c, End_Time__c, Teacher__c, Teacher__r.Name, Status__c, Event_Color__c, Event_Text_Color__c, Type__c  FROM Session__c WHERE  Status__c !=: status  AND ';
    }
    
    /**
Name        :   fetchSessions
Date        :   19 Feb 2020
Description :   Function is use for to get current sessions records based on teacher Id
Developer   :   
*/
    @RemoteAction
    global static SessionRecordModel fetchSessions(String selectedTeacher, String selectedLocation, String selectedClass, String selectedCourse, Boolean isPhSessionNeed){       
        //system.debug('selectedClass '+selectedClass);
        List<Session__c> sessionList = new List<Session__c>(); 
        isSessionAccessible = false;
        if(FieldPremissionCrudUtility.checkReadPermission('Account', new Set<String>{'Name','location__c'}, false)){
            fieldsApiName = new Set<String>{'Id','Name','Sequence__c', 'Class__c', 'Session_Date__c', 'Start_Time__c','End_Time__c','Teacher__c', 'Status__c','Event_Color__c','Event_Text_Color__c','Type__c'};
                isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, false);
            if(isSessionAccessible){
                String query = getSOQLQuery();                
                if(String.isNotBlank(selectedLocation)){
                    query += ' location__c =: selectedLocation AND ';
                }
                if(selectedTeacher == 'All_Teachers'){            
                    query += ' Session_Date__c = TODAY ';
                }else{          
                    query += ' teacher__c =: selectedTeacher AND Session_Date__c = TODAY ';   
                }      
                system.debug('selectedClass '+selectedClass);
                if(String.isNotBlank(selectedClass) && selectedClass != 'All_Class'){
                    if(isPhSessionNeed == false){
                        query += ' AND Class__c IN ('+ selectedClass+') ' ;
                    }else if(isPhSessionNeed){
                        query += 'AND ( Class__c IN ('+ selectedClass+') OR (Type__c =: sessionType) ) '  ;
                    }                
                }
                
                if(String.isNotBlank(selectedCourse) && selectedCourse != 'All_Courses' && String.isBlank(selectedClass)){
                    sessionList = new List<Session__c>();
                }else{
                    system.debug('query '+query);
                    sessionList = Database.query(query);
                }                  
            }
            else{
                System.debug('Session Fields Not Accessible');
            }
        }     
        if(!isSessionAccessible){
            return new SessionRecordModel();
        }
        return getSessionData(selectedTeacher, selectedLocation, sessionList);
    }
    
    /**
Name        :   SessionRecordModel
Date        :   20 Feb 2020
Description :   Function is use for to get sessions records based on teacher Id and selected Date
Developer   :   
*/
    @RemoteAction
    global static SessionRecordModel fetchSessionsByDate(String selectedTeacher, String selectedLocation, String selectedDate, String selectedClass, String selectedCourse, Boolean isPhSessionNeed){        
        //system.debug('selectedClass '+selectedClass);ctedLocation, String selectedDate, String selectedClass, String selectedCourse, Boolean isPhSessionNeed){        
        //system.debug('selectedClass '+selectedClass);ctedLocation, String selectedDate, String selectedClass, String selectedCourse, Boolean isPhSessionNeed){        
        //system.debug('selectedClass '+selectedClass);
        List<Session__c> sessionList = new List<Session__c>(); 
        fieldsApiName = new Set<String>{'Id','Name','Sequence__c', 'Class__c', 'Session_Date__c', 'Start_Time__c','End_Time__c','Teacher__c', 'Status__c','Event_Color__c','Event_Text_Color__c','Type__c'};
            isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, false);
        if(isSessionAccessible){
            String query = getSOQLQuery();
            if(String.isNotBlank(selectedDate)){     
                date selectDate = date.valueOf(selectedDate);   
                
                if(String.isNotBlank(selectedLocation)){
                    query += ' location__c =: selectedLocation AND ';
                }     
                
                if(selectedTeacher == 'All_Teachers'){                
                    query += ' Session_Date__c =: selectDate ';
                }else{                
                    query += ' teacher__c =: selectedTeacher AND Session_Date__c =: selectDate ';   
                }
                system.debug('selectedClass '+selectedClass);
                if(String.isNotBlank(selectedClass) && selectedClass != 'All_Class'){
                    if(isPhSessionNeed == false){
                        query += ' AND Class__c IN ('+ selectedClass+') ' ;
                    }else if(isPhSessionNeed){
                        query += 'AND ( Class__c IN ('+ selectedClass+') OR (Type__c =: sessionType) ) '  ;
                    }  
                }
                
                system.debug('query '+query);
                if(String.isNotBlank(selectedCourse) && selectedCourse != 'All_Courses' && String.isBlank(selectedClass)){
                    sessionList = new List<Session__c>();
                }else{
                    sessionList = Database.query(query);
                }      
                system.debug('query '+query);
                //sessionList = Database.query(query);
            }
            return getSessionData(selectedTeacher, selectedLocation, sessionList);
        }
        else{
            System.debug('Session Fields Not Accessible');
            return null;
        }
    }
    
    /**
Name        :   fetchSessionsByWeek
Date        :   20 Feb 2020
Description :   Function is use for to get sessions records based on teacher Id and date ranage
Developer   :   
*/
    @RemoteAction
    global static SessionRecordModel fetchSessionsByWeek(String selectedTeacher, String selectedLocation, String startDate, String endDate, String selectedClass, String selectedCourse, Boolean isPhSessionNeed){        
        //system.debug('selectedClass '+selectedClass);
        List<Session__c> sessionList = new List<Session__c>();    
        fieldsApiName = new Set<String>{'Id','Name','location__c','Sequence__c', 'Class__c', 'Session_Date__c', 'Start_Time__c','End_Time__c','Teacher__c', 'Status__c','Event_Color__c','Event_Text_Color__c','Type__c'};
            isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, false);
        if(isSessionAccessible){
            String query = getSOQLQuery();
            if(String.isNotBlank(startDate) && String.isNotBlank(endDate)){                
                date startDt = date.valueOf(startDate);  
                date endDt = date.valueOf(endDate);   
                
                if(String.isNotBlank(selectedLocation)){
                    query += ' location__c =: selectedLocation AND ';
                }                 
                
                if(selectedTeacher == 'All_Teachers'){               
                    query += ' Session_Date__c >=: startDt AND  Session_Date__c <=: endDt ';
                }else{               
                    query += ' teacher__c =: selectedTeacher AND Session_Date__c >=: startDt AND  Session_Date__c <=: endDt ';   
                }        
                system.debug('selectedClass '+selectedClass);          
                if(String.isNotBlank(selectedClass) && selectedClass != 'All_Class'){
                    if(isPhSessionNeed == false){
                        query += ' AND Class__c IN ('+ selectedClass+') ' ;
                    }else if(isPhSessionNeed){
                        query += 'AND ( Class__c IN ('+ selectedClass+') OR (Type__c =: sessionType) ) '  ;
                    }  
                }//else if(isPhSessionNeed == false){
                //     query += ' AND Class__c != null';
                // }                       
                system.debug('query '+query);
                if(String.isNotBlank(selectedCourse) && selectedCourse != 'All_Courses' && String.isBlank(selectedClass)){
                    sessionList = new List<Session__c>();
                }else{
                    sessionList = Database.query(query);
                }      
                //system.debug('query '+query);
                //sessionList = Database.query(query);
            }            
            return getSessionData(selectedTeacher, selectedLocation, sessionList);
        }
        else{
            System.debug('Session Fields Not Accessible');
            return null;
        }
    }
    
    /**
Name        :   getSessionData
Date        :   21 Feb 2020
Description :   Function is use for to get sessions records
Developer   :   
*/
    public static SessionRecordModel getSessionData(String selectedTeacher, String selectedLocation, List<Session__c> sessionList){
        SessionRecordModel sessionModelObj = new SessionRecordModel();                             
        if(sessionList.size() > 0){           
            sessionModelObj.locationId = selectedLocation;
            sessionModelObj.teacherId = selectedTeacher;
            sessionModelObj.sessionModelList = sessionList;   
        }         
        return sessionModelObj;
    }
    
    /**
Name        :   getWorkingHours
Date        :   22 Feb 2020
Description :   Function is use for to get working hours of current location
Developer   :   
*/
    @RemoteAction
    global static List<Location_Working_Hours__c> getWorkingHours(String locationId){
        List<Location_Working_Hours__c> workingHourList = new List<Location_Working_Hours__c>();
        fieldsApiName = new Set<String>{'Id', 'Name', 'Day__c', 'Start_Time__c', 'End_Time__c', 'Active__c', 'Location__c'};
            isLocationWorkingHoursAccessible = FieldPremissionCrudUtility.checkReadPermission('Location_Working_Hours__c', fieldsApiName, false);
        if(isLocationWorkingHoursAccessible){
            if(String.isNotBlank(locationId)){
                for(Location_Working_Hours__c wokObj : [SELECT Id, Name, Day__c, Start_Time__c, End_Time__c, Active__c, Location__c FROM Location_Working_Hours__c WHERE location__c =: locationId AND Active__c = true]){
                    if(wokObj.Active__c == true){
                        workingHourList.add(wokObj);
                    }
                }
            }
        }
        return workingHourList;
    }
    
    /**
Name        :   getSessionResources
Date        :   25 Feb 2020
Description :   commment line after discussed with Dharam And NITIN 
Developer   :   
*/
    // @RemoteAction
    // global static SessionRecordModel getSessionResources(String resourceId, String selectedLocation, String teacherId, String startDate, String resourceType ){
    //     String query = 'SELECT Id, Name,Resource__c, Resource__r.Name,Session__r.Name, Session__r.Start_Time__c, Session__r.Session_Date__c, Session__r.End_Time__c, Session__r.Event_Color__c, Session__r.Teacher__r.Name FROM Session_Resource__c WHERE ';
    //     List<Session_Resource__c> sessionResList = new List<Session_Resource__c>();
    //     SessionRecordModel sessionModelObj = new SessionRecordModel();          
    //     if(String.isNotBlank(resourceId)){
    //         date startDt = date.valueOf(startDate);  
    //         //system.debug(' startDt  '+startDt);
    //         //system.debug(' selectedLocation  '+ selectedLocation);
    //         //system.debug('teacherId '+teacherId);
    //         query += 'Resource__r.Id IN ('+resourceId+') AND Session__r.Teacher__r.location__c =: selectedLocation AND Session__r.Session_Date__c =: startDt ';
    //         if(String.isNotBlank(teacherId) && teacherId != 'All_Teachers'){
    //             query += 'AND Session__r.teacher__c =: teacherId ';
    //         }
    //         if(String.isNotBlank(resourceType)  && resourceType != 'All_Resources_Type'){
    //              query += 'AND Resource__r.type__c =: resourceType';            
    //         }
    //         //system.debug('query  -- '+query);
    //         sessionResList = Database.query(query);
    //         if(sessionResList.size() > 0){
    //             sessionModelObj.locationId = selectedLocation;
    //             sessionModelObj.teacherId = teacherId;
    //             sessionModelObj.sessionResourceModelList = sessionResList;   
    //         }
    //     }
    //     return sessionModelObj;
    // }
    
    // @RemoteAction
    // global static SessionRecordModel getSessionResourcesByWeek(String selectedLocation, String selectedTeacher, String resourceId, String startDate, String endDate, String resourceType){
    //     String query = 'SELECT Id, Name,Resource__c, Resource__r.Name, Session__r.Name, Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.Session_Date__c, Session__r.Event_Color__c, Session__r.Teacher__r.Name FROM Session_Resource__c WHERE ';
    //     List<Session_Resource__c> sessionResList = new List<Session_Resource__c>();
    //     SessionRecordModel sessionModelObj = new SessionRecordModel();     
    //     date startDt = date.valueOf(startDate);  
    //     date endDt = date.valueOf(endDate);  
    //     //system.debug(' startDt  '+startDt);
    //     //system.debug(' selectedLocation  '+ selectedLocation);
    //     //system.debug('teacherId '+selectedTeacher);
    //     if(String.isNotBlank(resourceId) && String.isNotBlank(startDate) && String.isNotBlank(endDate) && String.isNotBlank(selectedLocation) && String.isNotBlank(selectedTeacher)){  
    //       query += 'Resource__r.Id IN ('+resourceId+') AND Session__r.Teacher__r.location__c =: selectedLocation AND  Session__r.Session_Date__c >=: startDt AND Session__r.Session_Date__c <=: endDt ';
    //      if(String.isNotBlank(selectedTeacher) && selectedTeacher != 'All_Teachers'){
    //             query += 'AND Session__r.teacher__c =: selectedTeacher ';
    //         }
    //         if(String.isNotBlank(resourceType) && resourceType != 'All_Resources_Type'){
    //              query += 'AND Resource__r.type__c =: resourceType';            
    //         }
    //         sessionResList = Database.query(query);
    //         if(sessionResList.size() > 0){
    //             sessionModelObj.locationId = selectedLocation;
    //             sessionModelObj.teacherId = selectedTeacher;
    //             sessionModelObj.sessionResourceModelList = sessionResList;   
    //         }
    //         //system.debug('query  -- '+query);
    //     }
    //     return sessionModelObj;
    // }
    
    /**
Name        :   getTeacherWorkingHours
Date        :   29 Feb 2020
Description :   use for to get working hours of teacher based on location id
Developer   :   
*/
    @RemoteAction
    global static List<Teacher_Working_Hours__c> getTeacherWorkingHours(String locationId){
        List<Teacher_Working_Hours__c> teacherWorkingHourList = new List<Teacher_Working_Hours__c>();
        fieldsApiName = new Set<String>{'id', 'start_time__c', 'end_time__c', 'location__c', 'teacher__c', 'Day__c'};
            isTeacherWorkingHoursAccessible = FieldPremissionCrudUtility.checkReadPermission('Teacher_Working_Hours__c', fieldsApiName, false);                
        if(isTeacherWorkingHoursAccessible){
            if(String.isNotBlank(locationId)){
                for(Teacher_Working_Hours__c teacherObj : [Select id, start_time__c, end_time__c, location__c, teacher__c,Day__c from Teacher_Working_Hours__c WHERE location__c =: locationId  AND Active__c  = true]){
                    teacherWorkingHourList.add(teacherObj);               
                }
            }
        }
        return teacherWorkingHourList;
    }
    
    /**
Name        :   setNewSessionTiming
Date        :   05 Mar 2020
Description :   
Developer   :   
*/
    @RemoteAction
    global static void setNewSessionTiming(Id recId, String parentId, String newStartTime, String currentDate){
        //system.debug('recId  '+recId);
        Session__c sessionObj;
        List<Session_Resource__c> sessionResList = new List<Session_Resource__c>();
        if(String.isNotBlank(recId)){
            String sObjName = recId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Session__c'){
                sessionObj = new Session__c(id = recId);
                if(String.isNotBlank(parentId)){
                    sessionObj.Teacher__c = parentId;
                }
            }/*else if(sObjName == 'Session_Resource__c'){
sessionResList = [SELECT id,Session__r.id,Resource__c FROM Session_Resource__c WHERE id =: recId LIMIT 1];  
//system.debug('sessionResObj.Session__r.Id->'+sessionResList[0].Session__r.Id);
if(sessionResList.size() > 0){
sessionObj = new Session__c(Id = sessionResList[0].Session__r.Id);
if(String.isNotBlank(parentId)){
sessionResList[0].Resource__c = parentId;
}   
}               
}*/
            String[] strTimeSplit = newStartTime.split(':');
            Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                              ,Integer.valueOf(strTimeSplit[1]) //min
                                              ,Integer.valueOf(strTimeSplit[2]) //sec
                                              ,0);    
            sessionObj.Start_Time__c = startTime; 
            sessionObj.Session_Date__c = date.valueOf(currentDate);
            try{
                fieldsApiName = new Set<String>{'Session_Date__c', 'Start_Time__c','Teacher__c'};
                    isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, true);
                if(isSessionAccessible){
                    update sessionObj;
                }
                // if(sObjName == 'Session_Resource__c' && sessionResList.size() > 0){
                //     update sessionResList;
                // }
            }catch(Exception ex){
                system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
            }
        }
    }
    /**
Name        :   setNewTimeForAllSession
Date        :   05 Mar 2020
Description :   use for set new time of all sessions 
Developer   :   
*/
    @RemoteAction
    global static void setNewTimeForAllSession(String sessionId, String newStartTime){
        fieldsApiName = new Set<String>{'Id','Name','Session_Date__c', 'Start_Time__c','Teacher__c'};
            isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, false);
        if(isSessionAccessible){
            if(String.isNotBlank(sessionId)){
                List<Session__c> sessionList = [SELECT Id, Teacher__c, Teacher__r.location__c, Session_Date__c, Start_Time__c FROM Session__c WHERE id =: sessionId];
                sessionList =  [SELECT Id, Start_Time__c FROM Session__c 
                                WHERE Teacher__c =: sessionList[0].Teacher__c AND 
                                Teacher__r.location__c =: sessionList[0].Teacher__r.location__c AND
                                Session_Date__c >=: sessionList[0].Session_Date__c AND 
                                Start_Time__c =: sessionList[0].Start_Time__c];
                
                String[] strTimeSplit = newStartTime.split(':');
                Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                  ,Integer.valueOf(strTimeSplit[1]) //min
                                                  ,Integer.valueOf(strTimeSplit[2]) //sec
                                                  ,0);  
                
                for(Session__c sessionObj : sessionList){
                    sessionObj.Start_Time__c = startTime; 
                }
                
                try{
                    fieldsApiName = new Set<String>{'Start_Time__c'};
                        isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, true);
                    if(isSessionAccessible){
                        update sessionList;  
                    }
                }catch(Exception ex){
                    system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
                }
            }
        }
    }
    
    /**
Name        :   setNewDateTimeForCurrentAndUpComingSession
Date        :   09 Mar 2020
Description :   function is use for set new date and time for current selected session and upcoming session as well
Developer   :   
*/
    @RemoteAction 
    global static void setNewDateTimeForCurrentAndUpComingSession(String sessionId, String newStartTime,  Integer dayDiffernce, Integer previousDay, String parentId){
        if(String.isNotBlank(sessionId)){
            List<VacationModel> vacationList = new List<VacationModel>();
            boolean isHoliday = false;        
            //system.debug('sessionId  '+sessionId);
            //system.debug('newStartTime  '+newStartTime);
            //system.debug('dayDiffernce  '+dayDiffernce);
            //system.debug('previousDay  '+previousDay);
            fieldsApiName = new Set<String>{'Id','Name','location__c','Sequence__c', 'Class__c', 'Session_Date__c', 'Start_Time__c','End_Time__c','Teacher__c','Type__c'};
                isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, false);
            isHolidayAccessible = FieldPremissionCrudUtility.checkReadPermission('Holiday__c',new Set<String>{'Id','Start_Time__c'
                ,'Start_Date__c','End_Time__c','End_Date__c'}, false);
            isTeacherLeaveAccessible = FieldPremissionCrudUtility.checkReadPermission('Teacher_Leave__c',new Set<String>{'Id','Teacher__c'
                ,'Start_Date__c','End_Date__c','Status__c'}, false);
            Boolean isBlufyConfigAccessible = FieldPremissionCrudUtility.checkReadPermission('Blufy_Config__mdt',  
                                                                                            new Set<String>{'Id','Overlap_Holiday_For_Monthly_Session__c'},false);

            if(isSessionAccessible && isHolidayAccessible && isTeacherLeaveAccessible && isBlufyConfigAccessible){
                List<Blufy_Config__mdt> blufyList = [SELECT Id, Overlap_Holiday_For_Monthly_Session__c FROM Blufy_Config__mdt LIMIT 1];
                List<Session__c> sessionList = [SELECT Id, Location__c, Teacher__c, Teacher__r.location__c, Session_Date__c, Start_Time__c, Notes__c, Type__c FROM Session__c WHERE id =: sessionId];
                if(sessionList.size() > 0){
                    for(Holiday__c holiObj : [SELECT Id, Start_Time__c, Start_Date__c, End_Time__c, End_Date__c FROM Holiday__c WHERE CALENDAR_YEAR(Start_Date__c) =: sessionList[0].Session_Date__c.year() ]){
                        VacationModel vacObj = new VacationModel();
                        vacObj.Start_Date = holiObj.Start_Date__c;
                        vacObj.End_Date = holiObj.End_Date__c;                
                        vacationList.add(vacObj);    
                    }
                    
                    if(sessionList[0].Type__c == 'Placeholder'){
                        if(String.isNotBlank(sessionList[0].Teacher__c)){
                            sessionList =  [SELECT Id, Start_Time__c, Session_Date__c, Teacher__c, Type__c FROM Session__c 
                                            WHERE Teacher__c =: sessionList[0].Teacher__c AND 
                                            Location__c =: sessionList[0].Location__c AND
                                            Session_Date__c >=: sessionList[0].Session_Date__c AND 
                                            Start_Time__c =: sessionList[0].Start_Time__c AND
                                            Notes__c =: sessionList[0].Notes__c AND
                                            Type__c = 'Placeholder'];
                        }else{
                            sessionList =  [SELECT Id, Start_Time__c, Session_Date__c, Teacher__c, Type__c FROM Session__c 
                                            WHERE Teacher__c = null AND 
                                            Location__c =: sessionList[0].Location__c AND
                                            Session_Date__c >=: sessionList[0].Session_Date__c AND 
                                            Start_Time__c =: sessionList[0].Start_Time__c AND
                                            Notes__c =: sessionList[0].Notes__c AND
                                            Type__c = 'Placeholder'];
                        }               
                    }else{
                        for(Teacher_Leave__c teacherObj :  [SELECT Id, Teacher__c, Start_Date__c, End_Date__c FROM Teacher_Leave__c WHERE Teacher__c  =: sessionList[0].Teacher__c AND Status__c = 'Approved']){
                            VacationModel vacObj = new VacationModel();
                            vacObj.Start_Date = teacherObj.Start_Date__c;
                            vacObj.End_Date = teacherObj.End_Date__c;
                            vacationList.add(vacObj);           
                        }
                        
                        sessionList =  [SELECT Id, Start_Time__c, Session_Date__c, Teacher__c, Type__c, Class__r.Frequency__c, Class_term__c, Class_term__r.Exclude_Public_Holidays__c FROM Session__c 
                                        WHERE Teacher__c =: sessionList[0].Teacher__c AND 
                                        Location__c =: sessionList[0].Location__c AND
                                        Session_Date__c >=: sessionList[0].Session_Date__c AND 
                                        Start_Time__c =: sessionList[0].Start_Time__c AND
                                        DAY_IN_WEEK(Session_Date__c) =: previousDay+1];
                    }            
                }
                
                if(sessionList.size() > 0){
                    string[] strTimeSplit = newStartTime.split(':');
                    Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                      ,Integer.valueOf(strTimeSplit[1]) //min
                                                      ,Integer.valueOf(strTimeSplit[2]) //sec
                                                      ,0);  
                    
                    for(Session__c sessionObj : sessionList){
                        isHoliday = false;
                        Date currentDate = sessionObj.Session_Date__c;
                        if(vacationList.size() > 0 && blufyList.size() > 0 && sessionObj.Type__c != 'Placeholder'){
                            for(VacationModel vObj : vacationList){
                                if(vObj.Start_Date <= currentDate.addDays(dayDiffernce) && vObj.End_Date >= currentDate.addDays(dayDiffernce)){
                                    if((sessionObj.Class__r.Frequency__c == 'Term' && sessionObj.Class_term__c != null && sessionObj.Class_term__r.Exclude_Public_Holidays__c == true) || (sessionObj.Class__r.Frequency__c == 'Monthly' && blufyList[0].Overlap_Holiday_For_Monthly_Session__c == true) ){
                                        sessionObj.type__c =  'Exception';
                                    }else{
                                        isHoliday = true;
                                    }
                                }
                            }
                        }
                        if(!isHoliday){
                            sessionObj.Start_Time__c = startTime;                         
                            sessionObj.Session_Date__c = currentDate.addDays(dayDiffernce);
                            if(String.isNotBlank(parentId)){
                                sessionObj.Teacher__c = parentId;
                            }
                        }
                        
                    }  
                    
                    try{
                        fieldsApiName = new Set<String>{'Start_Time__c','Teacher__c','Type__c'};
                            isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, true);
                        if(isSessionAccessible){
                            update sessionList;                  
                        }
                    }catch(Exception ex){
                        system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
                    }
                }
            }
        }
    }
    
    
    @RemoteAction 
    global static void insertNewSession(String locationId, String teacherId, String newStartTime, String currentDate, String duration, String endDate, String repeat, String description){
        List<Session__c> sessionList = new List<Session__c>();
        Date currentSessionDate = Date.valueOf(currentDate);  
        Boolean isHoliday = false; 
        List<VacationModel> vacationList = new List<VacationModel>();
        if(String.isNotBlank(teacherId)){
            if(FieldPremissionCrudUtility.checkReadPermission('Teacher_Leave__c', new Set<String>{'Id', 'Teacher__c', 'Start_Date__c', 'End_Date__c', 'Status__c'}, false)){
                for(Teacher_Leave__c teacherObj :  [SELECT Id, Teacher__c, Start_Date__c, End_Date__c FROM Teacher_Leave__c WHERE Teacher__c  =: teacherId AND Status__c = 'Approved']){
                    VacationModel vacObj = new VacationModel();
                    vacObj.Start_Date = teacherObj.Start_Date__c;
                    vacObj.End_Date = teacherObj.End_Date__c;
                    vacationList.add(vacObj);           
                }
            }        
        }
        if(FieldPremissionCrudUtility.checkReadPermission('Holiday__c', new Set<String>{'Id', 'Start_Time__c', 'Start_Date__c', 'End_Date__c', 'End_Time__c'}, false)){
            for(Holiday__c holiObj : [SELECT Id, Start_Time__c, Start_Date__c, End_Time__c, End_Date__c FROM Holiday__c WHERE CALENDAR_YEAR(Start_Date__c) =: currentSessionDate.year()]){
                VacationModel vacObj = new VacationModel();
                vacObj.Start_Date = holiObj.Start_Date__c;
                vacObj.End_Date = holiObj.End_Date__c;
                //vacObj.Start_Time = holiObj.Start_Time__c;
                //vacObj.End_Time = holiObj.End_Time__c;
                vacationList.add(vacObj);    
            }
        }
        //fieldsApiName = new Set<String>{'location__c', 'Class__c', 'Session_Date__c', 'Start_Time__c', 'Status__c', 'duration__c', 'Type__c','Teacher__c','Notes__c', 'Duration_Unit__c'};
        fieldsApiName = new Set<String>{'location__c', 'Class__c', 'Session_Date__c', 'Start_Time__c', 'Status__c', 'duration__c', 'Type__c','Teacher__c','Notes__c'};
            isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, true);
        if(isSessionAccessible){
            if(repeat == 'None'){
                Session__c sessionObj = new Session__c();
                string[] strTimeSplit = newStartTime.split(':');
                Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                  ,Integer.valueOf(strTimeSplit[1]) //min
                                                  ,Integer.valueOf(strTimeSplit[2]) //sec
                                                  ,0); 
                sessionObj.location__c = locationId;
                if(String.isNotBlank(teacherId))
                    sessionObj.teacher__c =  teacherId;  
                
                sessionObj.Start_Time__c = startTime; 
                sessionObj.Session_Date__c = currentSessionDate;
                
                strTimeSplit = duration.split(':');
                Integer minutes = (Integer.valueOf(strTimeSplit[0]) * 60) + Integer.valueOf(strTimeSplit[1]);
                sessionObj.duration__c = minutes;
                
              //  sessionObj.Duration_Unit__c = 'Minutes';
                sessionObj.Status__c = 'Scheduled';
                sessionObj.Type__c = 'Placeholder';
                sessionObj.Notes__c = description;
                if(vacationList.size() > 0){
                    for(VacationModel vObj : vacationList){
                        if(vObj.Start_Date <= currentSessionDate && vObj.End_Date >= currentSessionDate){
                            isHoliday = true;
                        }
                    }
                }
                if(!isHoliday){
                    sessionList.add(sessionObj);
                }
            }else{
                Date endSessionDate = Date.valueOf(endDate);        
                Integer dayDiffernce = repeat == 'Weekly' ? 7 : 1;
                
                system.debug('currentSessionDate ->'+currentSessionDate);
                system.debug('endSessionDate ->'+endSessionDate);
                
                while(currentSessionDate <= endSessionDate){
                    isHoliday = false;
                    if(vacationList.size() > 0){
                        for(VacationModel vObj : vacationList){
                            if(vObj.Start_Date <= currentSessionDate && vObj.End_Date >= currentSessionDate){
                                isHoliday = true;
                            }
                        }
                    }
                    if(!isHoliday){
                        Session__c sessionObj = new Session__c();
                        string[] strTimeSplit = newStartTime.split(':');
                        Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                          ,Integer.valueOf(strTimeSplit[1]) //min
                                                          ,Integer.valueOf(strTimeSplit[2]) //sec
                                                          ,0);   
                        sessionObj.location__c = locationId;                               
                        if(String.isNotBlank(teacherId))
                            sessionObj.teacher__c =  teacherId;    
                        
                        sessionObj.Start_Time__c = startTime; 
                        sessionObj.Session_Date__c = currentSessionDate;
                        
                        strTimeSplit = duration.split(':');
                        Integer minutes = (Integer.valueOf(strTimeSplit[0]) * 60) + Integer.valueOf(strTimeSplit[1]);
                        sessionObj.duration__c = minutes;
                        
                       // sessionObj.Duration_Unit__c = 'Minutes';
                        sessionObj.Status__c = 'Scheduled';
                        sessionObj.Type__c = 'Placeholder';
                        sessionObj.Notes__c = description;
                        sessionList.add(sessionObj);
                    }
                    currentSessionDate = currentSessionDate.addDays(dayDiffernce);
                }
            }
            if(sessionList.size() > 0){
                try{
                    insert sessionList;
                }catch(Exception ex){
                    system.debug('ex Error -> '+ ex.getMessage() +' - '+ ex.getLineNumber());
                }
            }
        }
        
    }
    
    @RemoteAction
    global static List<Teacher_Leave__c> getTeacherLeaves(String teacherIds){
        List<Teacher_Leave__c> leaveList = new List<Teacher_Leave__c>();
        Set<String> setId = new Set<String>();
        setId.addAll(teacherIds.split(','));
        isTeacherLeaveAccessible = FieldPremissionCrudUtility.checkReadPermission('Teacher_Leave__c',new Set<String>{'Id','Teacher__c'
            ,'Start_Date__c','End_Date__c','Status__c'}, false);
        if(isTeacherLeaveAccessible){
            if(String.isNotBlank(teacherIds)){
                leaveList = [SELECT Id, Teacher__c, Start_Date__c, End_Date__c FROM Teacher_Leave__c WHERE Status__c = 'Approved' AND Teacher__c IN: setId];
                if(leaveList.size() > 0){
                    return leaveList;
                }   
            }else{
                system.debug('Teacher Leave is not Accessible');
            }
        }
        
        return null;
    }
    
    @RemoteAction
    global static List<Holiday__c> getHolidays(String selectedDate){
        date startDt = date.valueOf(selectedDate); 
        List<Holiday__c> holidayList = new List<Holiday__c>();
        if(FieldPremissionCrudUtility.checkReadPermission('Holiday__c', new Set<String>{'Id', 'Start_Date__c', 'End_Date__c'}, false)){
            holidayList = [SELECT id, Start_Date__c, End_Date__c FROM Holiday__c WHERE CALENDAR_YEAR(Start_Date__c) =: startDt.year()];
            if(holidayList.size() > 0){
                return holidayList;
            }
        }else{
            system.debug('Holiday not Accessible');
        }
        return null;
    }
    
    //    @RemoteAction
    //     global static void rescheduleSessionForStudent(String studentId, String newSessionId){
    //         if(String.isNotBlank(studentId) && String.isNotBlank(newSessionId)){
    //             Student_Session__c studentSessionObj = new Student_Session__c(id = studentId, session__c = newSessionId);
    //             try{
    //                 update studentSessionObj;
    //             }catch(Exception ex){
    //                 //system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
    //             }
    
    //         }
    //     }
    
    /**
Name        :   studentIsExistsForSession
Date        :   11 Mar 2020
Description :   
Developer   :   
*/
    // @RemoteAction
    // global static boolean studentIsExistsForSession(String sessionId, String studentId){
    //     //query on student session and get id of Student(Account) based on session Id
    //     //check studentId to Account so we can find out that student is already exists or not
    //     if(String.isNotBlank(sessionId) && String.isNotBlank(studentId)){
    //         List<Student_session__c> stuSessionList = [SELECT Id, Account__c, Session__c FROM Student_session__c WHERE Session__c =: sessionId];
    //         if(stuSessionList.size() > 0){
    //             for(Student_session__c sobj : stuSessionList){
    //                 if(sobj.Account__c == studentId){
    //                     return true;
    //                 }
    //             }
    //         }
    //     }
    //     return false;      
    // }
    /**
Name        :   updateStudenSessionsInAllSessions
Date        :   11 Mar 2020
Description :   commment code after discussed with Dharam And NITIN 
Developer   :   
*/
    // @RemoteAction
    // global static void updateStudenSessionsInAllSessions(Integer oldDay, Integer newDay, String accId){               
    //     List<student_session__c> sessionList = [SELECT id,Name,Session__r.session_date__c FROM student_session__c WHERE DAY_IN_WEEK(Session__r.session_date__c) =: oldDay+1 AND account__c =: accId];
    //     Map<String,Id> newSessionResMap = new Map<String,Id>();
    //     for(student_session__c sobj : [SELECT id,Name,Session__r.session_date__c FROM student_session__c WHERE DAY_IN_WEEK(Session__r.session_date__c) =: newDay+1 AND account__c =: accId]){
    //         newSessionResMap.put(sobj.Session__r.session_date__c+'', sobj.Session__c);
    //     }
    //     Integer dayDiffernce = newDay - oldDay;
    //     for(student_session__c sessionObj : sessionList){
    //         //Date sessionDate = new Date(sessionObj.Session__r.session_date__c);    
    //         //sessionObj.Session__r.session_date__c.addDays(dayDiffernce);
    //         //sessionDate.addDays(dayDiffernce);
    //         sessionObj.session__c = newSessionResMap.get(sessionObj.Session__r.session_date__c.addDays(dayDiffernce)+'');
    //     }
    //     //system.debug('sessionList->'+sessionList);
    //     try{
    //         update sessionList;
    //     }catch(Exception ex){
    //         //system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
    //     }
    //     //update sessionList;
    
    // }
    
    global class SessionRecordModel{
        public String locationId;
        public String teacherId;
        public List<Session__c> sessionModelList; 
        public List<Session_Resource__c> sessionResourceModelList;
    }
    class VacationModel{        
        Date Start_Date;
        Date End_Date;
        //Time Start_Time;
        //Time End_Time;
    }
}