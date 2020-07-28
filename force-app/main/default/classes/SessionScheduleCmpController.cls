/**
* @author
* @date 
*
* 
*
* Objects :-  Session__c, Class__c, Class_Term__c, Teacher & Student(API Name- Account), Teacher_Leave__c, Holiday__c, Student_Session__c  
Controller :- SessionScheduleCmpController
Desc:- generate sessions when a schedule button is clicked by user on Class_Term__c name TERM 1.
Term 1 is created by a trigger name- ClassTrigger & handler class name- ClassTriggerHelper   
*/
public class SessionScheduleCmpController {
    static Set<String> fieldsApiName;
    static boolean isClassAccessible = false;
    static boolean isSessionAccessible = false;
    
    @auraEnabled
    // generating sessions through sessionWrapper on Class_Term__c by fetching Class__c and Teacher fields 
    public static WrapperClass generateSession(String clsTermId,String classId){
        system.debug('classId-->'+classId);
        List<Class_Session__c> listClassSession = new List<Class_Session__c>();
        List<Session__c> listSessionObj = new List<Session__c>();
        WrapperClass wrpCls = new WrapperClass();
        List<sessionWrapper> sessList  = new List<sessionWrapper>();
        
        List<Holiday__c> listOfHolidays = new List<Holiday__c>();
        Map<String,List<Teacher_Working_Hours__c>> mapTeacherIdToTechrWrkHour = new Map<String,List<Teacher_Working_Hours__c>>();
        Map<String,List<Teacher_Leave__c>> mapTeacherIdToTeacherLeave = new Map<String,List<Teacher_Leave__c>>();
        Map<String,List<Session__c>> mapTeacherIdToTeacherSessions = new Map<String,List<Session__c>>();
        Map<String,List<Session__c>> mapRoomIdToRoomSessions = new Map<String,List<Session__c>>();
        Map<String,String> mapTeacherIdToTeacherName = new Map<String,String>();
        Map<String,String> mapRoomIdToRoomName = new Map<String,String>();
        
        List<Class__c> listClass = [SELECT Id, Name,Teacher__c,Teacher__r.Name,Start_Date__c,End_Date__c,Days_of_Week__c, 
                                    Sessions__c,Duration__c,Location__c,Course__c,Exclude_Public_Holidays__c,
                                    (SELECT Id,Name,Sessions__c,Start_Date__c,End_Date__c
                                     FROM Class_Terms__r WHERE Id=:clsTermId AND Status__c='Draft' LIMIT 1),
                                    (SELECT Id,Name,Duration__c,Start_Time__c,Teacher__c,Teacher__r.Name,Room__c,Room__r.Name 
                                     FROM Class_Sessions__r ORDER BY Start_Time__c),
                                    (SELECT Id,Sequence__c FROM Sessions__r ORDER BY Sequence__c DESC LIMIT 1)
                                    FROM Class__c WHERE Id =: classId];
        
        if(listClass != NULL && listClass.size() > 0 && listClass[0].Class_Terms__r.size() > 0){
            Class__c cls = listClass[0];
            Class_Term__c clsTrm = listClass[0].Class_Terms__r[0];
            if(listClass[0].Class_Sessions__r.size() > 0){
                listClassSession = listClass[0].Class_Sessions__r;
                for(Class_Session__c clsSess : listClassSession){
                    if(String.isNotBlank(clsSess.Teacher__c))
                        mapTeacherIdToTeacherName.put(clsSess.Teacher__c,clsSess.Teacher__r.Name);
                    if(String.isNotBlank(clsSess.Room__c))
                        mapRoomIdToRoomName.put(clsSess.Room__c,clsSess.Room__r.Name);
                }
            }
            else{
                wrpCls.message = 'No Class Session Found';
            }
            system.debug('listClassSession-->'+listClassSession);
            if(mapTeacherIdToTeacherName.keySet().size() > 0){
                Set<String> setTeacherId = mapTeacherIdToTeacherName.keySet();
                mapTeacherIdToTeacherLeave = UtilityClass.getTeacherLeaves(setTeacherId);
                mapTeacherIdToTechrWrkHour = UtilityClass.getTeacherWorkingHour(setTeacherId);
                mapTeacherIdToTeacherSessions = UtilityClass.getTeacherRelatedSessions(setTeacherId);
                listOfHolidays = UtilityClass.getHolidays();
            }            
            
            if(mapRoomIdToRoomName.keySet().size() > 0){
                Set<String> setRoomId = mapRoomIdToRoomName.keySet();
                mapRoomIdToRoomSessions = UtilityClass.getRoomRelatedSessions(setRoomId);
            }
            
            Date sDate = clsTrm.Start_Date__c;
            DateTime stDate = DateTime.newInstance(sDate.year(),sDate.month(),sDate.day(),00,00,00);
            Date eDate;
            DateTime endDate;
            
            eDate = (clsTrm.End_Date__c != NULL ? clsTrm.End_Date__c : null);
            endDate = (eDate != NULL ? DateTime.newInstance(eDate.year(),eDate.month(),eDate.day(),00,00,00) : null);
            
            system.debug('stDate@@-->'+stDate);
            Decimal seq = 0;
            if(cls.Sessions__r.size() > 0 && cls.Sessions__r[0].Sequence__c != NULL)  
                seq = cls.Sessions__r[0].Sequence__c;
            
            if(listClassSession.size() > 0 && mapTeacherIdToTeacherName.keySet().size() > 0 && 
               mapRoomIdToRoomName.keySet().size() > 0){
                listSessionObj = UtilityClass.createSessions(cls,stDate,endDate,seq,clsTermId,listClassSession,clsTrm.Sessions__c);
                if(listSessionObj.size() > 0){
                    listSessionObj = UtilityClass.getUpdatedSessions(Integer.valueOf(seq),cls.Exclude_Public_Holidays__c,listSessionObj, mapTeacherIdToTeacherLeave, 
                                                                     mapTeacherIdToTechrWrkHour, listOfHolidays,mapTeacherIdToTeacherSessions,
                                                                     mapRoomIdToRoomSessions);
                    for(Session__c sess : listSessionObj){
                        sessList.add(fillSessWrapper(sess,mapTeacherIdToTeacherName,mapRoomIdToRoomName));
                    }
                }
                wrpCls.sessList = sessList;
            }
        }
        return wrpCls;
    }
    
