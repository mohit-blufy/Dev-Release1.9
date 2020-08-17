global with sharing class FullCalendarController {
    
    public String selectedTeacher{get;set;}
    public String selectedLocation{get;set;}
    public String selectedCourse{get;set;}
    //public String selectedResourcesType {get;set;}
    public String selectedRoomType{get;set;}
    public List<SelectOption> locationList{get;set;}
    public List<SelectOption> teacherList{get;set;}  
    public List<SelectOption> courseList{get;set;}
    public List<SelectOption> classList{get;set;}
    //public List<SelectOption> resourcesList{get;set;}
    //public List<SelectOption> resourcesTypeList{get;set;}
    public List<SelectOption> roomTypeList{get;set;}
    public List<SelectOption> roomList{get;set;}
    public Full_Calendar_Configuration__mdt calendarConfigMetadataObject {get;set;}
    public boolean isUserHaveAllAccess{get;set;}
    public String nameSpace{get;set;}
    private List<Full_Calendar_Configuration__mdt> calendarConfigMetaList;
    private Map<Id, String> teacherMap;
    private String profileName;
    private Set<Id> teacherLocationIds;
    //public List<Account> allTeacherList {get;set;}    
    
    public FullCalendarController(){
        Set<String> fieldsApiName = new Set<String>{'Id','Name'};
        boolean isAccountAccessible;
        boolean isCourseAccessible;
        boolean isClassAccessible;
        boolean isRommAccessible;
        isAccountAccessible = FieldPremissionCrudUtility.checkReadPermission('Account',fieldsApiName,false);               
        isCourseAccessible = FieldPremissionCrudUtility.checkReadPermission('Course__c',fieldsApiName,false);
        fieldsApiName.add('Course__c');
        fieldsApiName.add('Teacher__c');
        isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Course__c',fieldsApiName,false);
        nameSpace = ConstantClass.nameSpace;
        fieldsApiName = new Set<String>{'Id','Name','Type__c'};
        isRommAccessible = FieldPremissionCrudUtility.checkReadPermission('Room__c',fieldsApiName,false);
        
        if(isAccountAccessible && isCourseAccessible && isCourseAccessible && isRommAccessible){
            isUserHaveAllAccess = true;
            locationList  = new list<SelectOption>();
            teacherList   = new list<SelectOption>();
            courseList    = new list<SelectOption>();
            classList     = new list<SelectOption>();
            //resourcesList = new list<SelectOption>();
            roomTypeList  = new list<SelectOption>();
            calendarConfigMetaList = new list<Full_Calendar_Configuration__mdt>();            
            teacherMap = new Map<Id, String>();
            teacherLocationIds = new Set<Id>();
            //resourcesTypeList = new list<SelectOption>();
            
            getFullCalendatMetadata();
            getProfileName();
            
            if(profileName == 'Teacher'){
                populateTeachers();
                populateLocations();
                if(locationList.size() > 0){
                    selectedLocation = locationList.get(0).getValue();
                }
            }else{
                populateLocations(); 
                if(locationList.size() > 0){
                    selectedLocation = locationList.get(0).getValue();  
                    populateTeachers();                  
                }               
            }            
            
            
            if(teacherList.size() > 0){
                selectedTeacher = teacherList.get(0).getValue();
                populateCourses();
            }         
            if(courseList.size() > 0){
                selectedCourse = courseList.get(0).getValue();
                populateClasses();
            }   

            populateRoomType();
            if(roomTypeList.size() > 0){
                selectedRoomType = roomTypeList.get(0).getValue();
            }
            if(String.isNotBlank(selectedLocation) && String.isNotBlank(selectedRoomType)){
                populateRoom();
            }
        }else{
            isUserHaveAllAccess = false;
        }
        //populateResourceType();
        //selectedResourcesType = resourcesTypeList.get(0).getValue();
        
        //populateResource();
    }
    /**
Name        :   getProfileName
Date        :   24 Apr 2020
Description :   Function is use for to get current user profile name
Developer   :  
*/
    private void getProfileName(){
        Id profileId = userinfo.getProfileId();
        profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    }
    
    /**
Name        :   populateTeachers
Date        :   19 Feb 2020
Description :   Function is use for to get avaiable accounts records which records type is teacher and have lookup based on Location Id 
Developer   :   
updated     :   30 Mar 2020
Description :   Now we fetch the teacher records from teacher_working_hours based on locationid
*/
    private void populateTeachers(){
        //allTeacherList = new List<Account>();
        teacherList = new List<SelectOption>();
        teacherMap = new Map<Id, String>();
        //system.debug('selectedLocation '+selectedLocation);            
        // Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Teacher').getRecordTypeId();    
        if(profileName != 'Teacher'){
            teacherList.add( new SelectOption( 'All_Teachers', 'All Teachers'));  
            for (Teacher_Working_Hours__c teacherObj : TeacherWorkingHoursService.getByLocationIdAndTeacherRecordsTypeId(new Set<String>{selectedLocation})){//[SELECT Id, Teacher__r.id, teacher__r.Name FROM Teacher_Working_Hours__c WHERE location__c =: selectedLocation AND teacher__r.recordtype.Id =: ConstantClass.teacherRecordTypeId]
                //teacherList.add( new SelectOption( teacherObj.Teacher__r.id, teacherObj.teacher__r.Name ));
                teacherMap.put( teacherObj.Teacher__r.id, teacherObj.teacher__r.Name);
            } 
            system.debug('teacherMap '+teacherMap);
            for(Id teacherId : teacherMap.keySet()){
                teacherList.add( new SelectOption( teacherId, teacherMap.get(teacherId) ));
            }
        }else{
            List<account> teachList = [SELECT Id, Name FROM Account WHERE recordtype.Id =: ConstantClass.teacherRecordTypeId AND Teacher_user__c =: UserInfo.getUserId()];
            if(teachList.size() > 0){
                teacherList.add( new SelectOption( teachList[0].Id ,teachList[0].Name ));
            }
        }
        
        // for(Account accObj : [SELECT Id,Name FROM Account WHERE recordtype.Id =: ConstantClass.teacherRecordTypeId AND Location__c =: selectedLocation]){
        //     teacherList.add( new SelectOption( accObj.Id, accObj.name ));
        //    // allTeacherList.add(accObj);
        // }        
        
    }
    
    /**
Name        :   populateLocations
Date        :   19 Feb 2020
Description :   Function is use for to get avaiable accounts records which records type is Location
Developer   :   
*/
    private void populateLocations(){
        //Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();            
        if(profileName != 'Teacher'){
            for(Account accObj : [SELECT Id,Name FROM Account WHERE recordtype.Id =: ConstantClass.locationRecordsTypeId]){
                locationList.add( new SelectOption( accObj.Id, accObj.name ));
            }        
        }else if(profileName == 'Teacher' && teacherList.size() > 0){
            for(Teacher_Working_Hours__c tlObj : TeacherWorkingHoursService.getByTeacherId(new Set<String>{teacherList.get(0).getValue()})){//[SELECT Id, Location__c FROM Teacher_Working_Hours__c WHERE Teacher__c =: teacherList.get(0).getValue()]
                teacherLocationIds.add(tlObj.Location__c);
            }
            if(teacherLocationIds.size() > 0){
                for(Account accObj : [SELECT Id,Name FROM Account WHERE recordtype.Id =: ConstantClass.locationRecordsTypeId AND Id IN: teacherLocationIds]){
                    locationList.add( new SelectOption( accObj.Id, accObj.name ));
                } 
            }
        }
        //system.debug('locationList->'+locationList.get(0));        
    }
    
    /**
Name        :   popluateCourses
Date        :   24 Feb 2020
Description :   Function is use for to get avaiable courses from course object
Developer   :   
*/
    private void populateCourses(){
        courseList  = new list<SelectOption>();
        courseList.add(new SelectOption('All_Courses', 'All Courses'));
        set<Id> courseId = new set<Id>();
        set<String> teacherIds = new set<String>();
        String status = ConstantClass.inActiveCourse;
        String query = 'SELECT Id, Name FROM Course__c WHERE Status__c !=: status ';
        system.debug('teacherMap '+teacherMap);
        if(selectedTeacher == 'All_Teachers' && !teacherMap.isEmpty()){           
            for(id teachId : teacherMap.keySet()){
                teacherIds.add(teachId+'');
            }
        }else{
            teacherIds.add(selectedTeacher);
        }
        if(String.isNotBlank(selectedTeacher) && teacherIds.size() > 0){
            for(Class__c classObj : ClassService.getByTeacherId(teacherIds)){//[SELECT id, Course__c FROM Class__c WHERE Teacher__c IN: teacherIds]
                if(classObj.Course__c != null)
                    courseId.add(classObj.Course__c);
            }
        }
        if(courseId.size() > 0){
            query += ' AND Id IN: courseId';
        }
        system.debug('selectedTeacher'+selectedTeacher);
        system.debug('coursequery'+courseId);
        system.debug('coursequery'+query);
        if(courseId.size() > 0){
            for(Course__c courObj : Database.query(query)){
                courseList.add(new SelectOption(courObj.Id, courObj.Name));
            }
        }
        
    }
    
    /**
Name        :   populateClasses
Date        :   24 Feb 2020
Description :   Function is use for to get avaiable Classes from Class object
Developer   :   
*/
    private void populateClasses(){
        classList  = new list<SelectOption>();
        classList.add(new SelectOption('All_Class', 'All Class'));
        String query = 'SELECT Id, Course__c, Name, Teacher__c FROM Class__c WHERE ';
        //system.debug('selectedCourse  ->'+selectedCourse);
        if(String.isNotBlank(selectedCourse) && selectedCourse != 'All_Courses'){
            query += ' Course__c =: selectedCourse AND ';
        }
        if(String.isNotBlank(selectedTeacher) && selectedTeacher == 'All_Teachers' && teacherList.size() > 1){
            query += 'Teacher__c IN (';
            for(SelectOption selectOpt : teacherList){
                if(selectOpt.getValue() != 'All_Teachers')
                    query += '\''+string.escapeSingleQuotes(selectOpt.getValue())+ '\',';
            }
            query = query.removeEnd(',');
            query += ') AND ';
        }else if(String.isNotBlank(selectedTeacher) && selectedTeacher != 'All_Teachers'){
            query += ' Teacher__c =: selectedTeacher AND';
        }
        if(String.isNotBlank(selectedLocation)){
            query += ' Location__c =: selectedLocation';
        }else{
            query = query.removeEnd(' AND');    
        }    
        //system.debug('selectedTeacher '+selectedTeacher);
        //system.debug('selectedLocation '+selectedLocation);
        system.debug(query);
        for(Class__c classObj : Database.query(query)){
            classList.add(new SelectOption(classObj.Id, classObj.Name));
        }
    }
    
    /**
Name        :   refreshFilters
Date        :   21 Feb 2020
Description :   Function is use for to refresh the teacher list when location is changed
Developer   :   
*/
    public void refreshFilters(){
        populateTeachers();
        selectedTeacher = teacherList.get(0).getValue();
        populateCourses();
        populateClasses();
        populateRoom();
        //populateResource();        
        //system.debug('selectedLocation'+selectedLocation);
    }
    
    /**
Name        :   getTodayDate
Date        :   19 Feb 2020
Description :   Function is use for to get currrent date for full calendar
Developer   :   
*/
    public String getTodayDate(){
        Datetime myDT = Datetime.now();
        return myDT.format('YYYY-MM-dd');       
    }  
    
    // commment function after discussed with Dharam And NITIN 
    // private void populateResourceType(){
    //     Schema.DescribeFieldResult fieldResult = Resource__c.Type__c.getDescribe();
    //     resourcesTypeList.add(new SelectOption('All_Resources_Type','All Resources Type'));
    //     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    //     for( Schema.PicklistEntry pickListVal : ple){
    //         resourcesTypeList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
    //     } 
    // }
    
    //commment line after discussed with Dharam And NITIN 
    // private void populateResource(){
    //     resourcesList = new List<SelectOption>();
    //     String query = 'SELECT Id,Name FROM Resource__c WHERE ';
    //     if(String.isNotBlank(selectedResourcesType) && selectedResourcesType != 'All_Resources_Type'){
    //      	   query += ' Type__c =: selectedResourcesType AND ';
    //     }
    //     query += ' Location__c =: selectedLocation';
    //     resourcesList.add(new SelectOption('All_Resources', 'All Resources'));
    //     for(Resource__c resObj : Database.query(query)){
    //         resourcesList.add(new SelectOption(resObj.id, resObj.Name));
    //     }
    // }
    //commment line after discussed with Dharam And NITIN 
    // public void refreshResources(){
    //     populateResource();       
    // }

    /**
    Name        :   populateRoomType
    Date        :   21 JULY 2020
    Description :   Function is use for to get type of room 
    Developer   :   
    */
    private void populateRoomType(){        
        Schema.DescribeFieldResult fieldResult = Room__c.Type__c.getDescribe();
         roomTypeList.add(new SelectOption('All_Room_Types','All Room Types'));
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            roomTypeList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
            system.debug(pickListVal.getLabel()+'-'+ pickListVal.getValue());
        } 
    }

    /**
    Name        :   populateRoom
    Date        :   21 JULY 2020
    Description :   
    Developer   :   
    */
    private void populateRoom(){
        roomList = new List<SelectOption>();
        String roomTypeValues = '';
        if(selectedRoomType == 'All_Room_Types'){
            for(SelectOption selectOpt : roomTypeList){
                if(selectOpt.getValue() != 'All_Room_Types')
                roomTypeValues += '\''+string.escapeSingleQuotes(selectOpt.getValue())+ '\',';
            }            
            roomTypeValues = roomTypeValues.removeEnd(',');
        }else{
            roomTypeValues = '\''+string.escapeSingleQuotes(selectedRoomType)+ '\'';
        }
        List<Room__c> roomRecordList = RoomService.getRooms(selectedLocation, roomTypeValues);
        if(roomRecordList.size() > 0){
            roomList.add(new SelectOption('All_Rooms', 'All Rooms'));
            for(Room__c roomObj : roomRecordList){
                roomList.add(new SelectOption(roomObj.id, roomObj.Name));
            }
        }
    }

    public void refreshRoom(){
            populateRoom();       
    }

    public void refreshClasses(){
        populateClasses();
    }
    
    public void refreshCourseAndClasses(){
        populateCourses();
        if(String.isNotBlank(selectedTeacher) && selectedTeacher != 'All_Teachers'){
            selectedCourse = courseList.get(0).getValue();
        }    
        populateClasses();
    }
    
    private void getFullCalendatMetadata(){        
        Boolean isFullCalConfigmdtAccesible = FieldPremissionCrudUtility.checkReadPermission('Full_Calendar_Configuration__mdt', new Set<String>{'Id',
            'Mode_Button_Color__c','Scheduler_License_Key__c','Selected_Mode_Button_Color__c','Selected_View_Button_Color__c','View_Button_Color__c',
            'Non_Business_Hours_Color__c','Modal_Header_Footer_Color__c','Business_Hours_Color__c','Calendar_Border_Color__c'}, false);
        if(isFullCalConfigmdtAccesible){
            calendarConfigMetaList = [SELECT Mode_Button_Color__c,Scheduler_License_Key__c, Selected_Mode_Button_Color__c, Selected_View_Button_Color__c, View_Button_Color__c,Non_Business_Hours_Color__c, Modal_Header_Footer_Color__c, Business_Hours_Color__c, Calendar_Border_Color__c  
                                      FROM Full_Calendar_Configuration__mdt LIMIT 1];       
            calendarConfigMetadataObject = calendarConfigMetaList.get(0);
            
        }
        //system.debug('calendarConfigMetaList  -> '+calendarConfigMetaList);
    }
}