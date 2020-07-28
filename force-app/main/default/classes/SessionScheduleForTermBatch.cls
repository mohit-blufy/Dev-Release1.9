global with sharing class SessionScheduleForTermBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //**************Retrieving Class with Open Status, Term Frequency,Advance Scheduling Unit is Term(s), Auto Schedule is true & Next Schedule Date is 
        //Today along with related Sessions,Class Session,Class Term & Enrollment Records***************************
        String query = 'SELECT Id,Name,Next_Schedule_Date__c,Last_Session_Date__c,Start_Date__c,Advance_Scheduling__c,Location__c,Auto_Schedule__c, ';
        query += ' Start_Time__c,Teacher__c,Duration__c,Days_of_Week__c,Sessions__c,Last_Scheduled_ClassTerm__c,Exclude_Public_Holidays__c, ';
        query += ' (SELECT Id,Duration__c,Start_Time__c,Teacher__c,Room__c FROM Class_Sessions__r ORDER BY Start_Time__c), ';
        query += ' (SELECT Id,Name,Class__c,Start_Date__c,End_Date__c,Sequence__c,Sessions__c ';
        query += ' FROM Class_Terms__r ORDER BY Sequence__c), ';
        query += ' (SELECT Id,Enrollment_End_Date__c,Student__c,Type__c FROM Enrollments__r), ';
        query += ' (SELECT Id,Sequence__c FROM Sessions__r ORDER BY Sequence__c DESC LIMIT 1) FROM Class__c ';
        query += ' WHERE Auto_Schedule__c = true AND Advance_Scheduling__c != NULL AND Status__c =\'Open\' AND Frequency__c = \'Term\' ';
        query += ' AND Advance_Scheduling_Unit__c = \'Term(s)\' AND Next_Schedule_Date__c = TODAY WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Class__c> listClass){
        try{
            List<Session__c> listSessionToInsert = new List<Session__c>();
            List<Class__c> listClassToUpdate = new List<Class__c>();
            List<Class_Term__c> listClassTermToUpdate = new List<Class_Term__c>();
            List<Student_Session__c> listStudentSession = new List<Student_Session__c>();
            Map<String,List<Session__c>> mapClassIdToSessions = new Map<String,List<Session__c>>();
            
            Set<String> setTeacherId = new Set<String>();
            Set<String> setRoomId = new Set<String>();
            List<Holiday__c> listOfHolidays = new List<Holiday__c>();
            Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
            Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
            Map<String,List<Session__c>> mapTeacherIdToTeacherSessions = new Map<String,List<Session__c>>();
            Map<String,List<Session__c>> mapRoomIdToRoomSessions = new Map<String,List<Session__c>>();
            
            //********************Retrieving Teacher Id with Auto Schedule True for creating sessions of Class*************************
            for(Class__c classRec : listClass){
                //*********************Retrieving Class Session related to class which specify the number of sessions per day of a Class*******************
                if(classRec.Class_Sessions__r.size() > 0){
                    for(Class_Session__c clsSess : classRec.Class_Sessions__r){
                        if(String.isNotBlank(clsSess.Teacher__c))
                            setTeacherId.add(clsSess.Teacher__c);
                        if(String.isNotBlank(clsSess.Room__c))
                            setRoomId.add(clsSess.Room__c);
                    }
                }else
                    System.debug('Classs Session Records Not Found For Class ID '+classRec.Id);
            }
            
            //************************Retrieving Teacher Leaves,Teacher Working Hour & Holiday of specified teacher of class**********************
            if(setTeacherId.size() > 0){
                mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
                mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
                mapTeacherIdToTeacherSessions = UtilityClass.getTeacherRelatedSessions(setTeacherId);
                listOfHolidays = UtilityClass.getHolidays();
            }
            
            if(setRoomId.size() > 0){
                mapRoomIdToRoomSessions = UtilityClass.getRoomRelatedSessions(setRoomId);
            }
            for(Class__c cls : listClass){
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
                        listSesstionOfOneTerm = UtilityClass.createSessions(cls,clsTerm.Start_Date__c,clsTerm.End_Date__c,seq,clsTerm.Id,
                                                                            listClassSession,(clsTerm.Sessions__c != NULL ? clsTerm.Sessions__c : null));
                        seq +=  listSesstionOfOneTerm.size();  
                        if(listSesstionOfOneTerm.size() > 0){
                            clsTerm.Status__c = ConstantClass.ScheduledStatus;
                            listSession.addAll(listSesstionOfOneTerm);  
                        }                           
                    }
                    if(listSession.size() > 0){
                        //*********Get Updated Sessions Based on Holiday,Teacher Leaves,Teacher Working Hour*****************
                        listSession = UtilityClass.getUpdatedSessions(Integer.valueOf(cls.Sessions__r[0].Sequence__c),cls.Exclude_Public_Holidays__c,listSession,
                                                                      mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour, listOfHolidays,
                                                                      mapTeacherIdToTeacherSessions,mapRoomIdToRoomSessions);
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
                ClassService.updateClassRecords(listClassToUpdate);
            
            if(listClassTermToUpdate.size() > 0)
                ClassTermService.updateClassTermRecords(listClassTermToUpdate);
            
            if(listSessionToInsert.size() > 0){
                SessionService.insertSessionRecords(listSessionToInsert);
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
                StudentSessionService.insertStudentSessionRecords(listStudentSession);
            
            
        }catch(Exception e){
            System.debug('Error Message-->'+e.getMessage());
            System.debug('Line Number-->'+e.getLineNumber());
            
            Blufy_Error_Log__c blufyErrLg = new Blufy_Error_Log__c();
            blufyErrLg.put('Process_Name__c','SessionRecordsCreationBatchApex');
            blufyErrLg.put('Description__c',e.getMessage());
            blufyErrLg.put('Title__c','Session Creation Batch');
            BlufyErrorLogService.insertBlufyErrorLogRecords(new List<Blufy_Error_Log__c>{blufyErrLg});
        }
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}