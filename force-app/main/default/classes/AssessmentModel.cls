public class AssessmentModel extends Entity{
    private String am_module;
    private String am_lesson;
    public AssessmentModel(){

    }
    public String Module {
        get{return this.am_module;}
        set{this.am_module = value;}
    }
    public String Lesson {
        get{return this.am_lesson;}
        set{this.am_lesson = value;}
    }
}