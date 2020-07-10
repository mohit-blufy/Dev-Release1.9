public class TeacherWorkingHoursService {
    
    public void insertTeacherWorkingHours(List<Teacher_Working_Hours__c> teacherWorkingHoursList){
        if(teacherWorkingHoursList.size() > 0){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                    AccessType.CREATABLE, teacherWorkingHoursList, true);

            try {
                insert securityDecision.getRecords();  
            } catch (Exception e) {
                System.debug('Error->'+e.getMessage());
            }
                     
        }
    }
}