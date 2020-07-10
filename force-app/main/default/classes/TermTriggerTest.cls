@isTest
//------- Insertion of Class Term when term status changes to Open in Classes with type ongoing & term frequency -----//
public class TermTriggerTest {
    public static testmethod void validateTermTrigger(){
        
        Course__c course  		  = BlufyTestUtil.createCourseRec('Test', 'Active', 'Test');
        insert course;
        
        Account location      	  = BlufyTestUtil.createLocationRec('Test');
        insert location;
        
        Account tch      		  = BlufyTestUtil.createTeacherRec('Test', location.Id);
        insert tch;
        
        Class__c cls   			  = BlufyTestUtil.createClassRec('Test', Course.Id, ConstantClass.classType, 
                                                                 ConstantClass.draftStatus, tch.Id, 40, 
                                                                 ConstantClass.ongoingClsType, 21, Date.today()+1,
                                                                 Time.newInstance(4,4,5,6),ConstantClass.minutesDurationPicklist,
                                                                 4, ConstantClass.termFrequency);
		insert cls;
        Class_Session__c clsSess = BlufyTestUtil.createClassSessionRec(cls.Id,Time.newInstance(10,30,00,00),120);
        insert clsSess;
        
  		// create term with different status
        List<Term__c> trmList = new List<Term__c>();
        
        trmList.add(new Term__c(Name = 'Test1', Year__c=''+System.today().year(), Status__c = ConstantClass.draftStatus, Start_Date__c = System.today().addDays(1),End_Date__c = System.today().addDays(6),
                    Sessions__c = 21, Sequence__c = 1));
        trmList.add(new Term__c(Name = 'Test2',Year__c=''+System.today().year(), Status__c = ConstantClass.draftStatus, Start_Date__c = System.today().addDays(1),End_Date__c = System.today().addDays(6),
                    Sessions__c = 24, Sequence__c = 2));        
        insert trmList;
        
        //update class for insert term as class term
        Class__c clsUpdate = new Class__c(Id = cls.Id, Status__c = ConstantClass.clsOpenStatus, 
                                          Frequency__c = ConstantClass.termFrequency, Type__c = ConstantClass.ongoingClsType);
        update clsUpdate;
        
        List<Class_Term__c> clsTermList = [select Name,id from Class_Term__c where Class__c =: cls.Id];
        System.assertEquals(0, clsTermList.size());
        
        //update term status
        Term__c trmUpdate = new Term__c(Id = trmList[0].Id, Status__c = ConstantClass.clsOpenStatus); 
        update trmUpdate;
        
        clsTermList = [select Name,id from Class_Term__c where Class__c =: cls.Id];
        System.assertEquals(1, clsTermList.size());
    }
}