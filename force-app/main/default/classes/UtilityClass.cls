public class UtilityClass {
    //Its used to fill session records
    public static List<Session__c> createSessions(Class__c classRec,DateTime startDate,DateTime endDate,Decimal sessionNum,String classTermId,
                                                  List<Class_Session__c> listClassSession,Decimal sessCounTotal){
                                                      List<Session__c> listSession = new List<Session__c>();
                                                      Integer i = 1;
                                                      while(sessCounTotal != NULL ? i <= sessCounTotal && startDate <= endDate : startDate <= endDate){
                                                          if(classRec.Days_of_Week__c.contains(DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('EEE'))){
                                                              for(Class_Session__c clsSession : listClassSession){
                                                                  Session__c sess = new Session__c();
                                                                  sess.put('Sequence__c',sessionNum + 1);
                                                                  sess.put('Class__c',classRec.Id);
                                                                  sess.put('Teacher__c',clsSession.Teacher__c);
                                                                  sess.put('Room__c',(clsSession.Room__c != null ? clsSession.Room__c : null));
                                                                  sess.put('Session_Date__c',Date.newInstance(startDate.year(),startDate.month(),startDate.day()));
                                                                  sess.put('Start_Time__c',clsSession.Start_Time__c);//class session start time
                                                                  sess.put('Duration__c',clsSession.Duration__c);// class session duration
                                                                  sess.put('Status__c',ConstantClass.ScheduledStatus);
                                                                  sess.put('Location__c',classRec.Location__c);
                                                                  sess.put('Type__c',ConstantClass.sessionStandardType);   
                                                                  sess.put('Class_Term__c',classTermId);
                                                                  if(sessCounTotal != NULL && i <= sessCounTotal){
                                                                      listSession.add(sess);
                                                                      sessionNum += 1;
                                                                      i++;
                                                                  }
                                                                  else if(sessCounTotal == NULL){
                                                                      listSession.add(sess);
                                                                      sessionNum += 1;
                                                                  }
                                                              }
                                                          }
                                                          startDate = startDate.addDays(1);
                                                      }
                                                      return listSession;
                                                  }
    
    public static Student_Session__c createStudentSessions(Enrollment__c enrolmnt,Session__c sess){
        Student_Session__c studentSession = new Student_Session__c();
        if(enrolmnt.Type__c == ConstantClass.fixedType){
            if(enrolmnt.Enrollment_Date__c != NULL && sess.Session_Date__c <= enrolmnt.Enrollment_End_Date__c){
                studentSession.put('Account__c',enrolmnt.Student__c);
                studentSession.put('Enrollment__c',enrolmnt.Id);
                studentSession.put('Status__c',ConstantClass.ScheduledStatus);
                studentSession.put('Session__c',sess.Id);
            }
        }
        else{
            studentSession.put('Account__c',enrolmnt.Student__c);
            studentSession.put('Enrollment__c',enrolmnt.Id);
            studentSession.put('Status__c',ConstantClass.ScheduledStatus);
            studentSession.put('Session__c',sess.Id);
        }
        return studentSession;
    }
    
    //------- Create Class Term when class Type equals to Term  --------//
    public static Class_Term__c fillClsTerm (Class__c cls, Term__c term,Date strtdate,Date endDate,Integer monthlyTermSeq){
        Class_Term__c clsTerm  = new Class_Term__c();
        clsTerm.put('Class__c',cls.Id);
        clsTerm.put('Status__c',ConstantClass.draftStatus);
        if(term != null){//Its used when frequency is term based
            clsTerm.put('Name',term.Name);
            clsTerm.put('Sequence__c',term.Sequence__c);
            clsTerm.put('Sessions__c',term.Sessions__c);    
            clsTerm.put('Start_Date__c', strtdate);
            clsTerm.put('End_Date__c',endDate);    
            clsTerm.put('Term__c', term.Id);
        }else if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
            clsTerm.put('Name', 'Monthly Term '+monthlyTermSeq);
            clsTerm.put('Sequence__c', monthlyTermSeq); 
            clsTerm.put('Sessions__c', cls.Sessions__c);
            clsTerm.put('Start_Date__c',strtdate);
            clsTerm.put('End_Date__c',endDate);
        }
        else{//Its used when frequency is fixed based classes
            clsTerm.put('Name', 'Fixed Term');
            clsTerm.put('Sequence__c', 1); 
            clsTerm.put('Sessions__c', cls.Sessions__c);
            clsTerm.put('Start_Date__c',strtdate);
            clsTerm.put('End_Date__c',endDate);
        }
        return clsTerm;
    } 
    
    //This function is used to get dynmically picklist values of the object, In Account billing country code values and label values are diff, So method is used.
    //Used on enrollment process
    public static List<String> getPickValues(String ObjectApi_name, String Field_name){ 
        //Map<String, String> mapPickvals = new Map<String, String>();        
        List<String> lstPickvals = new List<String>();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map    = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values   = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        
        for(Schema.PicklistEntry a : pick_list_values){ //for all values in the picklist list
            //lstPickvals.add(a.getValue());
            //mapPickvals.put(a.getLabel(), a.getValue());
            lstPickvals.add(a.getValue());
        }
        return lstPickvals;
    }
    
    public static Enrollment__c fillEnrollment(String cstmrId, String locId, String clsId, Date stDate, String status){
        Enrollment__c enr = new Enrollment__c();
        enr.Location__c   = locId;
        enr.Class__c      = clsId;
        enr.Start_Date__c = stDate;
        enr.Parent__c     = cstmrId;
        enr.Status__c     = status;
        enr.Enrollment_Date__c = System.today();
        return enr;
    }
    
    public static Invoice__c fillInvoice(String cstmrId, String locId, String subsId, String invType, String status){
        Invoice__c invoice = new Invoice__c();
        invoice.Customer__c= cstmrId;
        invoice.Location__c= locId;
        invoice.Subscription__c = subsId;
        invoice.Status__c       = status;
        invoice.Invoice_Type__c = invType;
        invoice.Invoice_Date__c = System.today();
        return invoice;
    }
    
    public static Invoice_Line_Item__c fillInvLineItem(String invId, String enrId, String subLnItmId, String feeId, String disId, String type, Decimal amount, Boolean isApplyGst){
        Invoice_Line_Item__c invLnItm = new Invoice_Line_Item__c();
        //invLnItm.Invoice__c   = invId;
        invLnItm.put('Invoice__c',invId);
        invLnItm.put('Enrollment__c',enrId);
        //invLnItm.Subscription_Line_Item__c = subLnItmId;
        invLnItm.put('Subscription_Line_Item__c',subLnItmId);
        //invLnItm.Fee__c       = feeId;
        invLnItm.put('Fee__c',feeId);
        invLnItm.put('Discount__c',disId);
        //invLnItm.Type__c      = type;
        invLnItm.put('Type__c',type);
        invLnItm.put('Amount__c',roundOffAmount(amount));
        if(isApplyGst){
            Decimal gstTaxPer = 0;
            try{
                gstTaxPer     = Decimal.valueOf(Label.GST_Rate);
                invLnItm.put('GST_Amount__c',roundOffAmount(amount*(gstTaxPer/100)));
                if(type == ConstantClass.discountType){
                    invLnItm.put('GST_Amount__c',-(invLnItm.GST_Amount__c));
                }
            }catch(Exception e){
                invLnItm.put('GST_Amount__c',0);
            }
        }   
        return invLnItm;
    }
    
    public static Payment__c fillPayment(String cstmrId, String invId, String status, Decimal amount){
        Payment__c payment = new Payment__c();
        payment.Parent__c  = cstmrId;
        payment.Invoice__c = invId;
        payment.Amount__c  = roundOffAmount(amount);
        payment.Status__c  = status;
        payment.Payment_Date__c = System.today();
        return payment;
    }   
    
    public static Map<String,List<Teacher_Leave__c>> getTeacherLeaves(Set<String> setTeacherId){
        try{
            Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
            List<Teacher_Leave__c> listTeacherLeaveByTeacher = TeacherLeaveService.getByTeacherId(setTeacherId);
            if(listTeacherLeaveByTeacher.size() > 0){
                for(Teacher_Leave__c tchrLv: listTeacherLeaveByTeacher){
                    for(Date stDt=tchrLv.Start_Date__c; stDt<=tchrLv.End_Date__c; stDt=stDt.addDays(1)){
                        List<Teacher_Leave__c> listTeacherleave = new List<Teacher_Leave__c>();
                        if(mapTeacherIdToTeacherLeave.containsKey(tchrLv.Teacher__c))
                            listTeacherleave = mapTeacherIdToTeacherLeave.get(tchrLv.Teacher__c);
                        listTeacherleave.add(tchrLv);
                        mapTeacherIdToTeacherLeave.put(tchrLv.Teacher__c,listTeacherleave);
                    }                                          
                }   
            }
            return mapTeacherIdToTeacherLeave;
        }catch(System.QueryException e){
            System.debug('UtilityClass Teacher Leave Method-->'+e.getMessage());
        }
        return null;
    }
    
    public static Map<String,List<Teacher_Working_Hours__c>> getTeacherWorkingHour(Set<String> setTeacherId){
        try{
            Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
            List<Teacher_Working_Hours__c> listTeacherWrkHour = TeacherWorkingHoursService.getByTeacherId(setTeacherId);
            if(listTeacherWrkHour.size() > 0){
                for(Teacher_Working_Hours__c techWrkHour : listTeacherWrkHour){
                    List<Teacher_Working_Hours__c> listTechrWrkHr = new List<Teacher_Working_Hours__c>();
                    if(mapTeacherIdToTechrWrkHour.containsKey(techWrkHour.Teacher__c))
                        listTechrWrkHr = mapTeacherIdToTechrWrkHour.get(techWrkHour.Teacher__c);
                    listTechrWrkHr.add(techWrkHour);
                    mapTeacherIdToTechrWrkHour.put(techWrkHour.Teacher__c,listTechrWrkHr);
                }
            }
            return mapTeacherIdToTechrWrkHour;
        }catch(System.QueryException e){
            System.debug('UtilityClass Teacher Working Hour Method-->'+e.getMessage());
        }
        return null;
    }
    
    public static List<Holiday__c> getHolidays(){
        try{
            List<Holiday__c> listOfHolidays = new List<Holiday__c>();
            for (Holiday__c holidays : HolidayService.getByDate(null,null)){
                listOfHolidays.add(holidays);
            }
            return listOfHolidays;   
        }catch(System.QueryException e){
            System.debug('UtilityClass Holiday Method-->'+e.getMessage());
        }
        return null;
    }
    
    public static Map<String,List<Session__c>> getTeacherRelatedSessions(Set<String> setTeacherId){
        try{
            Map<String,List<Session__c>> mapTeacherIdToTeacherSessions = new Map<String,List<Session__c>>();
            List<Session__c> listSessionByTeacherId = SessionService.getSessionsByTeacherId(setTeacherId);
            if(listSessionByTeacherId.size() > 0){
                for(Session__c session: listSessionByTeacherId){
                    List<Session__c> listSession = new List<Session__c>();
                    if(mapTeacherIdToTeacherSessions.containsKey(session.Teacher__c))
                        listSession = mapTeacherIdToTeacherSessions.get(session.Teacher__c);
                    listSession.add(session);
                    mapTeacherIdToTeacherSessions.put(session.Teacher__c,listSession);
                }
            }
            return mapTeacherIdToTeacherSessions;
        }catch(System.QueryException e){
            System.debug('UtilityClass Teacher Related Session Method-->'+e.getMessage());
        }
        return null;
    }
    
    public static Map<String,List<Session__c>> getRoomRelatedSessions(Set<String> setRoomId){
        try{
            Map<String,List<Session__c>> mapRoomIdToRoomSessions = new Map<String,List<Session__c>>();
            List<Session__c> listSessionByRoomId = SessionService.getSessionsByRoomId(setRoomId);
            if(listSessionByRoomId.size() > 0){
                for(Session__c session: listSessionByRoomId){
                    List<Session__c> listSession = new List<Session__c>();
                    if(mapRoomIdToRoomSessions.containsKey(session.Room__c))
                        listSession = mapRoomIdToRoomSessions.get(session.Room__c);
                    listSession.add(session);
                    mapRoomIdToRoomSessions.put(session.Room__c,listSession);
                }
            }
            return mapRoomIdToRoomSessions;
        }catch(System.QueryException e){
            System.debug('UtilityClass Room Related Session Method-->'+e.getMessage());
        }
        return null;
    }
    
    public static List<Session__c> getUpdatedSessions(Integer sequnNum,Boolean excludePublicHolidays,List<Session__c> sessList,Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave,
                                                      Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour,List<Holiday__c> listOfHolidays,
                                                      Map<String,List<Session__c>> mapTeacherIdToTeacherSessions,
                                                      Map<String,List<Session__c>> mapRoomIdToRoomSessions){
                                                          List<Session__c> listSession = new List<Session__c>();
                                                          List<Integer> listofSkipIndex = new List<Integer>();
                                                          for(Session__c sess : sessList){
                                                              if(excludePublicHolidays){
                                                                  if(listOfHolidays.size() > 0){
                                                                      Time sessETime = sess.Start_Time__c.addMinutes(Integer.valueOf(sess.Duration__c));
                                                                      for(Holiday__c holiday : listOfHolidays){    
                                                                          if(sess.Session_Date__c >= holiday.Start_Date__c && sess.Session_Date__c <= holiday.End_Date__c
                                                                             && holiday.Start_Time__c < sessETime && holiday.End_Time__c > sessETime){
                                                                                 listofSkipIndex.add(sessList.indexOf(sess));
                                                                             }
                                                                      }
                                                                  }
                                                              }
                                                              else{
                                                                  sess.Exception__c = '';
                                                                  if(mapTeacherIdToTeacherLeave.keySet().size() > 0){
                                                                      if(mapTeacherIdToTeacherLeave.containsKey(sess.Teacher__c)){
                                                                          if(mapTeacherIdToTeacherLeave.get(sess.Teacher__c) != NULL){
                                                                              List<Teacher_Leave__c> listTeacherLeave = mapTeacherIdToTeacherLeave.get(sess.Teacher__c);
                                                                              for(Teacher_Leave__c techrLv : listTeacherLeave){
                                                                                  if(techrLv.Start_Date__c <=  sess.Session_Date__c && techrLv.End_Date__c >= sess.Session_Date__c){                                                
                                                                                      if(techrLv.Status__c == ConstantClass.approvedStatus && !sess.Exception__c.contains(ConstantClass.teacherOnLeaveComment))
                                                                                          sess.Exception__c = ConstantClass.teacherOnLeaveComment;
                                                                                      else if(techrLv.Status__c == 'Requested' && !sess.Exception__c.contains(ConstantClass.teacherRequestLeaveComment))
                                                                                          sess.Exception__c = ConstantClass.teacherRequestLeaveComment;                                           
                                                                                  }  
                                                                              } 
                                                                          }
                                                                      }
                                                                  }
                                                                  
                                                                  if(mapTeacherIdToTechrWrkHour.keySet().size() > 0){
                                                                      if(mapTeacherIdToTechrWrkHour.containsKey(sess.Teacher__c)){
                                                                          if(mapTeacherIdToTechrWrkHour.get(sess.Teacher__c) != NULL){
                                                                              List<String> listTeachrId = new List<String>();
                                                                              Time sessETime = sess.Start_Time__c.addMinutes(Integer.valueOf(sess.Duration__c));
                                                                              List<Teacher_Working_Hours__c> listTchrWrkHr = mapTeacherIdToTechrWrkHour.get(sess.Teacher__c);
                                                                              for(Teacher_Working_Hours__c techrWrkHr : listTchrWrkHr){
                                                                                  system.debug('techrWrkHr-->'+techrWrkHr);
                                                                                  if(sess.Start_Time__c >= techrWrkHr.Start_Time__c && sessETime <= techrWrkHr.End_Time__c){
                                                                                      if(techrWrkHr.Day__c.contains(DateTime.newInstance(sess.Session_Date__c.year(),sess.Session_Date__c.month(),sess.Session_Date__c.day()).format('EEE'))){
                                                                                          listTeachrId.add(techrWrkHr.Teacher__c);
                                                                                      }
                                                                                  }
                                                                              }
                                                                              system.debug('listTeachrId-->'+listTeachrId);
                                                                              if(!listTeachrId.contains(sess.Teacher__c)){         
                                                                                  if(String.isBlank(sess.Exception__c))
                                                                                      sess.Exception__c = ConstantClass.teacherNotAvailableComment;
                                                                                  else if(!sess.Exception__c.contains(ConstantClass.teacherNotAvailableComment))
                                                                                      sess.Exception__c += ' '+ConstantClass.teacherNotAvailableComment;
                                                                              }
                                                                          }
                                                                      }
                                                                  }
                                                                  system.debug(' sess.Exception__c-->'+ sess.Exception__c);
                                                                  if(listOfHolidays.size() > 0){
                                                                      Time sessETime = sess.Start_Time__c.addMinutes(Integer.valueOf(sess.Duration__c));
                                                                      for(Holiday__c holiday : listOfHolidays){                                        
                                                                          if(sess.Session_Date__c >= holiday.Start_Date__c && sess.Session_Date__c <= holiday.End_Date__c
                                                                             && holiday.Start_Time__c < sessETime && holiday.End_Time__c > sessETime){
                                                                                 if(String.isBlank(sess.Exception__c))
                                                                                     sess.Exception__c = ConstantClass.holidayComment;
                                                                                 else if(!sess.Exception__c.contains(ConstantClass.holidayComment))
                                                                                     sess.Exception__c +=' '+ConstantClass.holidayComment;
                                                                             }  
                                                                      }
                                                                  }
                                                                  
                                                                  if(mapTeacherIdToTeacherSessions.keySet().size() > 0){
                                                                      if(mapTeacherIdToTeacherSessions.containsKey(sess.Teacher__c)){
                                                                          if(mapTeacherIdToTeacherSessions.get(sess.Teacher__c) != NULL){
                                                                              Time sessETime = sess.Start_Time__c.addMinutes(Integer.valueOf(sess.Duration__c));
                                                                              List<Session__c> listRelatedSession = mapTeacherIdToTeacherSessions.get(sess.Teacher__c);
                                                                             // system.debug('Sess-->'+sess);
                                                                              for(Session__c relSess : listRelatedSession){
                                                                                  //system.debug('relSess-->'+relSess);
                                                                                  if(relSess.Session_Date__c == sess.Session_Date__c && relSess.Start_Time__c <= sess.Start_Time__c
                                                                                     && relSess.Id != sess.Id && relSess.End_Time__c >= sessETime){
                                                                                         system.debug('tesddyf');
                                                                                         if(String.isBlank(sess.Exception__c))
                                                                                             sess.Exception__c = ConstantClass.teacherOccupiedComment;
                                                                                         else if(!sess.Exception__c.contains(ConstantClass.teacherOccupiedComment))
                                                                                             sess.Exception__c +=' '+ConstantClass.teacherOccupiedComment;                                          
                                                                                     }  
                                                                              } 
                                                                          }
                                                                      }
                                                                  }
                                                                  
                                                                  if(mapRoomIdToRoomSessions.keySet().size() > 0){
                                                                      if(mapRoomIdToRoomSessions.containsKey(sess.Room__c)){
                                                                          if(mapRoomIdToRoomSessions.get(sess.Room__c) != NULL){
                                                                              Time sessETime = sess.Start_Time__c.addMinutes(Integer.valueOf(sess.Duration__c));
                                                                              List<Session__c> listRelatedSession = mapRoomIdToRoomSessions.get(sess.Room__c);
                                                                              for(Session__c relSess : listRelatedSession){
                                                                                  if(relSess.Session_Date__c == sess.Session_Date__c && relSess.Start_Time__c <= sess.Start_Time__c
                                                                                     && relSess.Id != sess.Id && relSess.End_Time__c >= sessETime){
                                                                                         sess.Notes__c = ConstantClass.roomOccupiedComment;                                          
                                                                                     }  
                                                                              } 
                                                                          }
                                                                      }
                                                                  }

                                                                  if(String.isBlank(sess.Exception__c) && String.isNotBlank(sess.Notes__c))
                                                                      sess.Exception__c = sess.Notes__c;
                                                                  else if(String.isNotBlank(sess.Exception__c) && String.isNotBlank(sess.Notes__c))
                                                                      sess.Exception__c +=' '+sess.Notes__c;
                                                                  
                                                                  system.debug(' sess.Exception__c-->'+ sess.Exception__c);
                                                                  if(String.isNotBlank(sess.Exception__c))
                                                                      sess.Type__c = ConstantClass.sessionExceptionType;
                                                                  else
                                                                      sess.Type__c = ConstantClass.sessionStandardType;
                                                              }
                                                          }
                                                          
                                                          if(listofSkipIndex.size() > 0){
                                                              for(Session__c sess : sessList){
                                                                  if(!listofSkipIndex.contains(sessList.indexOf(sess))){
                                                                      listSession.add(sess);
                                                                  }
                                                              }
                                                              if(listSession.size() > 0){
                                                                  for(Integer i = sequnNum ; i< listSession.size(); i++){
                                                                      listSession[i].put('Sequence__c', i + 1);
                                                                  } 
                                                              }
                                                              return listSession;
                                                          }
                                                          else
                                                              return sessList;
                                                      }
    
    public static Session__c checkAvailabilityTeacherOrRoom(Session__c sess,String type){
        List<Holiday__c> listOfHolidays = new List<Holiday__c>();
        Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
        Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
        Map<String,List<Session__c>> mapTeacherIdToTeacherSessions = new Map<String,List<Session__c>>();
        Map<String,List<Session__c>> mapRoomIdToRoomSessions = new Map<String,List<Session__c>>();
        Boolean checkValidity = false;
        
        if(String.isBlank(type) && String.isNotBlank(sess.Teacher__c) && String.isNotBlank(sess.Room__c)){
            mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(new Set<String>{sess.Teacher__c});
            mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(new Set<String>{sess.Teacher__c});
            mapTeacherIdToTeacherSessions = UtilityClass.getTeacherRelatedSessions(new Set<String>{sess.Teacher__c});
            mapRoomIdToRoomSessions = UtilityClass.getRoomRelatedSessions(new Set<String>{sess.Room__c});
            listOfHolidays = UtilityClass.getHolidays();
            checkValidity = true;                
        }
        else if(type.equalsIgnoreCase('Teacher') && String.isNotBlank(sess.Teacher__c)){                
            mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(new Set<String>{sess.Teacher__c});
            mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(new Set<String>{sess.Teacher__c});
            mapTeacherIdToTeacherSessions = UtilityClass.getTeacherRelatedSessions(new Set<String>{sess.Teacher__c});
            listOfHolidays = UtilityClass.getHolidays();
            checkValidity = true;
        }
        else if(type.equalsIgnoreCase('Room') && String.isNotBlank(sess.Room__c)){
            mapRoomIdToRoomSessions = UtilityClass.getRoomRelatedSessions(new Set<String>{sess.Room__c});
            checkValidity = true;
        }
        
        if(checkValidity){
            List<Session__c> listSession = UtilityClass.getUpdatedSessions(Integer.valueOf(sess.Sequence__c-1),
                                                                           false,new List<Session__c>{sess}, mapTeacherIdToTeacherLeave, 
                                                                           mapTeacherIdToTechrWrkHour, listOfHolidays,
                                                                           mapTeacherIdToTeacherSessions,mapRoomIdToRoomSessions);
        }
        return sess;
    }
    
    public static Decimal roundOffAmount(Decimal amount){
        Decimal value = 0;
        if(amount != NULL){
            value = amount.setScale(2,System.RoundingMode.HALF_UP);
        }
        return value;        
    }    
}