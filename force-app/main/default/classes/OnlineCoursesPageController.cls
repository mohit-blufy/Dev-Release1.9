public class OnlineCoursesPageController {
   /* public string location {get;set;}
    public string category {get;set;}
    public string level {get;set;}
    public string type {get;set;}
    public List<SelectOption> listLocation {get;set;}
    public List<SelectOption> listCategory {get;set;}
    public List<SelectOption> listLevel {get;set;}
    public List<SelectOption> listType {get;set;}
    public Integer countFilter {get;set;}
    
    public OnlineCoursesPageController(){
        location = '';
        category = '';
        level = '';
        type = '';
        countFilter = 0;
        listLocation = new List<SelectOption>();
        listCategory = new List<SelectOption>();
        listLevel = new List<SelectOption>();
        listType = new List<SelectOption>();
        getFiltersData();
    }
    
    private void getFiltersData(){
        List<String> listFilterVisibility = new List<String>();
        for(Online_Process_Config__mdt metaData : [SELECT Field_Api_Name__c FROM Online_Process_Config__mdt
                                                            WHERE Active__c = true AND Type__c = 'Filter'
                                                            AND Section__c = 'Course Filter']){
                                                                listFilterVisibility.add(metaData.Field_Api_Name__c);                                            
                                                            }
        system.debug('listFilterVisibility-->'+listFilterVisibility);
        if(listFilterVisibility.size() > 0){
             countFilter = listFilterVisibility.size();
            if(listFilterVisibility.contains('Location')){
                for(Account acc : [SELECT Id,Name FROM Account WHERE RecordType.Name = 'Location']){
                    listLocation.add(new SelectOption(acc.Id,acc.Name));
                }
            }
            
            if(listFilterVisibility.contains('Category__c')){
                for(String catValue : UtilityClass.getPickValues('Course__c','Category__c')){
                    listCategory.add(new SelectOption(catValue,catValue));
                }
            }
            
            if(listFilterVisibility.contains('Level__c')){
                for(String levValue : UtilityClass.getPickValues('Course__c','Level__c')){
                    listLevel.add(new SelectOption(levValue,levValue));
                }
            }
            
            if(listFilterVisibility.contains('Type__c')){
                for(String typValue : UtilityClass.getPickValues('Course__c','Type__c')){
                    listType.add(new SelectOption(typValue,typValue));   
                }
            }
        }
    }   */
}