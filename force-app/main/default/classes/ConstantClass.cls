public class ConstantClass {
    
    
    public static String customerRecTypeId     	 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    public static String corporateRecTypeId      = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
    public static String teacherRecType     	 = 'Teacher';
    
    public static String activeStatus         	 = 'Active';
    public static String inActiveStatus          = 'InActive';
    public static String tutionFeeType       	 = 'Tuition Fee';
    public static String depositFeeType      	 = 'Deposit';
    public static String ScheduledStatus     	 = 'Scheduled';
    public static String approvedStatus     	 = 'Approved';
    public static String termFrequency       	 = 'Term';
    public static String oneTimeFrequency        = 'One-time';  
    
    public static String draftStatus           	 = 'Draft';
    public static String openStatus  	    	 = 'Open';
    public static String fixedType           	 = 'Fixed';
    
    public static String earlyBirdDiscount   	 = 'Early Bird';
    public static String amountFormat          	 = 'Amount';
    public static String percentFormat       	 = 'Percent';
    
    public static String referralType         	 = 'Referral';
    public static String promoType           	 = 'Promo';
    public static String discountType        	 = 'Discount';
    
    public static String monthlyFrequency     	 = 'Monthly';
    
    public static String newEnrollmentInvType	 = 'New Enrollment';
    public static String dueStatus            	 = 'Due';
    public static String paidStatus          	 = 'Paid';
    
    public static String enrolledStatus     	 = 'Enrolled';
    public static String cancelledStatus         = 'Cancelled';
    public static String ongoingClsType      	 = 'Ongoing';
    public static String monthClsType       	 = 'Month';
    public static String issuedStatus       	 = 'Issued';
    public static String pendingStatus			 = 'Pending';
    
    public static String notAttendedStatus  	 = 'Not Attended';
    public static String feeType            	 = 'Fee';
    
    public static String clsOpenStatus  		 = 'Open';
    public static String clsClosedStatus  		 = 'Closed';
    
    public static Integer defaultNextScheDtDiff  = 1;
    public static String durationUnitHours  	 = 'Hours';
    public static String durationUnitMins  	     = 'Minutes';
    
    public static String schedulingPicklistDay   = 'Day(s)';
    public static String schedulingPicklistWeek  = 'Week(s)';
    public static String schedulingPicklistMonth = 'Month(s)';
    public static String schedulingPicklistTerm  = 'Term(s)';
    public static String holidayTypeFull         = 'Full-day';  
    
    public static String classType               = 'Online'; 
    
    public static String holidayComment          = 'It is a Holiday';
    public static String teacherNotAvailableComment = 'Teacher is not available';
    public static String teacherOnLeaveComment	 = 'Teacher is on Leave';
    public static String teacherRequestLeaveComment	 = 'Teacher has requested a leave';
    public static String teacherOccupiedComment = 'Teacher is already occupied';
    public static String roomOccupiedComment = 'Room is already occupied';
    
    public static String locationRecordsTypeId   = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
    public static String teacherRecordTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Teacher').getRecordTypeId();
    public static String stuCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    public static String primaryFeeRecordTypeId  = Schema.SObjectType.Fee__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
    public static String secondaryFeeRecordTypeId= Schema.SObjectType.Fee__c.getRecordTypeInfosByName().get('Secondary').getRecordTypeId();
    public static String inActiveCourse          = 'Inactive';
    public static String sessionCancel           = 'Canceled';
    
    public static String sessionStandardType     = 'Standard';
    public static String sessionExceptionType    = 'Exception'; 
    
    public static String termOpenStatus = 'Open';
    
    public static String sessionType = 'Placeholder';
    
    public static String creditNoteCashMode = 'Credit Note';
    public static String creditNoteStatusUtilized = 'Utilized';
    public static String minutesDurationPicklist = 'Minutes';
    
    public static boolean isSkipHolidayForMonthlySess = false;
    
}