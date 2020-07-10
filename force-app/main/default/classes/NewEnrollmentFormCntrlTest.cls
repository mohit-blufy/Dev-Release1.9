@isTest
public class NewEnrollmentFormCntrlTest {
	public static testmethod void validateNewEnrollmentFormCntrl(){
        Account locationObj = BlufyTestUtil.createLocationRec('New Harbor');
        insert locationObj;
        
        Account teacherObj = BlufyTestUtil.createTeacherRec('Jonas', locationObj.Id);
        insert teacherObj;
        
        Account studentObj = BlufyTestUtil.createStudentRec('Gates','test1@gmail.com');
        insert studentObj;
        
        Course__c courseObj = BlufyTestUtil.createCourseRec('French', 'Active','XYZ-01');
        insert courseObj;
        
        Class__c classObj = BlufyTestUtil.createClassRec('Name', courseObj.Id, 'Classroom', 'Open', teacherObj.Id, 20,
                                                         'Fixed', 24, Date.today().addDays(1), Time.newInstance(10, 00, 00, 00),
                                                         'Hours', 2,'One-time');
        classObj.Days_of_Week__c 	  = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun';
        classObj.Location__c          = locationObj.Id;
        classObj.End_Date__c = Date.today().addMonths(6);
        insert classObj;
        
        
        Term__c termObj = BlufyTestUtil.createTermRec('Term 1', '2020', 'Open',Date.today().addDays(1),Date.today().addMonths(6),12,1 );
        insert termObj;
		
		Class_Term__c classTermObj = BlufyTestUtil.createClassTerms('Term 1',classObj.id,14,Date.today().addDays(1),Date.today().addMonths(6),1, ConstantClass.ScheduledStatus ,termObj.id);
        insert classTermObj;
        
        Session__c sessionObj = BlufyTestUtil.createSessionRec(locationObj.Id,teacherObj.Id, classObj.Id, Date.today().addDays(7), Time.newInstance(10, 00, 00, 00), 'Scheduled', 'Hours', 2,'Standard');
        insert sessionObj;
        
        Account customerObj = new Account(LastName = 'lie',personEmail = 'Test1@gmail.com',RecordTypeId =ConstantClass.stuCustomerRecordTypeId);
        insert customerObj;
        
        Account customerObjUpdate = new Account(Id = customerObj.id, Phone = '1234567890', Block__c= 'Test', Unit__c ='Test', 
                                                BillingStreet = 'Test', BillingPostalCode = '201301', BillingCountry = 'India',
                                                Gender__c = 'Male', PersonBirthDate = Date.today(),
                                                Relationship_with_contact__c = 'Self');
        update customerObjUpdate;
        
        Enrollment__c enrollObj = BlufyTestUtil.createEnrollment(classObj.Id, Date.newInstance(2020,03,24), locationObj.Id, studentObj.Id, 'Enrolled', true,  Date.newInstance(2020,03,24),customerObj.id);
        insert enrollObj;
        
        Enrollment__c enrollObjUpdate = new Enrollment__c(Id = enrollObj.Id, Parent_Email__c = 'Test@gmail.com'); 
        
        Student_Session__c studentSessionObj = BlufyTestUtil.createStudentSession(sessionObj.Id, 'Scheduled', studentObj.Id, enrollObjUpdate.id);
        insert studentSessionObj;
        
        Fee__c feeObj = BlufyTestUtil.createFeeRecords('Math Monthly Fee','Tuition Fee',200,true,true,'Ongoing','Monthly',2,90);
        feeObj.Prorate__c = true;
        insert feeObj;
        
        Course_Fee__c courseFee = BlufyTestUtil.createCourseFee(courseObj.Id,feeObj.Id);
        insert courseFee;
        
        Discount__c discount = BlufyTestUtil.createDiscount('testing',ConstantClass.referralType,Date.today().addDays(1),Date.today().addMonths(1),'Active','Amount',500,true);
        insert discount;
        
        Course_Discount__c courseDiscount =  BlufyTestUtil.createCourseDiscunt(courseObj.Id,discount.Id);
        insert courseDiscount;
        
        NewEnrollmentFormCntrl.ClassWrapper clsWrp = new NewEnrollmentFormCntrl.ClassWrapper();
        clsWrp.recNo = 1;
        clsWrp.clsId = classObj.Id;
        clsWrp.clsType = classObj.Type__c;
        clsWrp.clsFrequency = classObj.Frequency__c;
        clsWrp.locationId = locationObj.Id;
        clsWrp.location = locationObj.Name;
        clsWrp.clsDays = classObj.Days_of_Week__c;
        clsWrp.teacherName = classObj.Teacher__r.Name;
        clsWrp.slctClsTermId = classTermObj.Id;
        clsWrp.slctclsTermName = classTermObj.Name;
        clsWrp.fees = 400;
        Test.startTest();
        
        NewEnrollmentFormCntrl.fetchCourses();
        NewEnrollmentFormCntrl.fetchTermAndCondition();
        NewEnrollmentFormCntrl.getchSlcdAccDetails(customerObj.Id);
        NewEnrollmentFormCntrl.CourseFeeWrapper curseFeeWrp = NewEnrollmentFormCntrl.fetchCrsClsDetails(courseObj.Id);
        curseFeeWrp.slcdClsWrapObj = clsWrp;
        NewEnrollmentFormCntrl.getRelatedFeeApex(feeObj.Id);
        NewEnrollmentFormCntrl.editCrsClsDetails(JSON.serialize(curseFeeWrp));
        
        discount.Global__c = true;
        discount.Start_Date__c = system.today().addDays(-2);
        update discount;
        NewEnrollmentFormCntrl.fetchOtherDiscount();
        
        discount.Code__c = '001';
        discount.Type__c = ConstantClass.promoType;
        update discount;
        NewEnrollmentFormCntrl.fetchOtherDiscount();
        
        discount.Type__c = 'Discount';
        update discount;
        NewEnrollmentFormCntrl.fetchOtherDiscount();
        
        NewEnrollmentFormCntrl.getPicklistValues('Discount__c','Type__c');
        
        discount.Type__c = ConstantClass.earlyBirdDiscount;
        discount.Days_Before_Class__c = 1;
        update discount; 
        NewEnrollmentFormCntrl.checkEarlyBirdDiscount(JSON.serialize(clsWrp));
        
        feeObj.Schedule__c = 'Fixed';
        feeObj.Frequency__c = 'One-Time';
        update feeObj;
        system.debug('curseFeeWrp-->'+curseFeeWrp);
        curseFeeWrp.tutionFeeWrapperList = NewEnrollmentFormCntrl.fetchClsTermSessionAmount(JSON.serialize(clsWrp),JSON.serialize(curseFeeWrp.tutionFeeWrapperList));
        system.assertEquals(1,curseFeeWrp.tutionFeeWrapperList.size());
        Test.stopTest();
    }
    
