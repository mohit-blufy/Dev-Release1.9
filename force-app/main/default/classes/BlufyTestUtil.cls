/**
Name        : BlufyTestUtil
Date        : 23 March 2020
Description : This class is use as a Utility class for creating test data for other test classes.
*/
@isTest
public class BlufyTestUtil {   
    public static void init(){
        Account locationObj = BlufyTestUtil.createLocationRec('New Harbor');
        insert locationObj;
        system.debug('locationObj -> '+locationObj);
        
        Location_Working_Hours__c lwhObj = BlufyTestUtil.createLocationWorkingHours(locationObj.Id, Time.newInstance(10, 00, 00, 00), Time.newInstance(23, 00, 00, 00),'Mon;Tue;Wed;Thu;Fri');
        insert lwhObj;
        
        Account teacherObj = BlufyTestUtil.createTeacherRec('Jonas', locationObj.Id);
        insert teacherObj;
        system.debug('teacherObj ->'+teacherObj);
        
        Account studentObj = BlufyTestUtil.createStudentRec('Gates','test1@gmail.com');
        insert studentObj;
        system.debug('studentObj ->'+studentObj);
        
        Course__c courseObj = BlufyTestUtil.createCourseRec('French', 'Active','XYZ-01');
        insert courseObj;
        system.debug('courseObj ->'+courseObj);
        
        Module__c module = BlufyTestUtil.createModule('Module 1');
        insert module;
        
       	Course_Module__c cModule = BlufyTestUtil.createCourseModule(module.Id,courseObj.Id,1);
        insert cModule;
        
        Lesson__c lesson = BlufyTestUtil.createLesson('lesson1','Hours',10);
        insert lesson;
        
        Module_Lesson__c mlesson = BlufyTestUtil.createModuleLesson('ML1',1,10,module.Id,lesson.Id);
        insert mlesson;
        
        Term__c termObj = BlufyTestUtil.createTermRec('Term 1', '2020', 'Open',Date.today().addDays(1),Date.today().addMonths(6),12,1 );
        insert termObj;
        
        Class__c classObj = BlufyTestUtil.createClassRec('Name', courseObj.Id, 'Classroom', 'Open', teacherObj.Id, 20, 'Fixed', 24, Date.today().addDays(1), Time.newInstance(10, 00, 00, 00), 'Minutes', 120,'One-time', cModule.Id);
        classObj.Advance_Billing__c = 2;
        classObj.End_Date__c = Date.today().addMonths(6);
        insert classObj;
        system.debug('classObj ->'+classObj);
        
        List<Class_Term__c> classTerms = new List<Class_Term__c>();
        Class_Term__c classTermObj = BlufyTestUtil.createClassTerms('Term 1',classObj.id,10,Date.today().addDays(1),Date.today().addMonths(6),1, 'Draft',termObj.id);
        classTerms.add(classTermObj);
        
        Class_Term__c classTermObj1 = BlufyTestUtil.createClassTerms('Term 1',classObj.id,10,Date.today().addMonths(7),Date.today().addMonths(8),2, 'Draft',termObj.id);
        classTerms.add(classTermObj1);
       	insert classTerms;
        
        Room__c roomObj = BlufyTestUtil.createRoom(locationObj.Id, 'Room1', 'Group', 35);
        insert roomObj;
        
        Session__c sessionObj = BlufyTestUtil.createSessionRec(locationObj.Id , teacherObj.Id, classObj.Id, Date.today().addMonths(1), Time.newInstance(10, 00, 00, 00), 'Scheduled', 'Hours', 2, 'Standard', roomObj.id);
        insert sessionObj;
        
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(classObj.Id,Time.newInstance(10,30,00,00),120);
        insert clsSess;
        
        //create parent customer
        Account customerObj = new Account(LastName = 'lie',personEmail = 'Test1@gmail.com',RecordTypeId =ConstantClass.stuCustomerRecordTypeId);
        insert customerObj;
        
        Enrollment__c enrollObj = BlufyTestUtil.createEnrollment(classObj.Id, Date.newInstance(2020,03,24), locationObj.Id, studentObj.Id, 'Enrolled', true,  Date.newInstance(2020,03,24),customerObj.id);
        insert enrollObj;
        
        Student_Session__c studentSessionObj = BlufyTestUtil.createStudentSession(sessionObj.Id, 'Scheduled', studentObj.Id, enrollObj.id);
        insert studentSessionObj;
        
        Session__History sessionHistoryObj = BlufyTestUtil.createSessionHistoryRecord(sessionObj.Id,'Class__c');
        insert sessionHistoryObj;
         
        Fee__c feeObj = BlufyTestUtil.createFeeRecords('Math Monthly Fee','Tuition Fee',500,true,true,'Ongoing','Monthly',2,90);
        insert feeObj;
        
        Course_Fee__c courseFee = BlufyTestUtil.createCourseFee(courseObj.Id,feeObj.Id);
        insert courseFee;
        
        Discount__c discount = BlufyTestUtil.createDiscount('testing','Discount',Date.today().addDays(1),Date.today().addMonths(1),'Active','Amount',500,true);
        insert discount;
        
        Course_Discount__c courseDiscount =  BlufyTestUtil.createCourseDiscunt(courseObj.Id,discount.Id);
        insert courseDiscount;
        
        Subscription__c subscriptionobj = BlufyTestUtil.createSubscription(locationObj.id,studentObj.id,'Term',Date.newInstance(2020,03,24),Date.newInstance(2020,03,28),'Active');
        insert subscriptionobj;
        Subscription__c subscriptionobj2 = BlufyTestUtil.createSubscription(locationObj.id,studentObj.id,'Monthly',Date.newInstance(2020,03,24),Date.newInstance(2020,03,28),'Active');
        insert subscriptionobj2;
        
        Subscription_Line_Item__c objSubscriptionlines = BlufyTestUtil.createSubscriptionLineItems(enrollObj.id,classTermObj.id,subscriptionobj.id,System.today(),feeObj.id,Date.newInstance(2020,04,14),'Active',Date.newInstance(2020,05,13));
        insert objSubscriptionlines;
        Subscription_Line_Item__c objSubscriptionlines2 = BlufyTestUtil.createSubscriptionLineItems(enrollObj.id,classTermObj.id,subscriptionobj2.id,Date.newInstance(2020,05,1),feeObj.id,Date.newInstance(2020,04,14),'Active',Date.newInstance(2020,05,13));
        insert objSubscriptionlines2;
       
        
        Invoice__c invoiceObj = BlufyTestUtil.createInvoice(studentObj.Id,ConstantClass.dueStatus,Date.today());
        insert invoiceObj;
        
        Invoice_Line_Item__c invLinItm = BlufyTestUtil.createInvoiceLineItem(invoiceObj.Id,enrollObj.Id,ConstantClass.depositFeeType,100);
        insert invLinItm;
        
        //Credit_Note__c createNoteObj = BlufyTestUtil.createCreditRec(studentObj.id, 'Issued',Date.today(),Date.newInstance(2020,6,24),50 );
        //insert createNoteObj;
        
       // Credit_Note__c createNoteObj2 = BlufyTestUtil.createCreditRec(studentObj.id, 'Issued',Date.newInstance(2020,6,24),Date.newInstance(2020,6,24),50 );
       // insert createNoteObj2;
        
        Teacher_leave__c teacherLeaveObj = BlufyTestUtil.createTeacherLeave(teacherObj.id, String.valueOf(Date.today().addDays(1)),String.valueOf(Date.today().addDays(2)), 'Requested');
        insert teacherLeaveObj;
        
        Holiday__c  holidayObj = BlufyTestUtil.createHoliday(Date.today().addDays(1), Date.today().addDays(1), Time.newInstance(10, 00, 00, 00), Time.newInstance(23, 00, 00, 00));
        insert holidayObj;
    }
    
