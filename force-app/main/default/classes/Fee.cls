public class Fee extends Entity{
    private String fe_type;
    private Boolean fe_required;
    private Boolean fe_override;
    private Decimal fe_amount;
    private String fe_schedule;
    private String fe_frequency;
    private Decimal fe_units;
    private Decimal fe_unitprice;
    private Boolean fe_GSTApplicable; 
    public Fee(){

    }
    public String Id {
        get{return super.en_id;}
        set{super.en_id = value;}
    }
    public String Name {
        get{return super.en_name;}
        set{super.en_name = value;}
    }
    public String Type {
        get{return this.fe_type;}
        set{this.fe_type = value;}
    }    
    public Boolean Required {
        get{return this.fe_required;}
        set{this.fe_required = value;}
    }    
    public Boolean Overrid {
        get{return this.fe_override;}
        set{this.fe_override = value;}
    }    
    public Decimal Amount {
        get{return this.fe_amount;}
        set{this.fe_amount = value;}
    }    
    public String Schedule {
        get{return this.fe_schedule;}
        set{this.fe_schedule = value;}
    }    
    public String Frequency {
        get{return this.fe_frequency;}
        set{this.fe_frequency = value;}
    }    
    public Decimal Units {
        get{return this.fe_units;}
        set{this.fe_units = value;}
    }    
    public Decimal UnitPrice {
        get{return this.fe_unitprice;}
        set{this.fe_unitprice = value;}
    }    
    public Boolean GSTApplicable {
        get{return this.fe_GSTApplicable;}
        set{this.fe_GSTApplicable = value;}
    }
}