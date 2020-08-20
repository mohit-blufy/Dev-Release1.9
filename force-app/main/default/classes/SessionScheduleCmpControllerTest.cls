@isTest
public class SessionScheduleCmpControllerTest {
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    public static testmethod void verifyTestMethod(){
        
        Course__c course = [SELECT Name,Status__c,code__c from Course__c];
        
        Module__c module1 = BlufyTestUtil.createModule('Module 1');
        insert module1;
        
        Module__c module2 = BlufyTestUtil.createModule('Module 2');
        insert module2;
        
        Module__c module3 = BlufyTestUtil.createModule('Module 3');
        insert module3;
        
        Module__c module4 = BlufyTestUtil.createModule('Module 4');
        insert module4;
        
        Course_Module__c cModule1 = BlufyTestUtil.createCourseModule(module1.Id,course.Id,1);
        insert cModule1;
        
        Course_Module__c cModule2 = BlufyTestUtil.createCourseModule(module2.Id,course.Id,2);
        insert cModule2;
        
        Course_Module__c cModule3 = BlufyTestUtil.createCourseModule(module3.Id,course.Id,3);
        insert cModule3;
        
        Course_Module__c cModule4 = BlufyTestUtil.createCourseModule(module4.Id,course.Id,4);
        insert cModule4;
        
        Lesson__c lesson1 = BlufyTestUtil.createLesson('lesson1','Hours',10);
        insert lesson1;
        
        Lesson__c lesson2 = BlufyTestUtil.createLesson('lesson2','Hours',10);
        insert lesson2;
        
        Lesson__c lesson3 = BlufyTestUtil.createLesson('lesson3','Hours',10);
        insert lesson3;
        
        Lesson__c lesson4 = BlufyTestUtil.createLesson('lesson4','Hours',10);
        insert lesson4;
        
        Module_Lesson__c mlesson1 = BlufyTestUtil.createModuleLesson('ML1',1,10,module1.Id,lesson1.Id);
        insert mlesson1;
        
        Module_Lesson__c mlesson2 = BlufyTestUtil.createModuleLesson('ML1',1,10,module2.Id,lesson2.Id);
        insert mlesson2;
        
        Module_Lesson__c mlesson3 = BlufyTestUtil.createModuleLesson('ML1',1,10,module3.Id,lesson3.Id);
        insert mlesson3;
        
        Module_Lesson__c mlesson4 = BlufyTestUtil.createModuleLesson('ML1',1,10,module4.Id,lesson4.Id);
        insert mlesson4;
        
        Account location      	  = [SELECT Name FROM Account WHERE RecordType.Name = 'Location' LIMIT 1];
        
        Account tch      		  = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Teacher' LIMIT 1];
        
        // Create class and Update for testing
        Class__c cls   			  = [SELECT Name,Course__c,Format__c,Status__c, Teacher__c,Capacity__c,Type__c,Sessions__c,Start_Date__c,Start_Time__c,End_Time__c,Duration__c,Frequency__c,End_Date__c from Class__c];
        
        cls.Days_of_Week__c 	 = 'Fri;Mon;Tue;Wed;Sat;Thu;Sun';
        cls.Frequency__c 		 = ConstantClass.termFrequency;
        cls.Type__c 			 = ConstantClass.ongoingClsType; 
        cls.Location__c          = location.Id;
        cls.Starting_Module__c   = cModule1.Id;
        update cls;
        
        Room__c room = [Select Name, Type__c, Location__c, Capacity__c from Room__c where Location__c =: location.Id];
        
        //create term and update for testing
        Term__c trm = [SELECT Name,Year__c,Status__c,Start_Date__c,End_Date__c,Sessions__c,Sequence__c FROM Term__c];
        
        Class_Term__c clsTrm = [select Id, Name, Class__c, Class__r.Name, Class__r.Teacher__c, Class__r.Teacher__r.Name, Start_Date__c,End_Date__c, 
                                Class__r.Start_Time__c, Class__r.End_Time__c, Class__r.Days_of_Week__c, Sessions__c, Class__r.Duration__c,
                                Exclude_Public_Holidays__c, Status__c, Class__r.Location__c
                                FROM Class_Term__c WHERE Class__c =: cls.Id AND Status__c='Draft' LIMIT 1];
        
        Class_Session__c clsSess = [Select Class__c, Start_Time__c, Duration__c from Class_Session__c where Class__c =: cls.Id];
        clsSess.Teacher__c = tch.Id;
        clsSess.Room__c    = room.Id;
        update clsSess;
        
        Teacher_Leave__c tchLeave = [SELECT Name,Start_Date__c,End_Date__c,Teacher__c,Status__c FROM Teacher_Leave__c];
        
        Location_Working_Hours__c LocationHours = new Location_Working_Hours__c(Location__c = location.Id, Active__c = true, 
                                                                                Start_Time__c = Time.newInstance(4,4,4,4), 
                                                                                Day__c = 'Sat;Sun;',
                                                                                End_Time__c = Time.newInstance(9,9,9,9));
        insert LocationHours;
        
        Teacher_Working_Hours__c tchHours = new Teacher_Working_Hours__c(Teacher__c = tch.Id, Location__c = location.Id, Active__c = true,
                                                                         Start_Time__c = Time.newInstance(4,4,5,6), Day__c = 'Sat;Sun;',
                                                                         End_Time__c = Time.newInstance(8,8,8,8));
        insert tchHours;
        
        // Create map for testing purpose
        Map<Date, Teacher_Leave__c> tchrLeaveMap = new Map<Date, Teacher_Leave__c>();
        for(Teacher_Leave__c tchrLv: [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c 
                                      FROM Teacher_Leave__c WHERE Teacher__c =: tch.Id AND 
                                      Start_Date__c != null AND End_Date__c != null AND Status__c != 'Rejected']){     
                                          for(Date stDt=tchrLv.Start_Date__c; stDt<=tchrLv.End_Date__c; stDt=stDt.addDays(1))
                                              tchrLeaveMap.put(stDt, tchrLv);
                                      }
        //create list for testing purpose
        List<String> listTeachWorkHour = new List<String>();
        for(Teacher_Working_Hours__c techWrkHour : [SELECT Id,Day__c,End_Time__c,Start_Time__c,Active__c,Teacher__c
                                                    FROM Teacher_Working_Hours__c WHERE Active__c = true AND
                                                    Teacher__c =: tch.Id AND Start_Time__c <=: cls.Start_Time__c 
                                                    AND End_Time__c >=: cls.End_Time__c]){
                                                        if(techWrkHour.Day__c.contains(cls.Days_of_Week__c)){
                                                            listTeachWorkHour.add(techWrkHour.Teacher__c);
                                                        }
                                                    }
        Test.startTest();
        SessionScheduleCmpController.WrapperClass wrpCls = SessionScheduleCmpController.generateSession(clsTrm.Id,cls.Id);
        SessionScheduleCmpController.insertSessions(SessionScheduleCmpController.generateSession(clsTrm.Id,cls.Id).sessList, clsTrm.Id);
        System.assertEquals(trm.Start_Date__c,clsTrm.Start_Date__c);
        Test.stopTest();
    }
    
}