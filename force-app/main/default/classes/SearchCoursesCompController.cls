public class SearchCoursesCompController {
    
  /*  public List<Class__c> listClass {get;set;}
    public string locationValue; 
    public string categoryValue;
    public string levelValue;
    public string typeValue;
    public List<WrapperClass> listWrapperClass{get;set;}
    
    public SearchCoursesCompController(){
        listClass = new List<Class__c>();
        searchCourses();
    }
    
    public id getlocationValue(){return locationValue;}     
    public void setlocationValue(String str){
        if(str != locationValue){
            locationValue = str;
            searchCourses();
        }
    }
    
    public id getcategoryValue(){return categoryValue;}     
    public void setcategoryValue(String str){
        if(str != categoryValue){
            categoryValue = str;
            searchCourses();
        }
    } 
    
    public id getlevelValue(){return levelValue;}     
    public void setlevelValue(String str){
        if (str != levelValue){
            levelValue = str;
            searchCourses();
        }
    }
    
    public id gettypeValue(){return typeValue;}     
    public void settypeValue(String str){
        if(str != typeValue){
            typeValue = str;
            searchCourses();
        }
    }
    
    public void searchCourses(){
        Boolean isCourseAccessible = FieldPremissionCrudUtility.checkReadPermission('Course__c',new Set<String>{'Id',
            'Name','Duration__c','Duration_Type__c','Description__c'},false);
        
        Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Id',
            'Name'},false);
        
        Boolean isCourseFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('Course_Fee__c',new Set<String>{'Id',
            'Fee__c'},false);
        
        Boolean isFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('Fee__c',new Set<String>{'Id',
            'Amount__c','Type__c'},false);
        
        if(isCourseAccessible && isClassAccessible && isCourseFeeAccessible && isFeeAccessible){
            String query = ' SELECT Id,Name,Duration__c,Duration_Type__c,Description__c,(SELECT Fee__r.Amount__c ';
            query +=' FROM Course_Fee__r WHERE Fee__r.Type__c = \'Tuition Fee\'),(SELECT Id,Name, ';
            query += ' Days_of_Week__c,Start_Date__c,End_Date__c,Course__c, ';
            query += ' Teacher__c,Teacher__r.Name,Location__c,Location__r.Name, ';
            query += ' Start_Time__c,End_Time__c ';
            query += ' FROM Classes__r';
            
            if(String.isNotBlank(locationValue))
                query += ' WHERE Location__c =: locationValue ';
            system.debug('locationValue-->'+locationValue);
            query += ') FROM Course__c WHERE Class_Count__c > 0 ';
            
            if(String.isNotBlank(categoryValue))
                query += ' AND Category__c =: categoryValue ';
            
            if(String.isNotBlank(levelValue))
                query += ' AND Level__c =: levelValue '; 
            
            if(String.isNotBlank(typeValue))
                query += ' AND Type__c =: typeValue ';
            
            query += ' LIMIT 5 ';
            system.debug('query-->'+query);
            listWrapperClass = new List<WrapperClass>();
            for(Course__c course : Database.query(query)){
                if(course.Classes__r.size() > 0){
                    listWrapperClass.add(fillWrapper(course));
                }
            }
        }
    }
    
    private WrapperClass fillWrapper(Course__c course){
        WrapperClass wrpCls = new WrapperClass(); 
        wrpCls.courseId = course.Id;
        wrpCls.courseName = course.Name;
        wrpCls.courseDes = course.Description__c;
        wrpCls.courseDuration = String.valueOf(course.Duration__c);
        wrpCls.courseDurType = course.Duration_Type__c;
        wrpCls.fee = (course.Course_Fee__r.size() > 0 ? course.Course_Fee__r[0].Fee__r.Amount__c : 0); 
        wrpCls.listClass.addAll(course.Classes__r);
        return wrpCls;
    }
    
    public Class WrapperClass{
        public String courseId {get;set;}
        public String courseName {get;set;}
        public String courseDes {get;set;}
        public String courseDuration {get;set;}
        public String courseDurType {get;set;}
        public Double fee {get; set;} 
        public List<Class__c> listClass {get;set;}
        public WrapperClass(){
            listClass = new List<Class__c>();
            fee = 0;
        }
    }*/
}