    public static testmethod void validateNewEnrollmentFormCntrl1(){
        Account locationObj = BlufyTestUtil.createLocationRec('New Harbor');
        insert locationObj;
        
        Account teacherObj = BlufyTestUtil.createTeacherRec('Jonas', locationObj.Id);
        insert teacherObj;
        
        Account studentObj = BlufyTestUtil.createStudentRec('Gates','test1@gmail.com');
        insert studentObj;
        
        Course__c courseObj = BlufyTestUtil.createCourseRec('French', 'Active','XYZ-01');
        insert courseObj;
        
        Class__c classObj = BlufyTestUtil.createClassRec('Name', courseObj.Id, 'Classroom', 'Open', teacherObj.Id, 20,
                                                         'Ongoing', 24, Date.today().addDays(1), Time.newInstance(10, 00, 00, 00),
                                                         'Hours', 2,'Term');
        classObj.Days_of_Week__c 	  = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun';
        classObj.Location__c          = locationObj.Id;
        classObj.End_Date__c = Date.today().addMonths(6);
        insert classObj;
        
        Term__c termObj = BlufyTestUtil.createTermRec('Term 1', '2020', 'Open',Date.today().addDays(1),Date.today().addMonths(6),12,1 );
        insert termObj;
		
		Class_Term__c classTermObj = BlufyTestUtil.createClassTerms('Term 1',classObj.id,14,Date.today().addDays(1),Date.today().addMonths(6),1, ConstantClass.ScheduledStatus ,termObj.id);
        insert classTermObj;
        
        Session__c sessionObj = BlufyTestUtil.createSessionRec(locationObj.Id,teacherObj.Id, classObj.Id, Date.today().addDays(7), Time.newInstance(10, 00, 00, 00), 'Scheduled', 'Hours', 2,'Standard');
        insert sessionObj;
        sessionObj.Class_Term__c = classTermObj.Id;
        update sessionObj;
        
        Account customerObj = new Account(LastName = 'lie',personEmail = 'Test1@gmail.com',RecordTypeId =ConstantClass.stuCustomerRecordTypeId);
        insert customerObj;
        
        Account customerObjUpdate = new Account(Id = customerObj.id, Phone = '1234567890', Block__c= 'Test', Unit__c ='Test', 
                                                BillingStreet = 'Test', BillingPostalCode = '201301', BillingCountry = 'India',
                                                Gender__c = 'Male', PersonBirthDate = Date.today(),
                                                Relationship_with_contact__c = 'Self');
        update customerObjUpdate;

        Fee__c feeObj = BlufyTestUtil.createFeeRecords('Math Monthly Fee',ConstantClass.tutionFeeType,200,true,true,'Ongoing','Term',2,90);
        feeObj.Prorate__c = true;
        insert feeObj;
        
        Course_Fee__c courseFee = BlufyTestUtil.createCourseFee(courseObj.Id,feeObj.Id);
        insert courseFee;
        
        Discount__c discount = BlufyTestUtil.createDiscount('testing',ConstantClass.referralType,Date.today().addDays(1),Date.today().addMonths(1),'Active','Amount',500,true);
        insert discount;
        
        Course_Discount__c courseDiscount =  BlufyTestUtil.createCourseDiscunt(courseObj.Id,discount.Id);
        insert courseDiscount;
        
        NewEnrollmentFormCntrl.ClassWrapper clsWrp = new NewEnrollmentFormCntrl.ClassWrapper();
        clsWrp.recNo = 1;
        clsWrp.clsId = classObj.Id;
        clsWrp.clsType = classObj.Type__c;
        clsWrp.clsFrequency = classObj.Frequency__c;
        clsWrp.locationId = locationObj.Id;
        clsWrp.location = locationObj.Name;
        clsWrp.clsDays = classObj.Days_of_Week__c;
        clsWrp.teacherName = classObj.Teacher__r.Name;
        clsWrp.slctClsTermId = classTermObj.Id;
        clsWrp.slctclsTermName = classTermObj.Name;
        clsWrp.fees = 400;
        Test.startTest();
        
        NewEnrollmentFormCntrl.fetchCourses();
        NewEnrollmentFormCntrl.getchSlcdAccDetails(customerObj.Id);
        NewEnrollmentFormCntrl.CourseFeeWrapper curseFeeWrp = NewEnrollmentFormCntrl.fetchCrsClsDetails(courseObj.Id);
        curseFeeWrp.slcdClsWrapObj = clsWrp;
        curseFeeWrp.tutionFeeWrapperList = NewEnrollmentFormCntrl.fetchClsTermSessionAmount(JSON.serialize(clsWrp),JSON.serialize(curseFeeWrp.tutionFeeWrapperList));
        system.debug('curseFeeWrp-->'+curseFeeWrp.tutionFeeWrapperList);
        curseFeeWrp.tutionFeeWrapperList[0].isSelected = true;
        NewEnrollmentFormCntrl.calculateProratedAmount(JSON.serialize(curseFeeWrp));
        
        NewEnrollmentFormCntrl.CustomerWrapper custWrp = new NewEnrollmentFormCntrl.CustomerWrapper();
        custWrp.studentDetails = studentObj;
        custWrp.stuRecNo = 1;
        custWrp.slctdClsDetails = new List<NewEnrollmentFormCntrl.CourseFeeWrapper>{curseFeeWrp};
        List<NewEnrollmentFormCntrl.CustomerWrapper> listTest = new List<NewEnrollmentFormCntrl.CustomerWrapper>{custWrp};
        NewEnrollmentFormCntrl.completeEnrolment(JSON.serialize(customerObj),JSON.serialize(listTest),JSON.serialize(curseFeeWrp.disWrapperList),500,'1','Credit Card');
        NewEnrollmentFormCntrl.addStudents(listTest);
        
        NewEnrollmentFormCntrl.blankInitializeCstmrWrpr();
        
        Test.stopTest();
        List<Enrollment__c> enrList = [SELECT Id,(SELECT Id FROM Student_Sessions__r) FROM Enrollment__c LIMIT 1];
        if(enrList.size() > 0){
            Enrollment__c enrol = enrList.get(0);
            system.assertEquals(1,enrol.Student_Sessions__r.size());
        }
    }
}