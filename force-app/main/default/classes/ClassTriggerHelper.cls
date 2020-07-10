/**
* @author
* @date 
*
* 
*
* Objects :-  Session__c, Class__c, Class_Term__c, Teacher(API Name- Account) Teacher_Leave__c, Holiday__c, Term__c  
Trigger :- ClassTrigger
Desc:- Creating Class term or sessions based on class type, frequency and status equals to open after class updation.
Create Class Term when class is update to Open status which having Type as fixed and Frequency as One-time.
Insert Class Term from Term object when class is update to Open status which having Type as Ongoing and Frequency as Term.
Create Sessions when class is update to Open status which having Frequency as Monthly and Advance scheduling unit as Month(s). 
*/
public class ClassTriggerHelper {
    //-------   Create a Term when A cLass status is updated from draft to open (Mar 23,2020)   -------//
    
    public static void createTerm (List <Class__c> clsList) {
        List <Class_Term__c> clsTermlist = new List <Class_Term__c>();
        List <Session__c> sessList = new List <Session__c>();
        List <Class__c> clsUpdList = new List <Class__c>();
        Set<String> setTeacherId = new Set<String>();
        Set<String> setClassId = new Set<String>();
        Map<String,List<Class_Session__c>> mapClassIdToClassSessions = new Map<String,List<Class_Session__c>>();
        
        List<Holiday__c> listOfHolidays = new List<Holiday__c>(); 
        Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
        Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
        
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Id','Name','Start_Date__c',
            'Advance_Scheduling__c','Advance_Scheduling_Unit__c','Type__c','Frequency__c','Start_Time__c','Teacher__c','End_Date__c','Duration_Unit__c',
            'Duration__c','Days_of_Week__c','Sessions__c','Location__c','Last_Scheduled_ClassTerm__c','Auto_Schedule__c','Exclude_Public_Holidays__c'},false);
        Boolean isTermAccessible = FieldPremissionCrudUtility.checkReadPermission('Term__c',new Set<String>{'Id','Name','Start_Date__c',
            'End_Date__c','Sessions__c','Status__c','Sequence__c'},false);    
        Boolean isHolidayAccessible = FieldPremissionCrudUtility.checkReadPermission('Holiday__c', new Set<String>{'Id','Start_Date__c',
            'End_Date__c','Start_Time__c','End_Time__c'}, false);
        Boolean isTchrLeaveyAccessible = FieldPremissionCrudUtility.checkReadPermission('Teacher_Leave__c', new Set<String>{'Id', 'Name',
            'Status__c', 'Start_Date__c', 'End_Date__c','Teacher__c'}, false);
        Boolean isTchrWrkHressible = FieldPremissionCrudUtility.checkReadPermission('Teacher_Working_Hours__c', new Set<String>{'Id','Day__c',
            'End_Time__c','Start_Time__c','Active__c','Teacher__c'}, false);
        Boolean isClsSessionaccessible = FieldPremissionCrudUtility.checkReadPermission('Class_Session__c', new Set<String>{'Id','Name',
            'Duration__c','Start_Time__c','Class__c'}, false);
        
        Boolean isClassAccessibleForInsrtUpdte = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Next_Schedule_Date__c',
            'Last_Session_Date__c','Last_Session_Scheduled_Date__c','Last_Scheduled_ClassTerm__c'},true);
        Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c',new Set<String>{'Sequence__c','Class__c',
            'Teacher__c','Session_Date__c','Start_Time__c',
            'Status__c','Duration_Unit__c','Duration__c','Type__c'},true,false);
        Boolean isClsTermAccessible = FieldPremissionCrudUtility.checkReadPermission('Class_Term__c',new Set<String>{'Name','Start_Date__c',
            'End_Date__c','Sessions__c','Status__c','Sequence__c','Term__c'},true);
        
        if(isClassAccessible && isTermAccessible && isHolidayAccessible && isTchrLeaveyAccessible && isTchrWrkHressible && isClsSessionaccessible
           && isClassAccessibleForInsrtUpdte){
               
               //***********************Retrieving Terms with Open Status based on their Sequence**********************
               List<Term__c> trmList = [SELECT Id,Name,Sessions__c,Start_Date__c,End_Date__c,Sequence__c 
                                        FROM Term__c 
                                        WHERE Sessions__c != null AND Start_Date__c != null AND 
                                        End_Date__c != null AND Sequence__c != null AND Status__c=:ConstantClass.openStatus
                                        ORDER By Sequence__c];
               
               for(Class__c cls : clsList){
                   //********************Retrieving Class & Teacher Id with Auto Schedule True for creating sessions of Class*************************
                   if(cls.Auto_Schedule__c){
                       setTeacherId.add(cls.Teacher__c);   
                       setClassId.add(cls.Id);
                   }
               }
               
               //************************Retrieving Teacher Leaves,Teacher Working Hour & Holiday of specified teacher of class*******************************
               if(setTeacherId.size() > 0){
                   mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
                   mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
                   listOfHolidays = UtilityClass.getHolidays();
               }
               
               if(setClassId.size() > 0){
                   //*********************Retrieving Class Session related to class which specify the number of sessions per day of a Class*******************
                   for(Class_Session__c clsSess : [SELECT Id,Name,Duration__c,Start_Time__c,Class__c FROM Class_Session__c
                                                   WHERE Class__c IN :setClassId ORDER BY Start_Time__c]){
                                                       List<Class_Session__c> listClassSession = new List<Class_Session__c>();
                                                       if(mapClassIdToClassSessions.containsKey(clsSess.Class__c))
                                                           listClassSession = mapClassIdToClassSessions.get(clsSess.Class__c);
                                                       listClassSession.add(clsSess);
                                                       mapClassIdToClassSessions.put(clsSess.Class__c,listClassSession);      
                                                   }
               }
               
               for(Class__c cls : clsList){
                   //-------  Create Class Term by verfiying class Type equals to Ongoing & Frequency equals to Term --------//        
                   if(cls.Type__c.equalsIgnoreCase(ConstantClass.ongoingClsType) && cls.Start_Date__c != NULL){
                       if (cls.Frequency__c.equalsIgnoreCase(ConstantClass.termFrequency)){
                           List<Class_Term__c> listClassTermForNew = new List<Class_Term__c>();
                           for (Term__c term: trmList) {
                               //****************Creating Class Term Records based on Each Term ********************************
                               listClassTermForNew.add(UtilityClass.fillClsTerm(cls, term,term.Start_Date__c,term.End_Date__c,null));
                           } 
                           if(!mapClassIdToClassSessions.containsKey(cls.Id)){
                               cls.addError('Please specify the Class Sessions in related list of  the Class.');
                               
                           }
                           //*********Creating Session Records for Classes having Auto Schedule true & Advance Scheduling Unit is Term(s)***********
                           if(cls.Auto_Schedule__c && cls.Advance_Scheduling__c != NULL && String.isNotBlank(cls.Advance_Scheduling_Unit__c) 
                              && cls.Advance_Scheduling_Unit__c.equalsIgnoreCase(ConstantClass.schedulingPicklistTerm) && listClassTermForNew.size() > 0){
                                  List<Class_Term__c> listClassTerm = new List<Class_Term__c>();
                                  List<Session__c> listSession = new List<Session__c>();
                                  List<Session__c> listSesstionOfOneTerm = new List<Session__c>();
                                  List<String> listClassTermId = new List<String>();
                                  for(Class_Term__c clsTrm : listClassTermForNew){
                                      listClassTerm.add(clsTrm);
                                      if(listClassTerm.size() == cls.Advance_Scheduling__c)
                                          break;
                                  }
                                  if(listClassTerm.size() > 0){
                                      Integer seq = 0;
                                      for(Class_Term__c clsTerm : listClassTerm){
                                          if(mapClassIdToClassSessions.keySet().size() > 0 && mapClassIdToClassSessions.containsKey(cls.Id) && 
                                             mapClassIdToClassSessions.get(cls.Id) != NULL){
                                                 //**********Creating Sessions of Class from Class Term Start Date till Class Term End date********************
                                                 listSesstionOfOneTerm = UtilityClass.createSessions(cls,clsTerm.Start_Date__c,clsTerm.End_Date__c,seq,
                                                                                                     mapClassIdToClassSessions.get(cls.Id),
                                                                                                     (clsTerm.Sessions__c != NULL ? clsTerm.Sessions__c : null));
                                                 seq +=  listSesstionOfOneTerm.size();
                                                 
                                                 if(listSesstionOfOneTerm.size() > 0){
                                                     for(Session__c sess : listSesstionOfOneTerm){
                                                         sess.Class_Term__r =  clsTerm;
                                                     }
                                                     listClassTermId.add(clsTerm.Term__c);
                                                     listSession.addAll(listSesstionOfOneTerm);  
                                                 }
                                             }
                                      }
                                  }
                                  
                                  if(listClassTermId.size() > 0){
                                      for(Class_Term__c clsTerm : listClassTermForNew){
                                          system.debug('listClassTermId-->'+listClassTermId);
                                          //*******************Assigning Status to Scheduled for created sessions of Selected Class Term*************************
                                          if(listClassTermId.contains(clsTerm.Term__c)){
                                              clsTerm.put('Status__c',ConstantClass.ScheduledStatus);
                                          }
                                      }
                                  }
                                  
                                  if(listSession.size() > 0){
                                      //*********Get Updated Sessions Based on Holiday,Teacher Leaves,Teacher Working Hour*****************
                                      listSession = UtilityClass.getUpdatedSessions(0,cls.Exclude_Public_Holidays__c,listSession,
                                                                                    mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour, listOfHolidays);
                                      cls.put('Last_Scheduled_ClassTerm__c',listClassTerm.get(listClassTerm.size() - 1).Sequence__c);
                                      cls.put('Last_Session_Date__c',listSession.get(listSession.size() - 1).Session_Date__c);
                                      cls.put('Last_Session_Scheduled_Date__c',System.today());
                                      cls.put('Next_Schedule_Date__c',listClassTerm.get(listClassTerm.size() - 1).End_Date__c.addDays(-Integer.valueOf(Label.Days_Before_Term_End)));
                                      sessList.addAll(listSession);
                                      clsUpdList.add(cls);
                                  }
                              }
                           if(listClassTermForNew.size() > 0)
                               clsTermlist.addAll(listClassTermForNew);
                           
                           //-------  Create sessions by verfiying class Type equals to Ongoing & Frequency equals to Month  --------//              
                       }
                       else if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
                           if(cls.Advance_Scheduling__c != NULL){
                               List<MonthlyTermWrapper> listMonthlyTermWrapper = new List<MonthlyTermWrapper>();
                               Date endDateMonthDays = cls.Start_Date__c.addMonths(Integer.valueOf(cls.Advance_Scheduling__c));
                               Integer numberOfDays = Date.daysInMonth(endDateMonthDays.year(), endDateMonthDays.month());
                               Date endDate = Date.newInstance(endDateMonthDays.year(), endDateMonthDays.month(), numberOfDays);
                               // ***************Filling Wrapper Class Based on Class Start date and End Date based on Advance Scheduling value to 
                               // create Class term Records************************
                               for(Date i = cls.Start_Date__c ; i <= endDate ; ){
                                   MonthlyTermWrapper mTWrap = new MonthlyTermWrapper();
                                   mTWrap.sequence = listMonthlyTermWrapper.size() + 1;
                                   mTWrap.startDate =  i;
                                   Integer numberOfDaysinCurrMon = Date.daysInMonth(mTWrap.startDate.year(), mTWrap.startDate.month());
                                   mTWrap.endDate  = Date.newInstance(mTWrap.startDate.year(), mTWrap.startDate.month(), numberOfDaysinCurrMon);
                                   listMonthlyTermWrapper.add(mTWrap);
                                   i = mTWrap.endDate.addDays(1);
                               }
                               if(listMonthlyTermWrapper.size() > 0){
                                   List<Class_Term__c> listClassTermForNew = new List<Class_Term__c>();
                                   for(MonthlyTermWrapper mTWrap : listMonthlyTermWrapper){
                                       //********************************Creating Class Term Records for Each Month*********************************
                                       listClassTermForNew.add(UtilityClass.fillClsTerm(cls, null,mTWrap.startDate,mTWrap.endDate,mTWrap.sequence));
                                   }	
                                   if(!mapClassIdToClassSessions.containsKey(cls.Id)){
                                       cls.addError('Please specify the Class Sessions in related list of  the Class.');
                                   }
                                   //*********Creating Session Records for Classes having Auto Schedule true & Advance Scheduling Unit is Month(s)***********
                                   if(cls.Auto_Schedule__c && String.isNotBlank(cls.Advance_Scheduling_Unit__c) && listClassTermForNew.size() > 0
                                      && cls.Advance_Scheduling_Unit__c.equalsIgnoreCase(ConstantClass.schedulingPicklistMonth)){
                                          List<Session__c> listSession = new List<Session__c>();
                                          List<Session__c> listSesstionOfOneTerm = new List<Session__c>();
                                          Integer seq = 0;
                                          for(Class_Term__c clsTerm : listClassTermForNew){
                                              if(mapClassIdToClassSessions.keySet().size() > 0 && mapClassIdToClassSessions.containsKey(cls.Id) && 
                                                 mapClassIdToClassSessions.get(cls.Id) != NULL){
                                                     //***************Creating Sessions of Class from Class Term Start Date till Class Term End date********************
                                                     listSesstionOfOneTerm = UtilityClass.createSessions(cls,clsTerm.Start_Date__c,clsTerm.End_Date__c,seq,
                                                                                                         mapClassIdToClassSessions.get(cls.Id),null);
                                                     seq += listSesstionOfOneTerm.size();
                                                     
                                                     if(listSesstionOfOneTerm.size() > 0){
                                                         for(Session__c sess : listSesstionOfOneTerm){
                                                             sess.Class_Term__r =  clsTerm;
                                                         }
                                                         clsTerm.put('Status__c',ConstantClass.ScheduledStatus);
                                                         clsTerm.put('Sessions__c',listSesstionOfOneTerm.size());
                                                         listSession.addAll(listSesstionOfOneTerm);  
                                                     }
                                                 }
                                          }
                                          
                                          if(listSession.size() > 0){
                                              //*********Get Updated Sessions Based on Holiday,Teacher Leaves,Teacher Working Hour*****************
                                              listSession = UtilityClass.getUpdatedSessions(0,cls.Exclude_Public_Holidays__c,listSession,
                                                                                            mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour, listOfHolidays);
                                              cls.put('Last_Scheduled_ClassTerm__c',listClassTermForNew.get(listClassTermForNew.size() - 1).Sequence__c);
                                              cls.put('Last_Session_Date__c',listSession.get(listSession.size() - 1).Session_Date__c);
                                              cls.put('Last_Session_Scheduled_Date__c',System.today());
                                              cls.put('Next_Schedule_Date__c',listClassTermForNew.get(listClassTermForNew.size() - 1).End_Date__c.addDays(-Integer.valueOf(Label.Days_Before_Term_End)));
                                              sessList.addAll(listSession);
                                              clsUpdList.add(cls);
                                          }
                                      }
                                   
                                   if(listClassTermForNew.size() > 0)
                                       clsTermlist.addAll(listClassTermForNew);
                               }
                           }
                       }                       
                       
                       //-------  Create Class Term by verfiying class Type equals to Ongoing & Frequency equals to Fixed  --------//           
                   }else if(cls.Type__c.equalsIgnoreCase(ConstantClass.fixedType)){
                       List<Class_Term__c> listClassTermForNew = new List<Class_Term__c>();
                       listClassTermForNew.add(UtilityClass.fillClsTerm(cls, null,cls.Start_Date__c,cls.End_Date__c,null));
                       if(!mapClassIdToClassSessions.containsKey(cls.Id)){
                           cls.addError('Please specify the Class Sessions in related list of  the Class.');
                       }
                       if(cls.Auto_Schedule__c && cls.Advance_Scheduling__c != NULL && String.isBlank(cls.Advance_Scheduling_Unit__c) 
                          && listClassTermForNew.size() > 0){
                              List<Session__c> listSession = new List<Session__c>();
                              if(mapClassIdToClassSessions.keySet().size() > 0 && mapClassIdToClassSessions.containsKey(cls.Id) && 
                                 mapClassIdToClassSessions.get(cls.Id) != NULL){
                                     listSession = UtilityClass.createSessions(cls,cls.Start_Date__c,cls.End_Date__c,0,
                                                                               mapClassIdToClassSessions.get(cls.Id),
                                                                               (cls.Sessions__c != NULL ? cls.Sessions__c : null));
                                 }
                              
                              if(listSession.size() > 0){
                                  for(Session__c sess : listSession){
                                      sess.Class_Term__r =  listClassTermForNew[0];
                                  }
                                  listSession = UtilityClass.getUpdatedSessions(0,cls.Exclude_Public_Holidays__c,listSession,
                                                                                mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour, listOfHolidays);
                                  Class_Term__c clsTerm = listClassTermForNew[0];
                                  clsTerm.put('Status__c',ConstantClass.ScheduledStatus);
                                  listClassTermForNew[0] = clsTerm;
                                  cls.put('Last_Scheduled_ClassTerm__c',listClassTermForNew[0].Sequence__c);
                                  cls.put('Last_Session_Date__c',listSession.get(listSession.size() - 1).Session_Date__c);
                                  cls.put('Last_Session_Scheduled_Date__c',System.today());
                                  //cls.put('Next_Schedule_Date__c',listClassTermForNew[0].End_Date__c.addDays(-Integer.valueOf(Label.Days_Before_Term_End)));
                                  sessList.addAll(listSession);
                                  clsUpdList.add(cls);
                              }
                          }
                       if(listClassTermForNew.size() > 0)
                           clsTermlist.addAll(listClassTermForNew);
                   }
               }
           }
        
        if(isClsTermAccessible){
            if(clsTermlist.size() > 0)
                insert clsTermlist;
        }
        else
            system.debug('FLS NOT FOUND for Class Term');
        
        if(isSessionAccessible){
            if(sessList.size() > 0){
                for(Session__c sess : sessList){
                    sess.Class_Term__c = sess.Class_Term__r.Id;
                }
                insert sessList;
            }
        }
        else
            system.debug('FLS NOT FOUND for Session');
        
        //if(isClassAccessibleForInsrtUpdte){
        //  if(clsUpdList.size() > 0)
        ///     update clsUpdList;
        // }
        //  else
        //system.debug('FLS NOT FOUND for Class');
    }
    
    
    public Class MonthlyTermWrapper{
        public Date startDate;
        public Date endDate;
        public Integer sequence;
        
        public MonthlyTermWrapper(){
            sequence = 0;
        }
    }
}