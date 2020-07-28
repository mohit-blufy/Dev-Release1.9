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
    
    public static void createTerm (List <Class__c> clsList){
        List <Class_Term__c> clsTermlist = new List <Class_Term__c>();
        List <Session__c> sessList = new List <Session__c>();
        Set<String> setTeacherId = new Set<String>();
        Set<String> setRoomId = new Set<String>();
        Set<String> setClassId = new Set<String>();
        Map<String,List<Class_Session__c>> mapClassIdToClassSessions = new Map<String,List<Class_Session__c>>();
        Map<String,List<Class_Term__c>> mapClassIdToClassTerms = new Map<String,List<Class_Term__c>>();
        Map<String,List<Session__c>> mapClassIdToSessions = new Map<String,List<Session__c>>(); 
        
        List<Holiday__c> listOfHolidays = new List<Holiday__c>(); 
        Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
        Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
        Map<String,List<Session__c>> mapTeacherIdToTeacherSessions = new Map<String,List<Session__c>>();
        Map<String,List<Session__c>> mapRoomIdToRoomSessions = new Map<String,List<Session__c>>();
        
        //***********************Retrieving Terms with Open Status based on their Sequence**********************
        List<Term__c> trmList = TermService.getAllTerms();
        
        for(Class__c cls : clsList){  
            setClassId.add(cls.Id);
        }
        
        if(setClassId.size() > 0){
            //*********************Retrieving Class Session related to class which specify the number of sessions per day of a Class*******************
            List<Class_Session__c> listClassSessionForEachClass = ClassSessionService.getClassSessionsByClssId(setClassId);
            if(listClassSessionForEachClass != NULL && listClassSessionForEachClass.size() > 0){
                for(Class_Session__c clsSess : listClassSessionForEachClass){
                    List<Class_Session__c> listClassSession = new List<Class_Session__c>();
                    if(mapClassIdToClassSessions.containsKey(clsSess.Class__c))
                        listClassSession = mapClassIdToClassSessions.get(clsSess.Class__c);
                    listClassSession.add(clsSess);
                    mapClassIdToClassSessions.put(clsSess.Class__c,listClassSession);      
                }   
            }else{
                System.debug('Class Session Not Found');
            }
        }
        System.debug('mapClassIdToClassSessions-->'+mapClassIdToClassSessions);
        
        if(mapClassIdToClassSessions.keySet().size() > 0){
            List<Class_Session__c> listClsSession = new List<Class_Session__c>();
            for(String key : mapClassIdToClassSessions.keySet()){
                listClsSession.addAll(mapClassIdToClassSessions.get(key));
            }
            if(listClsSession.size() > 0){
                for(Class_Session__c clsSess : listClsSession){
                    if(String.isNotBlank(clsSess.Teacher__c))
                        setTeacherId.add(clsSess.Teacher__c);
                    if(String.isNotBlank(clsSess.Room__c))
                        setRoomId.add(clsSess.Room__c);
                }
                
            }
            
        }
        //************************Retrieving Teacher Leaves,Teacher Working Hour & Holiday of specified teacher of class*******************************
        if(setTeacherId.size() > 0){
            mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
            mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
            mapTeacherIdToTeacherSessions = UtilityClass.getTeacherRelatedSessions(setTeacherId);
            listOfHolidays = UtilityClass.getHolidays();
        }
        
        if(setRoomId.size() > 0){
            mapRoomIdToRoomSessions = UtilityClass.getRoomRelatedSessions(setRoomId);
        }
        
        for(Class__c cls : clsList){
            if(!mapClassIdToClassSessions.containsKey(cls.Id)){
                cls.addError('Please specify the Class Sessions in related list of  the Class.');
            }
            //-------  Create Class Term by verfiying class Type equals to Ongoing & Frequency equals to Term --------//        
            if(cls.Type__c.equalsIgnoreCase(ConstantClass.ongoingClsType)){
                if (cls.Frequency__c.equalsIgnoreCase(ConstantClass.termFrequency)){
                    List<Class_Term__c> listClassTermForNew = new List<Class_Term__c>();
                    if(trmList != NULL && trmList.size() > 0){
                        for (Term__c term: trmList) {
                            //****************Creating Class Term Records based on Each Term ********************************
                            listClassTermForNew.add(UtilityClass.fillClsTerm(cls, term,term.Start_Date__c,term.End_Date__c,null));
                        }
                    }
                    else{
                        System.debug('Terms not configured.');
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
                            if(listClassTermForNew.size() > 0)
                                clsTermlist.addAll(listClassTermForNew);
                        }
                    }
                }                       
                
                //-------  Create Class Term by verfiying class Type equals to Ongoing & Frequency equals to Fixed  --------//           
            }else if(cls.Type__c.equalsIgnoreCase(ConstantClass.fixedType)){
                List<Class_Term__c> listClassTermForNew = new List<Class_Term__c>();
                listClassTermForNew.add(UtilityClass.fillClsTerm(cls, null,cls.Start_Date__c,cls.End_Date__c,null));
                if(listClassTermForNew.size() > 0)
                    clsTermlist.addAll(listClassTermForNew);
            }
        }
        
        if(clsTermlist.size() > 0){
            clsTermlist = ClassTermService.insertClassTermRecords(clsTermlist);
            if(clsTermlist.size() > 0){
                for(Class_Term__c clsTrm : clsTermlist){
                    List<Class_Term__c> listClassTerm = new List<Class_Term__c>();
                    if(mapClassIdToClassTerms.containsKey(clsTrm.Class__c))
                        listClassTerm = mapClassIdToClassTerms.get(clsTrm.Class__c);
                    listClassTerm.add(clsTrm);
                    mapClassIdToClassTerms.put(clsTrm.Class__c,listClassTerm);
                }
            }
        }
        system.debug('clsTermlist-->'+clsTermlist);
        
        if(mapClassIdToClassTerms.keySet().size() > 0){
            for(Class__c cls : clsList){
                if(cls.Type__c.equalsIgnoreCase(ConstantClass.ongoingClsType) && cls.Auto_Schedule__c && 
                   cls.Advance_Scheduling__c != NULL && String.isNotBlank(cls.Advance_Scheduling_Unit__c) &&
                   mapClassIdToClassTerms.containsKey(cls.Id)){
                       if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.termFrequency) && cls.Advance_Scheduling_Unit__c.equalsIgnoreCase(ConstantClass.schedulingPicklistTerm)){
                           //*********Creating Session Records for Classes having Auto Schedule true & Advance Scheduling Unit is Term(s)***********
                           List<Class_Term__c> listClassTerm = new List<Class_Term__c>();
                           List<Session__c> listSession = new List<Session__c>();
                           List<Session__c> listSessionOfOneTerm = new List<Session__c>();
                           List<String> listClassTermId = new List<String>();
                           for(Class_Term__c clsTrm : mapClassIdToClassTerms.get(cls.Id)){
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
                                          Date sDate = clsTerm.Start_Date__c;
                                          DateTime strtDate = DateTime.newInstance(sDate.year(),sDate.month(),sDate.day(),00,00,00);
                                          
                                          Date eDate = clsTerm.End_Date__c;
                                          DateTime endDate = DateTime.newInstance(eDate.year(),eDate.month(),eDate.day(),00,00,00);
                                          listSessionOfOneTerm = UtilityClass.createSessions(cls,strtDate,endDate,seq,clsTerm.Id,
                                                                                             mapClassIdToClassSessions.get(cls.Id),
                                                                                             (clsTerm.Sessions__c != NULL ? clsTerm.Sessions__c : null));
                                          seq +=  listSessionOfOneTerm.size();
                                          if(listSessionOfOneTerm.size() > 0){                    
                                              listClassTermId.add(clsTerm.Id);
                                              listSession.addAll(listSessionOfOneTerm);  
                                          }
                                      }
                               }
                           }
                           
                           if(listClassTermId.size() > 0){
                               for(Class_Term__c clsTerm : mapClassIdToClassTerms.get(cls.Id)){
                                   system.debug('listClassTermId-->'+listClassTermId);
                                   //*******************Assigning Status to Scheduled for created sessions of Selected Class Term*************************
                                   if(listClassTermId.contains(clsTerm.Id)){
                                       clsTerm.put('Status__c',ConstantClass.ScheduledStatus);
                                   }
                               }
                           }
                           
                           if(listSession.size() > 0){
                               cls.put('Last_Scheduled_ClassTerm__c',listClassTerm.get(listClassTerm.size() - 1).Sequence__c);
                               cls.put('Next_Schedule_Date__c',listClassTerm.get(listClassTerm.size() - 1).End_Date__c.addDays(-Integer.valueOf(Label.Days_Before_Term_End)));
                               mapClassIdToSessions.put(cls.Id,listSession);
                           }
                       }
                       else if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency) && cls.Advance_Scheduling_Unit__c.equalsIgnoreCase(ConstantClass.schedulingPicklistMonth)){
                           //*********Creating Session Records for Classes having Auto Schedule true & Advance Scheduling Unit is Month(s)**********
                           List<Session__c> listSession = new List<Session__c>();
                           List<Session__c> listSesstionOfOneTerm = new List<Session__c>();
                           List<Class_Term__c> listClassTerm = mapClassIdToClassTerms.get(cls.Id);
                           Integer seq = 0;
                           for(Class_Term__c clsTerm : listClassTerm){
                               if(mapClassIdToClassSessions.keySet().size() > 0 && mapClassIdToClassSessions.containsKey(cls.Id) && 
                                  mapClassIdToClassSessions.get(cls.Id) != NULL){
                                      Date sDate = clsTerm.Start_Date__c;
                                      DateTime strtDate = DateTime.newInstance(sDate.year(),sDate.month(),sDate.day(),00,00,00);
                                      
                                      Date eDate = clsTerm.End_Date__c;
                                      DateTime endDate = DateTime.newInstance(eDate.year(),eDate.month(),eDate.day(),00,00,00);
                                      //***************Creating Sessions of Class from Class Term Start Date till Class Term End date********************
                                      listSesstionOfOneTerm = UtilityClass.createSessions(cls,strtDate,endDate,seq,clsTerm.Id,
                                                                                          mapClassIdToClassSessions.get(cls.Id),null);
                                      seq += listSesstionOfOneTerm.size();
                                      
                                      if(listSesstionOfOneTerm.size() > 0){
                                          clsTerm.put('Status__c',ConstantClass.ScheduledStatus);
                                          clsTerm.put('Sessions__c',listSesstionOfOneTerm.size());
                                          listSession.addAll(listSesstionOfOneTerm);  
                                      }
                                  }
                           }
                           if(listSession.size() > 0){
                               cls.put('Last_Scheduled_ClassTerm__c',listClassTerm.get(listClassTerm.size() - 1).Sequence__c);
                               cls.put('Next_Schedule_Date__c',listClassTerm.get(listClassTerm.size() - 1).End_Date__c.addDays(-Integer.valueOf(Label.Days_Before_Term_End)));
                               mapClassIdToSessions.put(cls.Id,listSession);
                           }                          
                       }
                   }
                else if(cls.Auto_Schedule__c && cls.Type__c.equalsIgnoreCase(ConstantClass.fixedType) 
                        && String.isBlank(cls.Advance_Scheduling_Unit__c) && mapClassIdToClassTerms.containsKey(cls.Id)){
                            List<Class_Term__c> listClassTermForNew = mapClassIdToClassTerms.get(cls.Id);
                            List<Session__c> listSession = new List<Session__c>();
                            if(mapClassIdToClassSessions.keySet().size() > 0 && mapClassIdToClassSessions.containsKey(cls.Id) && 
                               mapClassIdToClassSessions.get(cls.Id) != NULL){
                                   Date sDate = cls.Start_Date__c;
                                   DateTime strtDate = DateTime.newInstance(sDate.year(),sDate.month(),sDate.day(),00,00,00);
                                   Date eDate = cls.End_Date__c;
                                   DateTime endDate = DateTime.newInstance(eDate.year(),eDate.month(),eDate.day(),00,00,00);
                                   listSession = UtilityClass.createSessions(cls,sDate,endDate,0,listClassTermForNew[0].Id,
                                                                             mapClassIdToClassSessions.get(cls.Id),
                                                                             (cls.Sessions__c != NULL ? cls.Sessions__c : null));
                               }
                            if(listSession.size() > 0){
                                Class_Term__c clsTerm = listClassTermForNew[0];
                                clsTerm.put('Status__c',ConstantClass.ScheduledStatus);
                                listClassTermForNew[0] = clsTerm;
                                cls.put('Last_Scheduled_ClassTerm__c',listClassTermForNew[0].Sequence__c);
                                mapClassIdToClassTerms.put(cls.Id,listClassTermForNew);
                                mapClassIdToSessions.put(cls.Id,listSession);
                            }
                        }
            }
        }
        
        if(mapClassIdToSessions.keySet().size() > 0){
            for(Class__c cls : clsList){
                if(mapClassIdToSessions.containsKey(cls.Id)){
                    List<Session__c> listSession = mapClassIdToSessions.get(cls.Id);
                    //*********Get Updated Sessions Based on Holiday,Teacher Leaves,Teacher Working Hour*****************
                    listSession = UtilityClass.getUpdatedSessions(0,cls.Exclude_Public_Holidays__c,listSession,
                                                                  mapTeacherIdToTeacherLeave, mapTeacherIdToTechrWrkHour, 
                                                                  listOfHolidays,mapTeacherIdToTeacherSessions,mapRoomIdToRoomSessions);
                    mapClassIdToSessions.put(cls.Id,listSession);
                    cls.put('Last_Session_Date__c',listSession.get(listSession.size() - 1).Session_Date__c);
                    cls.put('Last_Session_Scheduled_Date__c',System.today());
                }
            }
        }
        
        if(mapClassIdToClassTerms.keySet().size() > 0){
            List<Class_Term__c> listClassTerm = new List<Class_Term__c>();
            for(String key : mapClassIdToClassTerms.keySet()){
                listClassTerm.addAll(mapClassIdToClassTerms.get(key));
            }
            if(listClassTerm.size() > 0)
                ClassTermService.updateClassTermRecords(listClassTerm);
        }
        
        if(mapClassIdToSessions.keySet().size() > 0){
            List<Session__c> listSession = new List<Session__c>();
            for(String key : mapClassIdToSessions.keySet()){
                listSession.addAll(mapClassIdToSessions.get(key));
            }
            if(listSession.size() > 0)
                SessionService.insertSessionRecords(listSession);
        }
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