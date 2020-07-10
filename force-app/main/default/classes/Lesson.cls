public class Lesson extends Entity{
    private String le_description;
    private Decimal le_duration;
    private String le_document;
    public Lesson(){

    }
    public String Id {
        get{return super.en_id;}
        set{super.en_id = value;}
    }
    public String Name {
        get{return super.en_name;}
        set{super.en_name = value;}
    }
    public String Description {
        get{return this.le_description;}
        set{this.le_description = value;}
    }
    public Decimal Duration {
        get{return this.le_duration;}
        set{this.le_duration = value;}
    }
    public String Document {
        get{return this.le_document;}
        set{this.le_document = value;}
    }
}