/**
	Name		: FullCalendarDataServiceTest
	Date		: 23 March 2020	
	Description :
	
*/
@isTest
public class FullCalendarDataServiceTest {
    static testmethod void validateDataServicesControllerMethod1() {
        BlufyTestUtil.init();
        
        List<Account>   locationList = [SELECT Id,Name FROM Account WHERE recordtypeid =: ConstantClass.locationRecordsTypeId];
        System.assert(locationList.size() > 0, 'Fail to create Location!');
        
        List<Account>   teacherList = [SELECT Id,Name FROM Account WHERE recordtypeid =: ConstantClass.teacherRecordTypeId];
        System.assert(teacherList.size() > 0, 'Fail to create Teacher!');
        
        List<Course__c> cousrList = [SELECT id,Name FROM Course__c WHERE status__c !=: ConstantClass.inActiveCourse];
        System.assert(cousrList.size() > 0, 'Fail to create Course!');
        
        List<Class__c>  classList = [SELECT id,Name FROM Class__C WHERE Course__c =: cousrList[0].Id AND Teacher__c =: teacherList[0].Id];
        System.assert(classList.size() > 0, 'Fail to create Class!');
        
        List<Session__c> sessionList = [SELECT Id, Name, Sequence__c, Class__c, Session_Date__c, Start_Time__c, End_Time__c, Teacher__c,Teacher__r.Name, Status__c, Event_Color__c  FROM Session__c WHERE Status__c !=: ConstantClass.sessionCancel];
        System.assert(sessionList.size() > 0, 'Fail to create  Session!');
        
        String classIds = '\''+ classList[0].Id + '\'';
       // Date startDate = Date.newInstance(2020,03,24);
        String startDate = '2020-03-24';
        String endDate = '2020-03-29';
        String newTime = '12:0:0';
        Integer dayDiff = 2;
        Integer previousDay = 1;
        String repeat = 'Daily';
        String duration = '02:00';
        String description = 'Daily checkup';
        
        FullCalendarDataService.fetchSessions(teacherList[0].Id, locationList[0].Id, classIds, cousrList[0].Id, true );
        FullCalendarDataService.fetchSessionsByDate(teacherList[0].Id, locationList[0].Id, startDate, classIds, cousrList[0].Id, true);
        FullCalendarDataService.fetchSessionsByWeek(teacherList[0].Id, locationList[0].Id, startDate, endDate, classIds, cousrList[0].Id, true);
        FullCalendarDataService.getWorkingHours(locationList[0].Id);
        FullCalendarDataService.getTeacherWorkingHours(locationList[0].Id);
        FullCalendarDataService.setNewSessionTiming(sessionList[0].Id, teacherList[0].Id, newTime, startDate);
        FullCalendarDataService.setNewTimeForAllSession(sessionList[0].Id, newTime);
        FullCalendarDataService.setNewDateTimeForCurrentAndUpComingSession(sessionList[0].Id, newTime, dayDiff, previousDay, '');
        FullCalendarDataService.insertNewSession(locationList[0].Id, teacherList[0].Id, newTime, startDate, duration, endDate, repeat, description);
        repeat = 'None';
        FullCalendarDataService.insertNewSession(locationList[0].Id, teacherList[0].Id, newTime, startDate, duration, endDate, repeat, description);
        FullCalendarDataService.getTeacherLeaves(teacherList[0].Id);
        FullCalendarDataService.getHolidays(startDate);
    }
}