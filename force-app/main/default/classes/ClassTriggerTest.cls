@isTest
private class ClassTriggerTest {
    static testmethod void test1(){
        
        Course__c course  		  = BlufyTestUtil.createCourseRec('Test', 'Active', 'Test');
        insert course;        
         
        Account location      	  = BlufyTestUtil.createLocationRec('Test');
        insert location;
        
        Account tch      		  = BlufyTestUtil.createTeacherRec('Test', location.Id);
        insert tch;
        
        //create class and update
        Class__c cls   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                 ConstantClass.draftStatus, tch.Id, 40, 
                                                                 ConstantClass.ongoingClsType, 21, Date.today()+1,
                                                                 Time.newInstance(4,4,5,6),ConstantClass.minutesDurationPicklist,
                                                                 4, ConstantClass.monthlyFrequency);
        cls.Advance_Scheduling__c = 2;
        cls.Advance_Scheduling_Unit__c = 'Month(s)';
        cls.Auto_Schedule__c = true;
		insert cls;
        
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(cls.Id,Time.newInstance(10,30,00,00),120);
        insert clsSess;
        
        Class__c clsUpdate = new Class__c(Id = cls.Id, Status__c = ConstantClass.clsOpenStatus, Days_of_Week__c = 'Mon');
        update clsUpdate;
        
        Test.startTest();
        Class__c clssObj = [SELECT Id,Advance_Scheduling__c FROM Class__c WHERE Id =: clsUpdate.Id];
        System.assertEquals(2,clssObj.Advance_Scheduling__c);  
        Test.stopTest();
    }
    
    static testmethod void test2(){
        
        Course__c course  		  = BlufyTestUtil.createCourseRec('Test', 'Active', 'Test');
        insert course;        
         
        Account location      	  = BlufyTestUtil.createLocationRec('Test');
        insert location;
        
        Account tch      		  = BlufyTestUtil.createTeacherRec('Test', location.Id);
        insert tch;
        
        //create class and update
        Class__c cls   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                 ConstantClass.draftStatus, tch.Id, 40, 
                                                                 ConstantClass.fixedType, 21, Date.today()+1,
                                                                 Time.newInstance(4,4,5,6),ConstantClass.minutesDurationPicklist,
                                                                 4, ConstantClass.oneTimeFrequency);
        cls.Advance_Scheduling__c = 2;
        cls.End_Date__c = System.today().addMonths(6);
        cls.Advance_Scheduling_Unit__c = '';
        cls.Auto_Schedule__c = true;
		insert cls;
        
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(cls.Id,Time.newInstance(10,30,00,00),120);
        insert clsSess;
        
        Class__c clsUpdate = new Class__c(Id = cls.Id, Status__c = ConstantClass.clsOpenStatus, Days_of_Week__c = 'Mon');
        update clsUpdate;
        
        Test.startTest();
        Class__c clssObj = [SELECT Id,Advance_Scheduling__c FROM Class__c WHERE Id =: clsUpdate.Id];
        System.assertEquals(2,clssObj.Advance_Scheduling__c);  
        Test.stopTest();
    }
    
    static testmethod void test3(){
        
        Course__c course  		  = BlufyTestUtil.createCourseRec('Test', 'Active', 'Test');
        insert course;        
         
        Account location      	  = BlufyTestUtil.createLocationRec('Test');
        insert location;
        
        Account tch      		  = BlufyTestUtil.createTeacherRec('Test', location.Id);
        insert tch;
        
        //create class and update
        Class__c cls   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                 ConstantClass.draftStatus, tch.Id, 40, 
                                                                 ConstantClass.ongoingClsType, 21, Date.today()+1,
                                                                 Time.newInstance(4,4,5,6),ConstantClass.minutesDurationPicklist,
                                                                 4, ConstantClass.termFrequency);
        cls.Advance_Scheduling__c = 2;
        cls.Advance_Scheduling_Unit__c = 'Term(s)';
        cls.Auto_Schedule__c = true;
		insert cls;
        
        Term__c termObj = BlufyTestUtil.createTermRec('Term 1', '2020', 'Open',Date.today().addDays(1),Date.today().addMonths(6),12,1 );
        insert termObj;
        
        List<Class_Term__c> classTerms = new List<Class_Term__c>();
        Class_Term__c classTermObj = BlufyTestUtil.createClassTerms('Term 1',cls.id,10,Date.today().addDays(1),Date.today().addMonths(6),1, 'Draft',termObj.id);
        classTerms.add(classTermObj);
        
        Class_Term__c classTermObj1 = BlufyTestUtil.createClassTerms('Term 1',cls.id,10,Date.today().addMonths(7),Date.today().addMonths(8),2, 'Draft',termObj.id);
        classTerms.add(classTermObj1);
        insert classTerms;
        
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(cls.Id,Time.newInstance(10,30,00,00),120);
        insert clsSess;
        
        Class__c clsUpdate = new Class__c(Id = cls.Id, Status__c = ConstantClass.clsOpenStatus, Days_of_Week__c = 'Mon');
        update clsUpdate;
        
        Test.startTest();
        Class__c clssObj = [SELECT Id,Advance_Scheduling__c FROM Class__c WHERE Id =: clsUpdate.Id];
        System.assertEquals(2,clssObj.Advance_Scheduling__c);  
        Test.stopTest();
    }
}