    // Function for inserting schedule sessions
    public static sessionWrapper fillSessWrapper(Session__c session,Map<String,String> mapTeacherIdToTeacherName,
                                                 Map<String,String> mapRoomIdToRoomName){
                                                     sessionWrapper sess = new sessionWrapper();
                                                     sess.seqNo        = Integer.valueOf(session.Sequence__c);
                                                     sess.clsId        = session.Class__c;
                                                     sess.clsTrmId     = session.Class_Term__c;
                                                     sess.tchrId       = session.Teacher__c;
                                                     sess.tchrName     = (mapTeacherIdToTeacherName.containsKey(session.Teacher__c) ? mapTeacherIdToTeacherName.get(session.Teacher__c) : null);
                                                     sess.roomId       = session.Room__c;
                                                     sess.roomName     = (mapRoomIdToRoomName.containsKey(session.Room__c) ? mapRoomIdToRoomName.get(session.Room__c) : null);
                                                     sess.clsLocId	   = session.Location__c;
                                                     sess.status       = ConstantClass.ScheduledStatus;
                                                     sess.stDate       = session.Session_Date__c;
                                                     sess.sessDay      = DateTime.newInstance(session.Session_Date__c.year(), session.Session_Date__c.month(),session.Session_Date__c.day()).format('EEE');
                                                     sess.stTime       = session.Start_Time__c;
                                                     sess.duration     = session.Duration__c;
                                                     sess.edTime 	   = session.Start_Time__c.addMinutes(Integer.valueOf(session.Duration__c));
                                                     sess.exceptionVal = session.Exception__c;
                                                     if(String.isNotBlank(sess.exceptionVal))
                                                         sess.isShowMessageOnRemarks = true;
                                                     
                                                     if(String.isNotBlank(session.Notes__c)){
                                                         sess.isShowMessageOnRoom = true;
                                                     }
                                                     //System.debug('sess.exceptionVal-->'+sess.exceptionVal);
                                                     //System.debug('sess.isShowMessageOnRemarks-->'+sess.isShowMessageOnRemarks);
                                                     return sess;
                                                 }
    
    
    @auraEnabled
    // inserting sessions when a schedule button is clicked on Class_Term__c UI
    public static List<Session__c> insertSessions (List<sessionWrapper> sessList,Id recordId) {
        fieldsApiName = new Set<String>{'Class__c','Sequence__c','Teacher__c','Status__c','Location__c','Session_Date__c','Duration__c','Start_Time__c','Class_Term__c','Notes__c','Exception__c'};
            isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c',fieldsApiName,true,false); 
        Boolean isClsTermAccessible = FieldPremissionCrudUtility.checkReadPermission('Class_Term__c',  new Set<String>{'Name','Start_Date__c','End_Date__c','Status__c'},true,false);
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Type__c','End_Date__c','Advance_Scheduling_Unit__c','Next_Schedule_Date__c','Last_Session_Date__c','Last_Session_Scheduled_Date__c','Sessions__c'},true,false);
        if(isSessionAccessible && isClsTermAccessible && isClassAccessible){    
            List <Session__c> insertSessList = new List<Session__c>();
            for(sessionWrapper sess : sessList){
                insertSessList.add(fillSession(sess, recordId));
            } 
            if (insertSessList.size()>0){ 
                insert insertSessList;
                createStudentSessions(insertSessList);
            }
            
            if(recordId!=null && insertSessList.size()>0) {
                // update Class_Term__c records when sessions are inserted and status changed to schedule
                Class_Term__c clsTerm = new Class_Term__c();
                clsTerm.id                                      = recordId;
                clsTerm.Status__c                               = ConstantClass.ScheduledStatus;
                clsTerm.Start_Date__c                           = insertSessList[0].Session_Date__c;
                clsTerm.End_Date__c                             = insertSessList[insertSessList.size()-1].Session_Date__c;
                update clsTerm;   
                
                List<Class__c> clsList = [SELECT Id, Advance_Scheduling_Unit__c, Last_Session_Date__c, Next_Schedule_Date__c,
                                          Advance_Scheduling__c,Type__c 
                                          FROM Class__c 
                                          WHERE Id =: insertSessList[0].Class__c];
                
                // update Class__c records when sessions are inserted
                if(clsList.size() > 0){
                    Class__c clsUpd = clsList.get(0);
                    clsUpd.Last_Session_Date__c           = clsTerm.End_Date__c;
                    clsUpd.Last_Session_Scheduled_Date__c = Date.today();
                    
                    // update Class_c End_date when type is Fixed
                    if (String.isNotBlank(clsUpd.Type__c)){
                        if(clsUpd.Type__c == ConstantClass.fixedType){
                            clsUpd.End_Date__c = clsTerm.End_Date__c;
                        }else{
                            // Update Class__c field name Next_Schedule_Date__c according to Advance_Scheduling_Unit__c(picklist) selection
                            if(String.isNotBlank(clsUpd.Advance_Scheduling_Unit__c) && clsUpd.Advance_Scheduling__c != NULL){
                                Integer days =Integer.valueOf(clsUpd.Advance_Scheduling__c);
                                if(clsUpd.Advance_Scheduling_Unit__c == ConstantClass.schedulingPicklistDay){
                                    clsUpd.Next_Schedule_Date__c = clsUpd.Last_Session_Date__c.addDays(-days); 
                                }else if (clsUpd.Advance_Scheduling_Unit__c == ConstantClass.schedulingPicklistWeek){
                                    clsUpd.Next_Schedule_Date__c = clsUpd.Last_Session_Date__c.addDays(-(days*7));
                                }else if (clsUpd.Advance_Scheduling_Unit__c == ConstantClass.schedulingPicklistMonth){
                                    clsUpd.Next_Schedule_Date__c = clsUpd.Last_Session_Date__c.addMonths(-days);
                                }                    
                            }else{ 
                                clsUpd.Next_Schedule_Date__c = clsUpd.Last_Session_Date__c.addMonths(-ConstantClass.defaultNextScheDtDiff);
                            }              
                        }
                    }
                    update clsUpd;
                }
            }   
            return insertSessList;
        }
        return null;
    } 
    
