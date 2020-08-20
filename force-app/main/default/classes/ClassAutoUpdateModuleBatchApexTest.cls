@isTest
public class ClassAutoUpdateModuleBatchApexTest {
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    @isTest
    static void test1(){
        Course__c crsObj  = [Select Name from Course__c];
        
        Module__c modObj  = [Select Name from Module__c];
        Module__c modObj2 = BlufyTestUtil.createModule('Module 2');
        Module__c modObj3 = BlufyTestUtil.createModule('Module 3');
        insert modObj2;
        insert modObj3;
        
        Course_Module__c crsModuleObj  = [Select Name,Sequence__c from Course_Module__c where Course__c =: crsObj.Id];
        Course_Module__c crsModuleObj2 = BlufyTestUtil.createCourseModule(modObj2.Id,crsObj.Id,2);
        Course_Module__c crsModuleObj3 = BlufyTestUtil.createCourseModule(modObj3.Id,crsObj.Id,3);
        insert crsModuleObj2;
        insert crsModuleObj3;
        
        Class__c clsObj = [Select Name,Starting_Module_Lesson__c,Current_Course_Module__c,Next_Module_Lesson__c,Auto_Update_Module__c from Class__c where Course__c =: crsObj.Id];
        clsObj.Auto_Update_Module__c     = true;
        clsObj.Current_Course_Module__c  = crsModuleObj.Id;
        clsObj.Starting_Module_Lesson__c = crsModuleObj.Id;
        clsObj.Next_Module_Lesson__c  	 = crsModuleObj2.Id;
        clsObj.Last_Session_Date__c      = System.today();
        update clsObj;
        
        Test.startTest();
        ClassAutoUpdateModuleBatchApex obj = new ClassAutoUpdateModuleBatchApex();
        Database.executeBatch(obj);
        System.assertEquals(clsObj.Current_Course_Module__c = crsModuleObj2.Id, clsObj.Current_Course_Module__c = crsModuleObj2.Id);
        Test.stopTest();
    }
}