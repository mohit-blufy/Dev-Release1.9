/**
Name        :   SessionModuleHelper 
Date        :   
Description :   This class is use for to align the session module records with module lesson
*/
public class SessionModuleHelper {
    
     /**
    Name        :  insertSessionModule
    Date        :  
    Description :  This function is use for to align module lesson and insert session module records
    Dev         :  Asif
    */
    public static void insertSessionModule(List<Session__c> sessionLst){
        if(sessionLst.size() > 0){
            Map<Id,List<Session__c>> sessionMap = new Map<Id,List<Session__c>>();
            Map<Id,List<Course_Module__c>> courseModuleMap = new Map<Id,List<Course_Module__c>>();
            Set<id> courseIds = new Set<id>();
            Set<Id> moduleIds = new Set<Id>();

            // ClassService clsDataObj = new ClassService();
            // ModuleLessonService modLessonDataObj = new ModuleLessonService();
            // CourseModuleService courseModDataObj = new CourseModuleService();
            // SessionModuleService sModObj = new SessionModuleService();

           // Set<Integer> classCurrentModuleSequence = new set<Integer>();
            List<Session_Module__c> sessionModList = new List<Session_Module__c>();
            //Fill session map with class Id
            for(Session__c sessObj : sessionLst){
                List<Session__c> sessionList = new List<Session__c>();
                if(sessionMap.containsKey(sessObj.class__c)){
                    sessionList = sessionMap.get(sessObj.class__c);
                    sessionList.add(sessObj);
                    sessionMap.put(sessObj.class__c,sessionList);
                }else{
                    sessionList.add(sessObj);
                    sessionMap.put(sessObj.class__c,sessionList);
                }
            }        
            //get the class data and fill the set of course id
            List<Class__c> classList =  ClassService.getClassData(sessionMap.keySet());
            if(classList.size() > 0){
                for(class__c clsObj : classList){
                    courseIds.add(clsObj.Course__c);    
                    //classCurrentModuleSequence.add(clsObj.Current_Course_Module__r.Sequence__c);
                }
                //Getting the courseModule records based on course id 
                //Filled another map of course id and list of course mdoule and also fill module id set
                List<Course_Module__c> courseModuleList = CourseModuleService.getCourseModule(courseIds);
                if(courseModuleList.size() > 0){
                    for(Course_Module__c courseModObj :courseModuleList){
                        List<Course_Module__c> cList = new List<Course_Module__c>();
                        if(courseModuleMap.containsKey(courseModObj.Course__c)){
                            cList = courseModuleMap.get(courseModObj.Course__c);
                            cList.add(courseModObj);
                            courseModuleMap.put(courseModObj.Course__c,cList);
                        }else{
                            cList.add(courseModObj);
                            courseModuleMap.put(courseModObj.Course__c,cList);
                        }
                        moduleIds.add(courseModObj.Module__c);
                    }
                    //getting the module_lesson records based on module Ids
                    List<Module_Lesson__c> moduleLessonList = ModuleLessonService.getModuleLessons(moduleIds);
                    
                    if(moduleLessonList.size() > 0){
                        //iterate class list
                        for(Class__c clsObj : classList){
                                            
                            Set<Id> newModuleIds = new Set<Id>();
                            List<Module_Lesson__c> mdList = new List<Module_Lesson__c>();
                            List<Session__c> sessionList = new List<Session__c>();
                            
                            //getting course Id of current class object and getting the course module records based on course Id
                            String courseId = clsObj.course__c;       
                            List<Course_Module__c> courseModList = courseModuleMap.get(courseId);

                            //iterate course module List and getting module Ids
                            for(Course_Module__c courseModObj : courseModList){
                                newModuleIds.add(courseModObj.module__c);
                            }

                            //getting module lesson records based on module ids
                            if(newModuleIds.size() > 0){
                                for(Module_Lesson__c moduleObj : moduleLessonList){
                                    if(newModuleIds.contains(moduleObj.Module__c) && moduleObj.Sequence__c >= clsObj.Current_Course_Module__r.Sequence__c){
                                        mdList.add(moduleObj);
                                    }
                                }
                                
                                if(mdList.size() > 0){
                                    //getting session records list based on current class object Id
                                    sessionList = sessionMap.get(clsObj.Id);
                                    sessionModList.addAll(getSessionModuleListData(sessionList, mdList));
                                }
                            }    
                        }
                    }
                }            
            }
            //Checking the list size and insert session module records
            if(sessionModList.size() > 0){            
                SessionModuleService.insertSessonModuleRecords(sessionModList);
            }        
        }
    }

    private static List<Session_Module__c> getSessionModuleListData(List<Session__c> sessionList, List<Module_Lesson__c> mdList){    
        Integer totalSession = 0;
        Integer index = 0;
        Integer currentSession = 0;        
        List<Session_Module__c> sessionModList = new List<Session_Module__c>();            
        if(mdList[0].Duration__c >= sessionList[0].Duration__c){
            if(math.mod(Integer.valueOf(mdList[0].Duration__c), Integer.valueOf(sessionList[0].Duration__c)) == 0){
                totalSession = Integer.valueOf(mdList[0].Duration__c) / Integer.valueOf(sessionList[0].Duration__c);                                
                //iterate session list  and fill session_module list
                for(Session__c sessobj : sessionList){      
                    
                    if(mdList.size()<=index){
                        break;
                    }
                    
                    Session_Module__c sessonModObj = new Session_Module__c();
                    
                    sessonModObj.Module_Lesson__c = mdList[index].Id;
                    sessonModObj.Session__c = sessobj.Id;                                                                       
                    currentSession = currentSession + 1;
                    
                    sessionModList.add(sessonModObj);
                    
                    if(currentSession == totalSession){
                        index = index +1;  
                        currentSession = 0;                                  
                    }  
                }                                        
            }                        
        }
        return sessionModList;
    }
}