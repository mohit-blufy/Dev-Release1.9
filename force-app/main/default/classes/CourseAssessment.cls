public class CourseAssessment extends Entity{
    private List<AssessmentModel> ca_model;
    public CourseAssessment(){

    }
    public List<AssessmentModel> Models{
        get{return this.ca_model;}
        set{this.ca_model = value;}
    }
}