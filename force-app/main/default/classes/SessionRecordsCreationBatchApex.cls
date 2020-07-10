/*
* Author : Shubhi Saxena
* created on : 02/04/2020
*
*
* Objects : Class__c,Session__c
* Description : This Batch Class is used to create session records to auto-maintain the 3 months records scenario
* for the classes with open status & Monthly frequency.
*/

global with sharing class SessionRecordsCreationBatchApex implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Id','Name','Next_Schedule_Date__c',
            'Last_Session_Date__c','Start_Date__c','Advance_Scheduling__c','Start_Time__c','Teacher__c','Duration__c','Days_of_Week__c','Status__c',
            'Sessions__c','Location__c','Auto_Schedule__c','Exclude_Public_Holidays__c','Frequency__c','Advance_Scheduling_Unit__c',
            'Last_Scheduled_ClassTerm__c'},false);
        Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c',  
                                                                                     new Set<String>{'Id','Sequence__c'},false);
        Boolean isClsSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Class_Session__c', new Set<String>{'Id','Name',
            'Duration__c','Start_Time__c','Class__c'}, false);
        Boolean isClsTermsAccessible = FieldPremissionCrudUtility.checkReadPermission('Class_Term__c', new Set<String>{'Id','Name',
            'Sequence__c'}, false);
        Boolean isEnrolmentAccessible = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c', new Set<String>{'Id','Name',
            'Enrollment_End_Date__c','Student__c','Type__c'}, false);
        
        if(isSessionAccessible && isClassAccessible && isEnrolmentAccessible && isClsSessionAccessible && isClsTermsAccessible){
            //**************Retrieving Class with Open Status, Monthly Frequency,Advance Scheduling Unit is Month(s)  & Next Schedule Date is 
            //Today along with related Sessions,Class Session,Class Term & Enrollment Records***************************
            String query = 'SELECT Id,Name,Next_Schedule_Date__c,Last_Session_Date__c,Start_Date__c,Advance_Scheduling__c,Location__c,Auto_Schedule__c, ';
            query += ' Start_Time__c,Teacher__c,Duration__c,Days_of_Week__c,Sessions__c,Exclude_Public_Holidays__c,Frequency__c,Last_Scheduled_ClassTerm__c, ';
            query += ' (SELECT Id,Name,Duration__c,Start_Time__c FROM Class_Sessions__r ORDER BY Start_Time__c), ';
            query += ' (SELECT Id,Sequence__c FROM Class_Terms__r ORDER BY Sequence__c DESC LIMIT 1), ';
            query += ' (SELECT Id,Name,Enrollment_End_Date__c,Student__c,Type__c FROM Enrollments__r), ';
            query += ' (SELECT Id,Sequence__c FROM Sessions__r ORDER BY Sequence__c DESC LIMIT 1) FROM Class__c ';
            query += ' WHERE Status__c =\'Open\' AND Frequency__c = \'Monthly\' AND Next_Schedule_Date__c = TODAY ';
            query += ' AND Advance_Scheduling_Unit__c = \'Month(s)\'';
            return Database.getQueryLocator(query);
        }
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
                   List <Class_Term__c> listClassTerm = new List <Class_Term__c>();
                   List<Student_Session__c> listStudentSession = new List<Student_Session__c>();
                   Map<String,List<Session__c>> mapClassIdToSessions = new Map<String,List<Session__c>>();
                   
                   Set<String> setTeacherId = new Set<String>();
                   List<Holiday__c> listOfHolidays = new List<Holiday__c>();
                   Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
                   Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
                   
                   Map<String,Course__c> crsMap = new Map<String,Course__c>();
                   for(Class__c classRec : listClass){
                       //********************Retrieving Teacher Id with Auto Schedule True for creating sessions of Class*************************
                       if(classRec.Auto_Schedule__c)
                           setTeacherId.add(classRec.Teacher__c);
                   }
                   
                   //************************Retrieving Teacher Leaves,Teacher Working Hour & Holiday of specified teacher of class**********************
                   if(setTeacherId.size() > 0){
                       mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
                       mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
                       listOfHolidays = UtilityClass.getHolidays();
                   }
                   
                   for(Class__c classRec : listClass){
                       if(classRec.Advance_Scheduling__c != NULL && classRec.Last_Session_Date__c != NULL){
                           //********Adding Months to Last Session Date for which we need to create session records***************
                           Integer numOfMonths = (System.today().addMonths(Integer.valueOf(classRec.Advance_Scheduling__c))).month() - classRec.Last_Session_Date__c.month();
                           if(numOfMonths != NULL && numOfMonths > 0){
                               List<MonthlyTermWrapper> listMonthlyTermWrapper = new List<MonthlyTermWrapper>();
                               List<Class_Term__c> listClassTermForNew = new List<Class_Term__c>();
                               
                               Date nextMonthSessDate = classRec.Last_Session_Date__c.addMonths(numOfMonths);
                               //**************Retrieving No. of Days in the Month for we need to create session records**************
                               Integer numOfMonthDays = Date.daysInMonth(nextMonthSessDate.year(),nextMonthSessDate.month());
                               Date lstDateOfNextMonth = Date.newInstance(nextMonthSessDate.year(),nextMonthSessDate.month(),numOfMonthDays);
                               //*******Getting the first session to be created after 1 day from Last Session Date****************
                               Date frstDateOfNextMonth = classRec.Last_Session_Date__c.addDays(1);
                               //*******Getting sequence of last scheduled monthly class term************************
                               Decimal seqnce = classRec.Class_Terms__r[0].Sequence__c;
                               // ***************Filling Wrapper Class Based on Class Last Session date and End Date based on Advance Scheduling value to 
                               // create Class term Records************************
                               for(Date i = frstDateOfNextMonth ; i <= lstDateOfNextMonth  ; ){
                                   MonthlyTermWrapper mTWrap = new MonthlyTermWrapper();
                                   mTWrap.sequence = seqnce + 1;
                                   mTWrap.startDate =  i;
                                   Integer numberOfDaysinCurrMon = Date.daysInMonth(mTWrap.startDate.year(), mTWrap.startDate.month());
                                   mTWrap.endDate  = Date.newInstance(mTWrap.startDate.year(), mTWrap.startDate.month(), numberOfDaysinCurrMon);
                                   listMonthlyTermWrapper.add(mTWrap);
                                   i = mTWrap.endDate.addDays(1);
                                   seqnce++;
                               }
                               
                               List<Class_Session__c> listClassSession = new List<Class_Session__c>();
                               //*********************Retrieving Class Session related to class which specify the number of sessions per day of a Class*******************
                               if(classRec.Class_Sessions__r.size() > 0){
                                   listClassSession.addAll(classRec.Class_Sessions__r);
                               }else
                                   System.debug('Classs Session Records Not Found For Class ID '+classRec.Id);
                               
                               if(listMonthlyTermWrapper.size() > 0){
                                   for(MonthlyTermWrapper mTWrap : listMonthlyTermWrapper){
                                       //********************************Creating Class Term Records for Each Month*********************************
                                       listClassTermForNew.add(UtilityClass.fillClsTerm(classRec, null,mTWrap.startDate,mTWrap.endDate,
                                                                                        Integer.valueOf(mTWrap.sequence)));
                                   }
                               }
                               
                               //*********Creating Session Records for Classes having Auto Schedule true & Advance Scheduling Unit is Month(s)***********
                               if(listClassSession.size() > 0 && classRec.Sessions__r.size() > 0 && classRec.Sessions__r[0].Sequence__c != NULL
                                  && listClassTermForNew.size() > 0 && classRec.Auto_Schedule__c){
                                      List<Session__c> listSesstionOfOneTerm = new List<Session__c>();
                                      List<Session__c> listSession = new List<Session__c>();
                                      Decimal seq = classRec.Sessions__r[0].Sequence__c;
                                      for(Class_Term__c clsTerm : listClassTermForNew){
                                          //***************Creating Sessions of Class from Class Term Start Date till Class Term End date********************
                                          listSesstionOfOneTerm = UtilityClass.createSessions(classRec,clsTerm.Start_Date__c,clsTerm.End_Date__c,seq,
                                                                                              listClassSession,null);
                                          seq +=  listSesstionOfOneTerm.size();  
                                          if(listSesstionOfOneTerm.size() > 0){
                                              for(Session__c sess : listSesstionOfOneTerm){
                                                  sess.Class_Term__r =  clsTerm;
                                              }
                                              clsTerm.Status__c = ConstantClass.ScheduledStatus;
                                              clsTerm.Sessions__c = listSesstionOfOneTerm.size();
                                              listSession.addAll(listSesstionOfOneTerm);  
                                          }
                                      }
                                      
                                      if(listSession.size() > 0){
                                           //*********Get Updated Sessions Based on Holiday,Teacher Leaves,Teacher Working Hour*****************
                                          listSession = UtilityClass.getUpdatedSessions(Integer.valueOf(classRec.Sessions__r[0].Sequence__c),classRec.Exclude_Public_Holidays__c,
                                                                                        listSession,mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour,
                                                                                        listOfHolidays);
                                          //********Updating Last Scheduled ClassTerm with last class term sequence************
                                          classRec.put('Last_Scheduled_ClassTerm__c',listClassTermForNew.get(listClassTermForNew.size() - 1).Sequence__c);
                                          //********Updating Last session date with newly Created Session last session of The month************
                                          classRec.put('Last_Session_Date__c',listSession.get(listSession.size() - 1).Session_Date__c);
                                          classRec.put('Last_Session_Scheduled_Date__c',System.today());
                                          //********Updating Next Schedule Date to days before from Last Term End Date ************
                                          classRec.put('Next_Schedule_Date__c',listClassTermForNew.get(listClassTermForNew.size() - 1).End_Date__c.addDays(-Integer.valueOf(Label.Days_Before_Term_End)));
                                          //mapClassIdToSessions.put(classRec.Id,listSession);
                                          listSessionToInsert.addAll(listSession);
                                          listClassToUpdate.add(classRec);
                                      }
                                  }
                               
                               if(listClassTermForNew.size() > 0)
                                   listClassTerm.addAll(listClassTermForNew);
                               
                           }
                           else{
                               system.debug('Number of Months less than or equal to 0 for '+classRec.Name);
                           }
                       }
                       else{
                           system.debug('Either Advance Scheduling or Last Session Date value is blank.'+classRec.Name);
                       }
                   }
                   
                   if(listClassTerm.size() > 0)
                       insert listClassTerm;
                   
                   if(listSessionToInsert.size() > 0){
                       for(Session__c sess : listSessionToInsert){
                           sess.Class_Term__c = sess.Class_Term__r.Id;
                       }
                       insert listSessionToInsert;
                       for(Session__c sess : listSessionToInsert){
                           List<Session__c> listSession = new List<Session__c>();
                           if(mapClassIdToSessions.containsKey(sess.Class__c))
                               listSession = mapClassIdToSessions.get(sess.Class__c);
                           listSession.add(sess);
                           mapClassIdToSessions.put(sess.Class__c,listSession);
                       }
                   }
                   
                   if(listClassToUpdate.size() > 0)
                       update listClassToUpdate;
                   
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
        }
        catch(Exception e){
            System.debug('Message-->'+e.getMessage());
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
    
    public Class MonthlyTermWrapper{
        public Date startDate;
        public Date endDate;
        public Decimal sequence;
        
        public MonthlyTermWrapper(){
            sequence = 0;
        }
    }
}