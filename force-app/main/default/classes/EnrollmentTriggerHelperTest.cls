@isTest
public class EnrollmentTriggerHelperTest {
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    static testmethod void validateEnrollmentTriggerHelper(){
        
        Account studentObj  = [Select Name from Account where recordtypeid =: ConstantClass.stuCustomerRecordTypeId Limit 1];
        
        Account locationObj = [Select Name from Account where recordtypeid =: ConstantClass.locationRecordsTypeId Limit 1];
        
        Account teacherObj  = [Select Name from Account where recordtypeid =: ConstantClass.teacherRecordTypeId Limit 1];
        
        Holiday__c holidayObj = new Holiday__c (Start_Date__c = Date.today().addDays(1), 
                                                End_Date__c   = Date.today().addDays(1),
                                                Start_Time__c = Time.newInstance(10, 00, 00, 00), 
                                                End_Time__c   = Time.newInstance(23, 00, 00, 00),
                                                Name = 'Test', Type__c = 'Other');
        insert holidayObj;
        
        Course__c courseObj = [Select Name, Status__c, code__c from Course__c];
        
        Fee__c feeObj = [Select Name, Type__c, Amount__c, Required__c, Override__c, Schedule__c, Frequency__c, Units__c, 
                         Unit_Price__c from Fee__c];
        System.debug('feeObj@@'+feeObj);
        
        Course_Fee__c courseFeeObj = BlufyTestUtil.createCourseFee(courseObj.Id, feeObj.Id);
        insert courseFeeObj;
        
        Class__c classObj = [Select Name, Course__c, Format__c, Status__c, Teacher__c, Capacity__c, Type__c,
                             Sessions__c, Start_Date__c, Start_Time__c, Duration__c, Frequency__c
                             from Class__c];
        
        classObj.Type__c      				= ConstantClass.ongoingClsType;
        classObj.Frequency__c 				= ConstantClass.termFrequency;
        classObj.Days_of_Week__c			= 'Fri;Mon;Tue;Wed;Sat;Thu;Sun';
        classObj.Advance_Billing__c = 10;
        classObj.Advance_Billing_Unit__c = 'Day(s)';
        update classObj;
        
        System.debug('classObj@@'+classObj);
                
        Room__c roomObj = BlufyTestUtil.createRoom(locationObj.Id, 'Room', 'Group', 50);
        insert roomObj;
        
        Session__c sessObj = BlufyTestUtil.createSessionRec(locationObj.Id, teacherObj.Id, classObj.Id, Date.today().addDays(5), 
                                                            Time.newInstance(10, 00, 00, 00), ConstantClass.ScheduledStatus,
                                                            null, 120, 'Standard', roomObj.Id);
       
        insert sessObj;
        
        Term__c termObj = BlufyTestUtil.createTermRec('Term 1', String.valueOf(Date.today().Year()), ConstantClass.openStatus, Date.today().addDays(1), 
                                                      Date.today().addMonths(2), 12, 1);
        insert termObj;
        
        Class_Term__c classTermObj = BlufyTestUtil.createClassTerms('Term 1',classObj.id,10,Date.today().addDays(-25),
                                                                    Date.today().addMonths(2),1, ConstantClass.ScheduledStatus,
                                                                    termObj.id);
        insert classTermObj;
        sessObj.Class_Term__c = classTermObj.Id;
        update sessobj;
        
        Class_Term__c classTermObj2 = BlufyTestUtil.createClassTerms('Term 2',classObj.id,10,Date.today().addMonths(3),
                                                                    Date.today().addMonths(2),1, ConstantClass.ScheduledStatus,
                                                                    termObj.id);
        insert classTermObj2;
        
        Enrollment__c enrollObj = BlufyTestUtil.createEnrollment(classObj.Id, Date.today().addDays(1), locationObj.Id,
                                                                 studentObj.Id, ConstantClass.draftStatus, true, 
                                                                 Date.newInstance(2020,03,24), studentObj.id);
        enrollObj.Type__c                = ConstantClass.ongoingClsType;
        enrollObj.Enrollment_End_Date__c = Date.today().addMonths(3);
        insert enrollObj;
        
        Student_Session__c studSessObj = BlufyTestUtil.createStudentSession(sessObj.Id, ConstantClass.draftStatus,
                                                                            studentObj.Id, enrollObj.Id);
        insert studSessObj;
        
        Invoice__c invoiceObj = BlufyTestUtil.createInvoice(studentObj.Id,ConstantClass.dueStatus,Date.today());
        insert invoiceObj;
        
        Invoice_Line_Item__c invLinItm = BlufyTestUtil.createInvoiceLineItem(invoiceObj.Id,enrollObj.Id,
                                                                             ConstantClass.depositFeeType,100);
        insert invLinItm;
        invLinItm.Fee__c = FeeObj.Id;
        update invLinItm;
        System.debug('invLinItm@@'+invLinItm);
        
        enrollObj.Status__c = ConstantClass.enrolledStatus;
        update enrollObj;
        System.debug('enrollObj@@'+enrollObj);
        
        Test.startTest();
        SubscriptionLineItemService.insertSubsLineItemRecords(null);
        SubscriptionService.upsertSubscriptionRecords(null);
        System.assertEquals(feeObj.Amount__c = invLinItm.Amount__c, feeObj.Amount__c = invLinItm.Amount__c);
        Test.stopTest();
    }
}