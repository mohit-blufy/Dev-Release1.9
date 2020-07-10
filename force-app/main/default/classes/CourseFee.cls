public class CourseFee  extends Entity{
    private String cf_courseId;
    private String cf_feeId;
    private String cf_primary;
    private Fee    cf_fee;
    private Course cf_course;
    
    public CourseFee() {

    }

    public String Id {
        get{return super.en_id;}
        set{super.en_id = value;}
    }
    public String Name {
        get{return super.en_name;}
        set{super.en_name = value;}
    }
    public String CourseId {
        get{return this.cf_courseId;}
        set{this.cf_courseId = value;}
    }
    public String FeeId {
        get{return this.cf_feeId;}
        set{this.cf_feeId = value;}
    }
    public String Primary {
        get{return this.cf_primary;}
        set{this.cf_primary = value;}
    }
    public Fee Fee {
        get{return this.cf_fee;}
        set{this.cf_fee = value;}
    }
    public Course Course {
        get{return this.cf_course;}
        set{this.cf_course = value;}
    }
}