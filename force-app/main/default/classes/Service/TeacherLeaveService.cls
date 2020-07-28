public class TeacherLeaveService {

    public static List<Teacher_Leave__c> getByTeacherId(set<String> setTeacherId){
        try{
            List<Teacher_Leave__c> listTeacherLeave = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c,Teacher__c 
                                                       FROM Teacher_Leave__c WHERE Teacher__c IN: setTeacherId AND 
                                                       Start_Date__c != null AND End_Date__c != null AND Status__c != 'Rejected'
                                                       WITH SECURITY_ENFORCED];
            return listTeacherLeave;
        } catch(System.QueryException e){
            System.debug(e.getMessage());
        }
        return null;
    }
}
