public class Course  extends Entity{
    private String cr_code;
    private String cr_type;
    private String cr_level;
    private String cr_format;
    private String cr_category;
    private String cr_status;
    private String cr_description;
    private String cr_requirements;
    private String cr_conditions;
    private Decimal cr_duration;
    private Decimal cr_sequence;
    private Decimal cr_classcount;
    private List<Fee> cr_fees;
    private List<Module> cr_modules;
    private List<CourseAssessment> cr_assessments;
    public Course() {

    }
    public String Id {
        get{return super.en_id;}
        set{super.en_id = value;}
    }
    public String Name {
        get{return super.en_name;}
        set{super.en_name = value;}
    }
    public String Code {
        get{return this.cr_code;}
        set{this.cr_code = value;}
    }
    public String Type {
        get{return this.cr_type;}
        set{this.cr_type = value;}
    }
    public String Level {
        get{return this.cr_level;}
        set{this.cr_level = value;}
    }
    public String Format {
        get{return this.cr_format;}
        set{this.cr_format = value;}
    }
    public String Category {
        get{return this.cr_category;}
        set{this.cr_category = value;}
    }
    public String Status {
        get{return this.cr_status;}
        set{this.cr_status = value;}
    }
    public String Description {
        get{return this.cr_description;}
        set{this.cr_description = value;}
    }
    public String Requirements {
        get{return this.cr_requirements;}
        set{this.cr_requirements = value;}
    }
    public String Conditions {
        get{return this.cr_conditions;}
        set{this.cr_conditions = value;}
    }
    public Decimal Duration {
        get{return this.cr_duration;}
        set{this.cr_duration = value;}
    }
    public Decimal Sequence {
        get{return this.cr_sequence;}
        set{this.cr_sequence = value;}
    }
    public Decimal ClassCount {
        get{return this.cr_classcount;}
        set{this.cr_classcount = value;}
    }
    public List<Fee> Fees {
        get{return this.cr_fees;}
        set{this.cr_fees = value;}
    }
    public List<Module> Modules {
        get{return this.cr_modules;}
        set{this.cr_modules = value;}
    }
    public List<CourseAssessment> Assessments {
        get{return this.cr_assessments;}
        set{this.cr_assessments = value;}
    }
    public List<Course> getActiveCourses(){
        CourseData crsData = new CourseData();
        return crsData.getActiveCourses();
    }
    public List<Course> getFees(){
        CourseData crsData = new CourseData();
        crsData.Course = this;
        return crsData.getFees();
    }
    public List<Fee> getFeesById(String crId){
        CourseData crsData = new CourseData();
        return crsData.getFeesById(crId);
    }
    public List<Course> getAssessments(){
        CourseData crsData = new CourseData();
        crsData.Course = this;
        return crsData.getAssessments();
    }
}