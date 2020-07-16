/**
Name        :   LessonService
Date        :   14-07-20
Description :   This class is use for to perform DML operation on Lesson__c Object
*/
public  class LessonService {
   
    /**
    Name        :  getLessonInMap
    Date        :  14-07-20
    Description :  This function is use for to get the Lesson__c data map based on lessonId set Ids
    Dev         :  Asif
    */	
    public static Map<Id,Lesson__c> getLessonInMap(set<id> lessonIds){
        if(!lessonIds.isEmpty()){
            Map<Id,Lesson__c> lessonMap = new Map<Id,Lesson__c>();
            for(Lesson__c lessObj : [SELECT Id, Duration__c 
                                        FROM Lesson__c WHERE Id IN: lessonIds 
                                        WITH SECURITY_ENFORCED ]){
                lessonMap.put(lessObj.Id, lessObj);
            }
            return lessonMap;
        }
        return null;
    }
}