    public static Session__c fillSession(sessionWrapper sess, String clsTermId){
        Session__c session  = new Session__c();
        session.Class__c         = sess.clsId;
        session.Sequence__c      = sess.seqNo;
        session.Teacher__c       = sess.tchrId;
        session.Room__c          = sess.roomId;
        session.Status__c        = sess.status;
        session.Session_Date__c  = sess.stDate;
        session.Duration__c      = sess.duration;
        session.Start_Time__c    = sess.stTime;
        session.Location__c		 = sess.clsLocId;
        session.Class_Term__c    = clsTermId;
        session.Notes__c         = sess.remarks; 
        session.Exception__c = sess.exceptionVal; 
        //session.Module_Lesson__c = sess.moduleLesson;
        session.Type__c          = ConstantClass.sessionStandardType;
        if(sess.isShowMessageOnRemarks || sess.isShowMessageOnRoom)
            session.Type__c      = ConstantClass.sessionExceptionType;
        return session;
    }
    
    // Insert student sessions when sessions are created by class enrollments student
    public static void createStudentSessions (List<Session__c> sessList){
        Class__c clsId = new Class__c(id=sessList[0].Class__c);
        List<Student_Session__c> studSessList = new List<Student_Session__c>();
        for(Enrollment__c enroll : [select name,class__c,Student__c from Enrollment__c where Class__c =: clsId.Id]){
            for (integer s=0; s<sessList.size(); s++){
                Student_Session__c stuSess = new Student_Session__c();
                stuSess.Session__c    = sessList[s].id;
                stuSess.Account__c    = enroll.Student__c;
                stuSess.Enrollment__c = enroll.id;
                stuSess.Status__c     = ConstantClass.ScheduledStatus;
                studSessList.add(stuSess);
            }
        }
        
        if(studSessList.size() > 0)
            insert studSessList;
    }
    
