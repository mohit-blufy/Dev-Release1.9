public class LineItemCalculateWrapper {
	//public Map<String,Decimal> currentTermSession;
    //public Map<String,Decimal> currentMonthSession;
    //public Map<String,Decimal> lastMonthSession;
    
    public Map<String,List<Class_Term__c>> mapOfClassTerm;
    public Map<String,List<Session__c>> mapOfClassSession;
    public LineItemCalculateWrapper(){
       // currentTermSession = new Map<String,Decimal>();
      //  currentMonthSession = new Map<String,Decimal>();
      //  lastMonthSession = new Map<String,Decimal>();
      mapOfClassSession = new Map<String,List<Session__c>>();
        mapOfClassTerm = new Map<String,List<Class_Term__c>>();
    }
}