    public static Account createLocationRec(String locationName){                
        return new Account(name = locationName, recordtypeid = ConstantClass.locationRecordsTypeId);
    }
    
    public static Account createTeacherRec(String teacherName, String locationId){
        return new Account(Lastname = teacherName, recordtypeid = ConstantClass.teacherRecordTypeId, Location__c = locationId);
    } 
    
    public static Account createStudentRec(String studentName,String personEmail){
        return new Account(Lastname = studentName, recordtypeid = ConstantClass.stuCustomerRecordTypeId,personEmail = personEmail);
    }
    
    public static Course__c createCourseRec(String courseName, String status, String code){
        return new Course__c(Name = courseName, Status__c = status, code__c = code);
    }
    public static Term__c createTermRec(String termName, String year, String status, Date startDate, Date endDate,Double session, Double seq ){
        return new Term__c(Name = termName, Year__c = year, status__c = status, Start_Date__c = startDate, End_Date__c= endDate,Sessions__c = session,Sequence__c = seq);
    }
    
    public static Class__c createClassRec(String className, String courseId, String format, String status, String teacherId, Integer capacity ,String type, Integer sessions, date startDate, time startTime, String durationUnit, Integer duration, String frequency, String currentCourseModuleId){
        //return new Class__c(Name = className, Course__c = courseId, Format__c = format, Status__c = status, Teacher__c = teacherId, Capacity__c = capacity, Type__c = type, Sessions__c = sessions, Start_Date__c = startDate, Start_Time__c = startTime,End_Date__c = Date.newInstance(2020,03,27), Duration_Unit__c = durationUnit, Duration__c = duration, Frequency__c = frequency);
        return new Class__c(Name = className, Course__c = courseId, Format__c = format, Status__c = status, Teacher__c = teacherId, Capacity__c = capacity, Type__c = type, Sessions__c = sessions, Start_Date__c = startDate, Start_Time__c = startTime, Duration__c = duration, Frequency__c = frequency, Current_Course_Module__c = currentCourseModuleId);
    }
    
