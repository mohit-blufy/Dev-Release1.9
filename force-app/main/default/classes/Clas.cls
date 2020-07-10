public class Clas extends Entity{ 
    private String  cl_advancebillingunit;
    private String  cl_advanceschedulingunit;
    private String  cl_daysofweek;
    private String  cl_description;
    private String  cl_durationunit;
    private String  cl_status;
    private String  cl_type;
    private String  cl_frequency;
    private String  cl_format;   
    private Boolean cl_allowoverbooking;
    private Boolean cl_autobilling;
    private Boolean cl_autoschedule;
    private Decimal cl_advancebilling;
    private Decimal cl_advancescheduling;
    private Decimal cl_capacity;
    private Decimal cl_duration;
    private Decimal cl_enrollments;
    private Decimal cl_seatsavailable;
    private Date cl_startdate;
    private Date cl_enddate;
    private Date cl_lastsessiondate;
    private Date cl_lastsessionscheduleddate;
    private Date cl_nextscheduledate;
    private Time cl_starttime;
    private Time cl_endtime;

    private Course course;
    //private Account location;
    //private Account teacher;
    //private moduleLess Current_Module_Lesson;
    public Clas(){

    }
    public String Id {
        get{return super.en_id;}
        set{super.en_id = value;}
    }
    public String Name {
        get{return super.en_name;}
        set{super.en_name = value;}
    }

    public String  AdvanceBillingUnit{
        get{return this.cl_advancebillingunit;}
        set{this.cl_advancebillingunit = value;}
    }
    public String  AdvanceSchedulingUnit{
        get{return this.cl_advanceschedulingunit;}
        set{this.cl_advanceschedulingunit = value;}
    }
    public String  DaysOfWeek{
        get{return this.cl_daysofweek;}
        set{this.cl_daysofweek = value;}
    }
    public String  Description0{
        get{return this.cl_daysofweek;}
        set{this.cl_daysofweek = value;}
    }
    public String  DurationUnit{
        get{return this.cl_durationunit;}
        set{this.cl_durationunit = value;}
    }
    public String  Status{
        get{return this.cl_status;}
        set{this.cl_status = value;}
    }
    public String  Type{
        get{return this.cl_status;}
        set{this.cl_status = value;}
    }
    public String  Frequency{
        get{return this.cl_frequency;}
        set{this.cl_frequency = value;}
    }
    public String  Format{
        get{return this.cl_format;}
        set{this.cl_format = value;}
    }   
    public Boolean AllowOverBooking{
        get{return this.cl_allowoverbooking;}
        set{this.cl_allowoverbooking = value;}
    }
    public Boolean Autobilling{
        get{return this.cl_autobilling;}
        set{this.cl_autobilling = value;}
    }
    public Boolean AutoSchedule{
        get{return this.cl_autoschedule;}
        set{this.cl_autoschedule = value;}
    }
    public Decimal AdvanceBilling{
        get{return this.cl_advancebilling;}
        set{this.cl_advancebilling = value;}
    }
    public Decimal AdvanceScheduling{
        get{return this.cl_advancescheduling;}
        set{this.cl_advancescheduling = value;}
    }
    public Decimal Capacity{
        get{return this.cl_capacity;}
        set{this.cl_capacity = value;}
    }
    public Decimal Duration{
        get{return this.cl_duration;}
        set{this.cl_duration = value;}
    }
    public Decimal Enrollments{
        get{return this.cl_enrollments;}
        set{this.cl_enrollments = value;}
    }
    public Decimal SeatsAvailable{
        get{return this.cl_seatsavailable;}
        set{this.cl_seatsavailable = value;}
    }
    public Date StartDate{
        get{return this.cl_startdate;}
        set{this.cl_startdate = value;}
    }
    public Date EndDate{
        get{return this.cl_enddate;}
        set{this.cl_enddate = value;}
    }
    public Date LastSessionDate{
        get{return this.cl_lastsessiondate;}
        set{this.cl_lastsessiondate = value;}
    }
    public Date LastSessionScheduledDate{
        get{return this.cl_lastsessionscheduleddate;}
        set{this.cl_lastsessionscheduleddate = value;}
    }
    public Date NextScheduleDate{
        get{return this.cl_nextscheduledate;}
        set{this.cl_nextscheduledate = value;}
    }
    public Time StartTime{
        get{return this.cl_starttime;}
        set{this.cl_starttime = value;}
    }
    public Time EndTime{
        get{return this.cl_endtime;}
        set{this.cl_endtime = value;}
    }
}