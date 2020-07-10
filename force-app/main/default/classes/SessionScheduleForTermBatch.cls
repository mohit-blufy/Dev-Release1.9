global with sharing class SessionScheduleForTermBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Id','Name','Next_Schedule_Date__c',
            'Last_Session_Date__c','Start_Date__c','Advance_Scheduling__c','Start_Time__c','Teacher__c','Duration__c','Days_of_Week__c','Status__c',
            'Sessions__c','Location__c','Auto_Schedule__c','Exclude_Public_Holidays__c','Frequency__c','Advance_Scheduling_Unit__c',
            'Last_Scheduled_ClassTerm__c'},false);
        Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c',new Set<String>{'Id','Sequence__c'},false);
        Boolean isClsSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Class_Session__c', new Set<String>{'Id','Name',
            'Duration__c','Start_Time__c','Class__c'}, false);
        Boolean isClsTermsAccessible = FieldPremissionCrudUtility.checkReadPermission('Class_Term__c', new Set<String>{'Id','Name',
            'Sequence__c','Class__c','Start_Date__c','End_Date__c','Sequence__c','Sessions__c'}, false);
        Boolean isEnrolmentAccessible = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c', new Set<String>{'Id','Name',
            'Enrollment_End_Date__c','Student__c','Type__c'}, false);
        
        if(isSessionAccessible && isClassAccessible && isEnrolmentAccessible && isClsSessionAccessible && isClsTermsAccessible){
            //**************Retrieving Class with Open Status, Term Frequency,Advance Scheduling Unit is Term(s), Auto Schedule is true & Next Schedule Date is 
            //Today along with related Sessions,Class Session,Class Term & Enrollment Records***************************
            String query = 'SELECT Id,Name,Next_Schedule_Date__c,Last_Session_Date__c,Start_Date__c,Advance_Scheduling__c,Location__c,Auto_Schedule__c, ';
            query += ' Start_Time__c,Teacher__c,Duration__c,Days_of_Week__c,Sessions__c,Last_Scheduled_ClassTerm__c,Exclude_Public_Holidays__c, ';
            query += ' (SELECT Id,Name,Duration__c,Start_Time__c FROM Class_Sessions__r ORDER BY Start_Time__c), ';
            query += ' (SELECT Id,Name,Class__c,Start_Date__c,End_Date__c,Sequence__c,Sessions__c ';
            query += ' FROM Class_Terms__r ORDER BY Sequence__c), ';
            query += ' (SELECT Id,Name,Enrollment_End_Date__c,Student__c,Type__c FROM Enrollments__r), ';
            query += ' (SELECT Id,Sequence__c FROM Sessions__r ORDER BY Sequence__c DESC LIMIT 1) FROM Class__c ';
            query += ' WHERE Auto_Schedule__c = true AND Advance_Scheduling__c != NULL AND Status__c =\'Open\' AND Frequency__c = \'Term\' ';
            query += ' AND Advance_Scheduling_Unit__c = \'Term(s)\' AND Next_Schedule_Date__c = TODAY';
            return Database.getQueryLocator(query);
        }
        else
            System.debug('FLS NOT Found');
        return null;
    }
    
    global void execute(Database.BatchableContext bc, List<Class__c> listClass){
        try{
            
            Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Next_Schedule_Date__c',
                'Last_Session_Date__c','Last_Session_Scheduled_Date__c','Last_Scheduled_ClassTerm__c'},true);
            
            Boolean isStudentSessionReadAccessible = FieldPremissionCrudUtility.checkReadPermission('Student_Session__c',new Set<String>{'Id',
                'Session__c','Name','Status__c','Enrollment__c','Account__c'},false);
            
            Boolean isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Student_Session__c',new Set<String>{'Status__c',
                'Enrollment__c','Account__c'},true);
            
            Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c',new Set<String>{'Sequence__c','Class__c',
                'Teacher__c','Session_Date__c','Start_Time__c','Status__c','Duration__c','Type__c','Location__c'},true);
            
            Boolean isHolidayAccessible = FieldPremissionCrudUtility.checkReadPermission('Holiday__c', new Set<String>{'Id','Start_Date__c','End_Date__c','Start_Time__c','End_Time__c'}, false);
            Boolean isTchrLeaveyAccessible = FieldPremissionCrudUtility.checkReadPermission('Teacher_Leave__c', new Set<String>{'Id', 'Name', 
                'Status__c', 'Start_Date__c', 'End_Date__c','Teacher__c'}, false);
            Boolean isTchrWrkHressible = FieldPremissionCrudUtility.checkReadPermission('Teacher_Working_Hours__c', new Set<String>{'Id','Day__c',
                'End_Time__c','Start_Time__c','Active__c','Teacher__c'}, false);
            Boolean isTermAccessible = FieldPremissionCrudUtility.checkReadPermission('Term__c',new Set<String>{'Id','Name','Start_Date__c',
                'End_Date__c','Sessions__c','Status__c','Sequence__c'},false);
            Boolean isEnrolmentAccessible = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c', new Set<String>{'Id','Name',
                'Enrollment_End_Date__c','Student__c','Type__c'}, false);
            Boolean isClsTermAccessible = FieldPremissionCrudUtility.checkReadPermission('Class_Term__c',new Set<String>{'Name','Start_Date__c',
                'End_Date__c','Sessions__c','Status__c','Sequence__c','Term__c'},true);
            
            
            if(isClassAccessible && isStudentSessionReadAccessible && isHolidayAccessible && isTchrLeaveyAccessible && isTchrWrkHressible && isTermAccessible
               && isEnrolmentAccessible && isStudentSessionAccessible && isSessionAccessible && isClsTermAccessible ){
                   List<Session__c> listSessionToInsert = new List<Session__c>();
                   List<Class__c> listClassToUpdate = new List<Class__c>();
                   List<Class_Term__c> listClassTermToUpdate = new List<Class_Term__c>();
                   List<Student_Session__c> listStudentSession = new List<Student_Session__c>();
                   Map<String,List<Session__c>> mapClassIdToSessions = new Map<String,List<Session__c>>();
                   
                   Set<String> setTeacherId = new Set<String>();
                   List<Holiday__c> listOfHolidays = new List<Holiday__c>();
                   Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
                   Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
                   
                   //********************Retrieving Teacher Id with Auto Schedule True for creating sessions of Class*************************
                   for(Class__c classRec : listClass){
                       setTeacherId.add(classRec.Teacher__c);
                   }
                   
                   //************************Retrieving Teacher Leaves,Teacher Working Hour & Holiday of specified teacher of class**********************
                   if(setTeacherId.size() > 0){
                       mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
                       mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
                       listOfHolidays = UtilityClass.getHolidays();
                   }
                   
                   for(Class__c cls : listClass){
                       List<Enrollment__c> listEnrollment = new List<Enrollment__c>();
                       List<Class_Term__c> listClassTerm = new List<Class_Term__c>();
                       List<Class_Session__c> listClassSession = new List<Class_Session__c>();
                       //**********Retrieving Class Terms to schedule based on difference between last scheduled class term & Advance Scheduling***************
                       if(cls.Class_Terms__r.size() > 0 && cls.Last_Scheduled_ClassTerm__c != NULL && cls.Advance_Scheduling__c != NULL){
                           for(Class_Term__c clsTrm : cls.Class_Terms__r){
                               if(clsTrm.Sequence__c > cls.Last_Scheduled_ClassTerm__c){
                                   listClassTerm.add(clsTrm);
                               }
                               if(listClassTerm.size() == cls.Advance_Scheduling__c)
                                   break;
                           }
                       }
                       
                       //*********************Retrieving Enrollments related to class*******************
                       if(cls.Enrollments__r.size() > 0){
                           listEnrollment.addAll(cls.Enrollments__r);
                       }
                       
                       //*********************Retrieving Class Session related to class which specify the number of sessions per day of a Class*******************
                       if(cls.Class_Sessions__r.size() > 0){
                           listClassSession.addAll(cls.Class_Sessions__r);
                       }else
                           System.debug('Classs Session Records Not Found For Class ID '+cls.Id);
                       
                       if(listClassTerm.size() > 0 && listClassSession.size() > 0 && cls.Sessions__r.size() > 0 && cls.Sessions__r[0].Sequence__c != NULL){
                           List<Session__c> listSession = new List<Session__c>();
                           List<Session__c> listSesstionOfOneTerm = new List<Session__c>();
                           Decimal seq = cls.Sessions__r[0].Sequence__c;
                           for(Class_Term__c clsTerm : listClassTerm){
                               //***************Creating Sessions of Class from Class Term Start Date till Class Term End date********************
                               listSesstionOfOneTerm = UtilityClass.createSessions(cls,clsTerm.Start_Date__c,clsTerm.End_Date__c,seq,
                                                                                   listClassSession,(clsTerm.Sessions__c != NULL ? clsTerm.Sessions__c : null));
                               seq +=  listSesstionOfOneTerm.size();  
                               if(listSesstionOfOneTerm.size() > 0){
                                   for(Session__c sess : listSesstionOfOneTerm){
                                       sess.Class_Term__c =  clsTerm.Id;
                                   }
                                   clsTerm.Status__c = ConstantClass.ScheduledStatus;
                                   listSession.addAll(listSesstionOfOneTerm);  
                               }                           
                           }
                           if(listSession.size() > 0){
                               //*********Get Updated Sessions Based on Holiday,Teacher Leaves,Teacher Working Hour*****************
                               listSession = UtilityClass.getUpdatedSessions(Integer.valueOf(cls.Sessions__r[0].Sequence__c),cls.Exclude_Public_Holidays__c,listSession,
                                                                             mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour, listOfHolidays);
                               //********Updating Last Scheduled ClassTerm with last class term sequence************
                               cls.put('Last_Scheduled_ClassTerm__c',listClassTerm.get(listClassTerm.size() - 1).Sequence__c);
                               //********Updating Last session date with newly Created Session last session of The month************
                               cls.put('Last_Session_Date__c',listSession.get(listSession.size() - 1).Session_Date__c);
                               cls.put('Last_Session_Scheduled_Date__c',System.today());
                               //********Updating Next Schedule Date to days before from Last Term End Date ************
                               cls.put('Next_Schedule_Date__c',listClassTerm.get(listClassTerm.size() - 1).End_Date__c.addDays(-Integer.valueOf(Label.Days_Before_Term_End)));
                               listSessionToInsert.addAll(listSession);
                               listClassTermToUpdate.addAll(listClassTerm);
                               listClassToUpdate.add(cls);
                           }
                       }
                   }
                   
                   if(listClassToUpdate.size() > 0)
                       update listClassToUpdate;
                   
                   if(listClassTermToUpdate.size() > 0)
                       update listClassTermToUpdate;
                   
                   if(listSessionToInsert.size() > 0){
                       insert listSessionToInsert;
                       for(Session__c sess : listSessionToInsert){
                           List<Session__c> listSession = new List<Session__c>();
                           if(mapClassIdToSessions.containsKey(sess.Class__c))
                               listSession = mapClassIdToSessions.get(sess.Class__c);
                           listSession.add(sess);
                           mapClassIdToSessions.put(sess.Class__c,listSession);
                       }
                   }
                   
                   if(mapClassIdToSessions.keySet().size() > 0){
                       for(Class__c cls: listClass){
                           //*********************Retrieving Enrollments related to class*******************
                           if(cls.Enrollments__r.size() > 0 && mapClassIdToSessions.containsKey(cls.Id)){
                               for(Enrollment__c enrol : cls.Enrollments__r){
                                   //******************Creating Student Session Records for each Enrollment based on session records*********** 
                                   for(Session__c sess : mapClassIdToSessions.get(cls.Id)){
                                       Student_Session__c stuSess = UtilityClass.createStudentSessions(enrol, sess);
                                       listStudentSession.add(stuSess);
                                   }
                               }
                           }
                       }
                   }
                   
                   if(listStudentSession.size() > 0)
                       insert listStudentSession;
               }
            else{
                System.debug('FLS NOT FOUND.');
            }
        }catch(Exception e){
            System.debug('Error Message-->'+e.getMessage());
            System.debug('Line Number-->'+e.getLineNumber());
            Boolean isBlufyErrorAccessible = FieldPremissionCrudUtility.checkReadPermission('Blufy_Error_Log__c',new Set<String>{'Process_Name__c','Description__c','Title__c'},true);
            if(isBlufyErrorAccessible){
                Blufy_Error_Log__c blufyErrLg = new Blufy_Error_Log__c();
                blufyErrLg.put('Process_Name__c','SessionRecordsCreationBatchApex');
                blufyErrLg.put('Description__c',e.getMessage());
                blufyErrLg.put('Title__c','Session Creation Batch');
                insert blufyErrLg;
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}