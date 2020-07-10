/**
Name		: FullCalendarControllerTest
Date		: 23 March 2020
Author		:
Description :

*/
@isTest
public class FullCalendarControllerTest {
    @testSetup static void testDataSetup(){
        BlufyTestUtil.init();
    }
    @isTest static void FullCalendarControllerTest(){        
        FullCalendarController fullCalendarObj = new FullCalendarController();
        fullCalendarObj.refreshFilters();
        fullCalendarObj.refreshClasses();
        fullCalendarObj.refreshCourseAndClasses();
        String todayDate = fullCalendarObj.getTodayDate();
        
        system.assertEquals(todayDate,Datetime.now().format('YYYY-MM-dd'));
    }    
}