    public static Class_Term__c createClassTerms(String name, String classId,Double session, Date startDate, Date endDate, Double seq, String status, String termId){
        return new Class_Term__c(Name = name, Class__c = classId, Sessions__c = session ,Start_Date__c = startDate, End_Date__c = endDate, Sequence__c = seq, Status__c = status, Term__c = termId, Exclude_Public_Holidays__c = true);  
    } 
    public static Session__c createSessionRec(String locationId, String teacherId, String classId, date sessionDate, time startTime, String status, String durationUnit, Integer duration, String sessionType, String roomId){
       // return new Session__c(Location__c = locationId, Teacher__c = teacherId, Class__c = classId, Session_Date__c = sessionDate, Start_Time__c = startTime, Status__c = status, Duration_Unit__c = durationUnit, Duration__c = duration, type__c = sessionType);
        return new Session__c(Location__c = locationId, Teacher__c = teacherId, Class__c = classId, Session_Date__c = sessionDate, Start_Time__c = startTime, Status__c = status, Duration__c = duration, type__c = sessionType, room__c = roomId);
    }
    
    public static Enrollment__c createEnrollment(String classId, date enrollDate, String locationId, String StudentId, String status, boolean termsAndConditions, date startDate, String parentStudent){
        return new Enrollment__c(Class__c = classId, Enrollment_Date__c = enrollDate, Location__c = locationId, Student__c = StudentId, Status__c = status, Terms_and_Conditions__c = termsAndConditions, Start_Date__c = startDate,Parent__c = parentStudent,Parent_Email__c = 'test1@gmail.com');
    }
    
    public static Student_Session__c createStudentSession(String sessionId, String status, String studentId, String enrollment){
        return new Student_Session__c(Session__c = sessionId, Status__c = status, Account__c = studentId, Enrollment__c = enrollment);
    }
    public static Session__History createSessionHistoryRecord(string parentId, string Field){
        return new Session__History(ParentId = parentId, Field = Field);
    }
    
    public static Class_Session__c createClassSessionRec(String clssId,Time strtTime,Double duration){
        return new Class_Session__c(Class__c = clssId,Start_Time__c = strtTime,Duration__c = duration);
    }
    
    public static Fee__C createFeeRecords(String name,String type, Double Amount,Boolean required, Boolean overi, String schedule, String freq, Double unit ,Double unitPrice){
        return new fee__c(Name= name, Type__c= type,Amount__c = Amount, Required__c = required,Override__c = overi,Schedule__c=schedule, Frequency__c =freq ,Units__c = unit, Unit_Price__c = unitPrice);
    }
    
       
    public static Course_Fee__c createCourseFee(String curseId, String feeId){
        return new Course_Fee__c(Course__c = curseId,Fee__c = feeId);
    }
    