    public Class WrapperClass{
        @AuraEnabled public List<sessionWrapper> sessList;
        @AuraEnabled public Decimal sessPerDay;
        @AuraEnabled public String message;
        public WrapperClass(){
            message = '';
            sessList = new List<sessionWrapper>();
            sessPerDay = 1;
        }
    }
    // sessionWrapper class for recieving input
    public class sessionWrapper{
        @AuraEnabled public Integer seqNo{get;set;}
        @AuraEnabled public String  clsId{get;set;}
        @AuraEnabled public String  clsTrmId{get;set;}
        @AuraEnabled public String  tchrId{get;set;}
        @AuraEnabled public String  tchrName{get;set;}
        @AuraEnabled public String  roomId{get;set;}
        @AuraEnabled public String  roomName{get;set;}
        @AuraEnabled public String  clsLocId{get;set;}
        @AuraEnabled public String  status{get;set;}
        @AuraEnabled public Date    stDate{get;set;}
        @AuraEnabled public String  sessDay{get;set;}
        @AuraEnabled public Boolean isOnLeave{get;set;}
        @AuraEnabled public Time    stTime{get;set;}
        @AuraEnabled public Time    edTime{get;set;}
        @AuraEnabled public Decimal duration{get;set;}
        @AuraEnabled public String remarks{get;set;}
        @AuraEnabled public String exceptionVal{get;set;}
        //@AuraEnabled public String module{get;set;}
        // @AuraEnabled public String lesson{get;set;}
        //@AuraEnabled public String modulelesson{get;set;}
        @AuraEnabled public Boolean isShowMessageOnRemarks{get;set;}
        @AuraEnabled public Boolean isShowMessageOnRoom {get;set;}
        
        // gets true if teacher is on leave while inserting sessions by comparing Date 
        public sessionWrapper(){
            //isOnLeave = false;
            isShowMessageOnRemarks = false;
            isShowMessageOnRoom = false;
        }
    }
}