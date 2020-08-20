/**
Name        :   LessonService
Date        :   14-07-20
Description :   This class is use for to perform DML operation on Lesson__c Object
*/
public  class LessonService {
   
    /**
    getById on 14-07-20  get the Lesson__c list based on lessonId set Ids
    */	
    public static List<Lesson__c> getById(set<id> lessonIds){    
            return [SELECT Id, Duration__c 
                    FROM Lesson__c WHERE Id IN: lessonIds 
                    WITH SECURITY_ENFORCED ];
    }
}