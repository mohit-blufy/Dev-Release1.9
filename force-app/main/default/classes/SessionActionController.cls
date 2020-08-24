global with sharing class SessionActionController {
    static Set<String> fieldsApiName;
    static boolean isSessionAccessible = false;
    static boolean isStudentSessionAccessible = false;
    static boolean isHistoryAccessible = false;    
    
    /**
    Name        :   fetchSessionsDetail
    Date        :   03 Mar 2020
    Description :   It's use for to get the session details which we can show on session detail modal
    Developer   :   
    */
    @RemoteAction
    global static List<Session__c> fetchSessionsDetail(String sessionId){ 
        if(FieldPremissionCrudUtility.checkReadPermission('Account', new Set<String>{'Id','Name'}, false) && FieldPremissionCrudUtility.checkReadPermission('Class__c', new Set<String>{'Id','Name'}, false)){
            fieldsApiName = new Set<String>{'Id', 'Duration__c', 'Duration_Unit__c', 'Session_date__c', 'Start_Time__c', 'Notes__c', 'Type__c','Lesson__c', 'Module__c'};
                isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c', fieldsApiName, false);
            if(isSessionAccessible){
                String query = 'SELECT Name, Teacher__r.location__r.Name, Teacher__r.Name, Class__r.Name, Duration__c, Duration_Unit__c, Session_date__c, Start_Time__c, Notes__c, Type__c, Lesson__c, Module__c, Class__r.Course__r.Name FROM Session__c ';
                if(String.isNotBlank(sessionId)){
                    query += 'WHERE Id =: sessionId ';
                }                
                List<Session__c> sessionList = Database.query(query);
                if(sessionList.size() > 0){
                    return sessionList;
                }
            }        
        }    
        return null;
    }      
    
    /**
Name        :   fecthSessionResourceDetail
Date        :   17 Mar 2020
Description :   commment function after discussed with Dharam And NITIN 
Developer   :   
*/
    // @RemoteAction
    // global static  List<Session_Resource__c > fecthSessionResourceDetail(String resourceId){
    //     String query = 'SELECT id, Resource__r.Name, Session__r.Teacher__r.location__r.Name, Session__r.Teacher__r.Name , Session__r.Class__r.Name , Session__r.Duration__c, Session__r.Duration_Unit__c, Session__r.Session_date__c , Session__r.Start_Time__c  FROM Session_Resource__c  ';
    //     if(String.isNotBlank(resourceId)){
    //         query += 'WHERE Id =: resourceId ';
    //     }
    //     List<Session_Resource__c > sessionList = Database.query(query);
    //     if(sessionList.size() > 0){
    //         return sessionList;
    //     }
    //     return null;
    // }
    
    /**
Name        :   getSessionStudent
Date        :   04 Mar 2020
Description :   it's use for to get the detail from Student_Session__c based on session id
Developer   :   
*/
    @RemoteAction
    global static List<Student_Session__c> getSessionStudent(string sessionId){
        List<Student_Session__c> studentList = new List<Student_Session__c>();
        if(String.isNotBlank(sessionId)){
            fieldsApiName = new Set<String>{'Id', 'Status__c', 'Notes__c'};         
                if(FieldPremissionCrudUtility.checkReadPermission('Session__c', new Set<String>{'Id','Name'}, false) &&  FieldPremissionCrudUtility.checkReadPermission('Account', new Set<String>{'Id','Name'}, false) && FieldPremissionCrudUtility.checkReadPermission('Class__c', new Set<String>{'Id','Name'}, false)){
                    isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Student_Session__c', fieldsApiName, false);
                    if(isStudentSessionAccessible){
                        studentList = StudentSessionService.getBySessionId(new Set<Id>{sessionId});//[SELECT Session__c, Session__r.Teacher__r.Name, Account__r.Name, Session__r.Class__r.Name, Status__c, Notes__c, Session__r.Class__r.Course__r.Name, Enrollment__c  FROM Student_Session__c WHERE Session__c =: sessionId];
                        if(studentList.size() > 0){
                            return studentList;
                        }
                    }
                }        
        }
        return studentList;
    }
    
    /**
    Name        :   getSessionStudentForAssessment
    Date        :   09 jun 2020
    Description :   It's used for fetching student session details, fetcg=hing grade picklist from Assessment__c.
    Developer   :   
    */
    
     @RemoteAction
    global static List<StudentSessionAssModel> getSessionStudentForAssessment(string sessionId){
        List<StudentSessionAssModel> studentSessAssList = new List<StudentSessionAssModel>();
        List<User_Interface_Settings__mdt> userList = UserInterfaceConfigService.getAssessmentData();
        if(userList.size() > 0){
            List<studentAssessmentModal> studentAssessmentList = new List<studentAssessmentModal>();
            for(User_Interface_Settings__mdt uiObj : userList){
                studentAssessmentModal  sObj = new studentAssessmentModal();
                sobj.dataType = uiObj.Data_Type__c;
                sobj.label = uiObj.MasterLabel;
                sobj.name = uiObj.Field_API_Name__c;
                sobj.sequence = uiObj.Sequence__c;
                sobj.require = uiObj.Required__c;
                if(uiObj.Data_Type__c == 'Picklist'){
                    sobj.picklistVal = UtilityClass.getPickValues(ConstantClass.nameSpace+uiObj.Object_API_Name__c, ConstantClass.nameSpace+uiObj.Field_API_Name__c);
                }
                studentAssessmentList.add(sObj);
            }
            // List<String> grdList = UtilityClass.getPickValues('Assessment__c', 'Score_Grade__c');
            for(Student_Session__c stu: getSessionStudent(sessionId)){
                StudentSessionAssModel stuSessAss = new StudentSessionAssModel(stu, false, studentAssessmentList); 
                studentSessAssList.add(stuSessAss);
            }
            System.debug('studentSessAssList@@'+studentSessAssList);
            return studentSessAssList;
        }
        return null;
    }

    /**
    Name        :   getCrsAssessmentNames
    Date        :   10 Jun 2020
    Description :   It's used for fetching Name field from Course_Assessment__c and populate the same in picklist.
    Developer   :   
    */
    @RemoteAction
    global static List<Course_Assessment__c> getCrsAssessmentNames(String crsId){
        System.debug('crsId@@@'+crsId);
        List<Course_Assessment__c> crsAssessmentPlist = CourseAssessmentService.getByCourseId(new Set<String>{crsId});//[SELECT Name,Course__c FROM Course_Assessment__c where Course__c =: crsId];
        system.debug('crsAssessmentPlist-->'+crsAssessmentPlist);
        if (crsAssessmentPlist.size() > 0){
            return crsAssessmentPlist; 
        }
        return crsAssessmentPlist;
    }
    
    
    /**
    Name        :   insertAssessmentRecords
    Date        :   12 Jun 2020
    Description :   It's used for inserting assessment records as per student selection and it's corresponding grade.
    Developer   :   
    */
    @RemoteAction
    global static void insertAssessmentRecords(List<StudentSessionAssModel> studRecords, String crsAssId){      
        List<Assessment__c> assessList = new List<Assessment__c>();
        if (String.isBlank(crsAssId))
            crsAssId = null;
        //system.debug('studRecords'+studRecords);
        if(studRecords != null ){
            for (StudentSessionAssModel obj : studRecords){
               // system.debug('obj.isSelect'+obj.isSelect);
                if (obj.isSelect){
                    Assessment__c assessmentObj = new Assessment__c();                    
                    assessmentObj.put(ConstantClass.nameSpace+'Student__c',obj.stuSess.Account__c);
                    assessmentObj.put(ConstantClass.nameSpace+'Class__c',obj.stuSess.Session__r.Class__c);
                    assessmentObj.put(ConstantClass.nameSpace+'Session__c',obj.stuSess.Session__c);
                    assessmentObj.put(ConstantClass.nameSpace+'Assessor__c',obj.stuSess.Session__r.Teacher__c);
                    assessmentObj.put(ConstantClass.nameSpace+'Enrollment__c',obj.stuSess.Enrollment__c);
                    assessmentObj.put(ConstantClass.nameSpace+'Score_Grade__c',obj.selectedGrade);
                    assessmentObj.put(ConstantClass.nameSpace+'Course_Assessment__c',crsAssId);
                    assessmentObj.put(ConstantClass.nameSpace+'Status__c',ConstantClass.completedStatus);
                    assessmentObj.put(ConstantClass.nameSpace+'Assessment_Date__c',Date.Today());
                    if(obj.keyValues != null&& obj.keyValues.size() > 0){
                        for(KeyValuesWrapper keyValueObj : obj.keyValues){
                            if(keyValueObj.type == 'Date'){
                                assessmentObj.put(keyValueObj.name,Date.valueOf(keyValueObj.value));
                            }else if(keyValueObj.type == 'Number'){
                                assessmentObj.put(keyValueObj.name,Decimal.valueOf(keyValueObj.value));
                            }else if(keyValueObj.type == 'Boolean'){
                                assessmentObj.put(keyValueObj.name,Boolean.valueOf(keyValueObj.value));
                            }else{
                                assessmentObj.put(keyValueObj.name,keyValueObj.value);
                            }                        
                        }
                    }
                    assessList.add(assessmentObj);
                    //System.debug('assessList@@'+assessmentObj);       
                }
            }
            if (assessList.size() > 0){
                AssessmentService.insertRecords(assessList);
                // try{
                //     insert assessList;
                // }catch(Exception ex){
                //     system.debug('Error -> '+ex.getMessage());                   
                // }
            }
        }
    }
    
    
    /**
    Name        :   changeStudentStatus
    Date        :   04 Mar 2020
    Description :   it's use for change the status of students
    Developer   :   
    */
    @RemoteAction
    global static void changeStudentsStatus(String sessionStudentsId,String status, String sessionId){ 
        List<Student_Session__c> studentList = new List<Student_Session__c>();
        fieldsApiName = new Set<String>{'Status__c'};
            isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Student_Session__c', fieldsApiName, true);
        system.debug('isStudentSessionAccessible-->'+isStudentSessionAccessible);
        if(isStudentSessionAccessible){
            if(String.isNotBlank(sessionStudentsId)){
                List<String> ids = sessionStudentsId.split(',');
                for(String strObj : ids){
                    Student_Session__c sessionObj = new Student_Session__c(id = strObj);
                    if(status == 'Completed'){
                        sessionObj.Status__c = 'Attended';
                    }else if(status == 'No-show'){
                        sessionObj.Status__c = 'Not Attended';
                    }  
                    studentList.add(sessionObj);
                }
                if(studentList.size() > 0){
                    try{
                        update studentList;
                        if(String.isNotBlank(sessionId) && status == 'Completed'){
                            session__c sessObj = new session__c(id = sessionId);
                            sessObj.Attendance_Update__c = true;
                            update sessObj;
                            
                        }
                    }catch(Exception ex){
                        system.debug('Error -> '+ex.getMessage());                   
                    }
                }
            }
        }
    }

    /**
    Name        :   changeStudentStatus
    Date        :   04 Mar 2020
    Description :   it's use for change the status of students
    Developer   :   
    */
    @RemoteAction
    global static void changeStudentStatus(String sessionStudentsId,String status){ 
        //we are not using this function
    }
    
    /**
    Name        :   cancelStudentForSession
    Date        :   05 Mar 2020
    Description :   it's use for cancel student session
    Developer   :   
    */
    @RemoteAction
    global static void cancelStudentForSession(String sessionStudentsId){
        fieldsApiName = new Set<String>{'Status__c'};
            isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Student_Session__c', fieldsApiName, true);
        if(isStudentSessionAccessible){
            if(String.isNotBlank(sessionStudentsId)){
                Student_Session__c sessionStuObj = new Student_Session__c(id = sessionStudentsId);            
                sessionStuObj.status__c = ConstantClass.cancelledStatus;
                try{
                    StudentSessionService.updateStudentSessionRecords(new List<Student_Session__c>{sessionStuObj});
                    //update sessionStuObj;
                }catch(Exception ex){
                    system.debug('Error -> '+ex.getMessage());                   
                }
            }
        }
    }
    
    /**
    Name        :   cancelSession
    Date        :   05 Mar 2020
    Description :   it's use for cancel the session records
    Developer   :   
    */
    @RemoteAction
    global static void cancelSession(String sessionId){
        if(String.isNotBlank(sessionId)){
            Session__c sessionObj = new Session__c(id = sessionId);            
            sessionObj.status__c = ConstantClass.cancelledStatus;
            try{
                SessionService.updateSessionRecords(new List<Session__c>{sessionObj});
                //update sessionObj;
            }catch(Exception ex){
                system.debug('Error -> '+ex.getMessage());                   
            }
        }
    }
    
    /**
    Name        :   getSessionHistoryRecords
    Date        :   12 Mar 2020
    Description :   it's use for to get session history
    Developer   :   
    */
    @RemoteAction
    global static List<SessionHistoryModal> getSessionHistoryRecords(String sessionId){
        
        List<SessionHistoryModal> sessionHistoryModalList = new List<SessionHistoryModal>();       
        fieldsApiName = new Set<String>{'Id', 'ParentId',  'CreatedById', 'CreatedDate', 'Field', 'OldValue', 'NewValue'};
            isHistoryAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__History', fieldsApiName, false); 
        if(isHistoryAccessible){
            if(String.isNotBlank(sessionId)){
                for(Session__History sessionHistoryObj : [SELECT Id, ParentId, CreatedBy.Name, CreatedById, CreatedDate, Field, OldValue, NewValue FROM Session__History WHERE ParentId =: sessionId ORDER BY CreatedDate desc]){
                    SessionHistoryModal sessionModalObj = new SessionHistoryModal();
                    String description = '';
                    sessionModalObj.historyBy = sessionHistoryObj.CreatedBy.Name;
                    sessionModalObj.createdDate = sessionHistoryObj.CreatedDate.format('EEE, MMM dd yyyy h:mm a');
                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                    Schema.SObjectType leadSchema = schemaMap.get('Session__c');
                    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();                                                                                   
                    description += 'Session ';
                    if(sessionHistoryObj.Field != 'created' && fieldMap.containsKey(sessionHistoryObj.Field)){
                        description +=  fieldMap.get(sessionHistoryObj.Field).getDescribe().getLabel();
                        String[] strTimeSplit;
                        String newTime;
                        description += ' changed from ';                  
                        if(sessionHistoryObj.OldValue instanceOf TIME && sessionHistoryObj.NewValue instanceOf TIME){
                            strTimeSplit = String.valueOf(sessionHistoryObj.OldValue).split(':');
                            newTime = strTimeSplit[0] +':'+strTimeSplit[1] +':00';  
                            description +=  newTime + ' to '; 
                            
                            strTimeSplit = String.valueOf(sessionHistoryObj.NewValue).split(':');
                            newTime = strTimeSplit[0] +':'+strTimeSplit[1] +':00';    
                            description +=  newTime; 
                        }else if(sessionHistoryObj.OldValue instanceOf date && sessionHistoryObj.NewValue instanceOf date){
                            description += Date.valueOf(sessionHistoryObj.OldValue).format()+' to '+Date.valueOf(sessionHistoryObj.NewValue).format();
                        }else{
                            description += sessionHistoryObj.OldValue+' to '+sessionHistoryObj.NewValue;
                        }                   
                    }else{
                        description += sessionHistoryObj.Field;
                    }
                    sessionModalObj.description = description;
                    sessionHistoryModalList.add(sessionModalObj);
                }           
            }
        }
        return sessionHistoryModalList;
    }
    // /**
    // Name        :   
    // Date        :   13 Mar 2020
    // Description :   
    // Developer   :   
    // */
    // @RemoteAction
     //global static List<Account> getStudentRecords(String keywordToSearch){
    //     Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
    //     //system.debug('devRecordTypeId '+devRecordTypeId);
    //     String query = 'SELECT Id, Name, PersonEmail, Phone FROM Account WHERE  recordtype.Id =: devRecordTypeId';
    //     if(String.isNotBlank(keywordToSearch)){
    //         query += ' AND Name like  \'%' + keywordToSearch + '%\'';
    //     }else{
    //         query += ' LIMIT 5';
    //     }
    //     //system.debug('query '+query);
    //     List<Account> accList = Database.query(query);
    //     //system.debug('accList->' +accList);
    //     if(accList.size() > 0){
    //         return accList;
    //     }
    //     return null;
     //}
    
    global class StudentSessionAssModel{
        public Student_Session__c stuSess;           
        public Boolean isSelect;   
        public String selectedGrade;        
        public List<studentAssessmentModal> studentAssList;
        public List<KeyValuesWrapper> keyValues;
        
        public StudentSessionAssModel(Student_Session__c stuSess, Boolean isSelect,  List<studentAssessmentModal> studentAssList){
            this.stuSess  = stuSess;
            this.isSelect = isSelect;        
            this.studentAssList = studentAssList;
        }
    }
    
    global class SessionHistoryModal{
        public String createdDate;           
        public String historyBy;        
        public String description;        
    }
    class studentAssessmentModal{
        public string dataType;
        public string label;
        public string name;
        public Decimal sequence;
        public Boolean require;
        public List<String> picklistVal;         
    }
    class KeyValuesWrapper{
        public String name;
        public String value;
        public String type;
    }
}