    public static Discount__c createDiscount(String name,String type,Date startDate,Date endDate,String status,String format,Double value,Boolean active){
        return new Discount__c(Name = name,End_Date__c = endDate ,Format__c = format,Start_Date__c = startDate,Status__c = status,Type__c= type,Value__c = value,Active__c = true);
    }
    
    public static Course_Discount__c createCourseDiscunt(String courseId,String discountId){
        return new Course_Discount__c(Course__c = courseId,Discount__c = discountId); 
    }
    
    public static Subscription__c createSubscription(String locationId, String CustomerId, String PayementFreq, date startDate, Date endDate, String status){
        return  new Subscription__c(Location__c = locationId,Customer__c = CustomerId,Payment_Frequency__c = PayementFreq,Subscription_Start_Date__c = startDate,Subscription_End_Date__c = endDate,Status__c = status);
        
    }
    public static Subscription_Line_Item__c createSubscriptionLineItems(String enrollId,String classTermId,String subscriptionId, Date nextBillDate, String feeId, Date startDate, String status, Date expriyDate){
        return new Subscription_Line_Item__c(Enrollment__c = enrollId,Class_Term__c = classTermId,Subscription__c = subscriptionId,Next_Bill_Date__c = nextBillDate ,Fee__c = feeId, Subscription_Start_Date__c = startDate,Status__c = status,Subscription_Expiry_Date__c= expriyDate);
    }
   // public static Credit_Note__c createCreditRec(String customerId, String status, Date issuedDate , Date utilizedDate, Double amount){
   //     return new Credit_Note__c(Customer__c = customerId,Status__c = status,Date_Issued__c = issuedDate, Date_Utilized__c = utilizedDate, Amount__c  = amount );
   // }
    
    public static Invoice__c createInvoice(String customerId, String status, Date issuedDate){
        return new Invoice__c(Customer__c = customerId,Status__c = status,Invoice_Date__c = issuedDate);
    }
    
    public static Invoice_Line_Item__c createInvoiceLineItem(String invoiceId, String enrollmentId,String type,Decimal amount){
        return new Invoice_Line_Item__c(Invoice__c = invoiceId,Enrollment__c = enrollmentId,Type__c = type,Amount__c = amount);
    }
    
    public static Teacher_Leave__c createTeacherLeave(String teacherId, String Start_Date, String End_Date, String status){
        Date newSrtDate = Date.valueOf(Start_Date);
        Date newEndDate = Date.valueOf(End_Date);
        return new Teacher_Leave__c(teacher__c = teacherId, Start_Date__c = newSrtDate, End_Date__c = newEndDate, Status__c = status);
    }
    
     public static Holiday__c createHoliday(date startDate, date endDate, time startTime, time endTime){      
        return new Holiday__c(Start_Date__c = startDate, End_Date__c = endDate, Start_Time__c = startTime, End_Time__c = endTime);
    }
    
    public static Module__c createModule(String name){      
        return new Module__c(Name = name);
    }
    
    public static Course_Module__c createCourseModule(String moduleId,String courseId,Decimal sequence){
        return new Course_Module__c(Module__c = moduleId,Course__c = courseId,Sequence__c = sequence);
    }
    
    public static Lesson__c createLesson(String name,String durationUnit,Decimal duration){
        return new Lesson__c(Name = name,Duration__c = duration);
    }
    
    public static Module_Lesson__c createModuleLesson(String name,Decimal sequence,Decimal duration,String moduleId,String lessonId){
        return new Module_Lesson__c(Name = name,Sequence__c = sequence,Duration__c = duration,Module__c = moduleId,Lesson__c = lessonId);
    }
    public static Location_Working_Hours__c createLocationWorkingHours(String locationId, time startTime, time endTime, String dow){
        return new Location_Working_Hours__c(Location__c = locationId, Start_Time__c =startTime,End_Time__c = endTime,Day__c = dow, Active__c = true);                                                                
    }
    public static Room__c createRoom(String locationId, String name, String roomType, Integer capacity){
        return new room__c(Name = name, Type__c = roomType, Location__c = locationId, Capacity__c = capacity);
    }
}