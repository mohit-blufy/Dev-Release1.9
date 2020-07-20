/*
Name: NewEnrollmentFormCntrl
Date: 30th Jan 2020
Author: 
Description: This controller is used create new enrollments 
*/
public class NewEnrollmentFormCntrl {
    static Boolean isCourseAccessible = FieldPremissionCrudUtility.checkReadPermission('Course__c',new Set<String>{'Id', 'Name', 'Status__c'},false);
    static Boolean isFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('Fee__c',new Set<String>{'Id', 'Name', 'Amount__c',
        'Unit_Price__c','Schedule__c','Units__c','Type__c','Frequency__c','Required__c','Override__c','Amount__c'},false);
    static Boolean isCourseFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('Course_Fee__c', new Set<String>{'Id', 'Name',
        'Course__c','Fee__c'},false);
    static Boolean isDiscountAccessible = FieldPremissionCrudUtility.checkReadPermission('Discount__c',new Set<String>{'Id', 'Name', 
        'Days_Before_Class__c','Value__c','Override__c','Required__c','Type__c','Format__c','Global__c','Active__c','Start_Date__c','End_Date__c'},false);
    static Boolean isCourseDiscAccessible = FieldPremissionCrudUtility.checkReadPermission('Course_Discount__c',new Set<String>{'Id', 'Name',
        'Course__c','Discount__c'},false);
    static Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Id', 'Name', 'Sequence__c',
        'Start_Date__c','End_Date__c','Start_Time__c','End_Time__c','Location__c','Teacher__c','Type__c','Status__c','Capacity__c','Days_of_Week__c',
        'Seats_Available__c','Frequency__c','Allow_Enrollment__c','Advance_Billing_Unit__c','Advance_Billing__c'},false);
    static Boolean isClassTermAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Id', 'Name', 'Sequence__c',
        'Start_Date__c','End_Date__c','Teacher__c','Status__c'},false);
    static Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c',new Set<String>{'Id', 'Class__c', 
        'Class_Term__c', 'Sequence__c','Session_Date__c','Teacher__c','Status__c'},false);
    static Boolean isAccountAccessible = FieldPremissionCrudUtility.checkReadPermission('Account',new Set<String>{'Id', 'Name', 'RecordTypeId', 
        'FirstName', 'LastName', 'PersonEmail','Phone','Block__c','Unit__c','BillingStreet','BillingPostalCode', 'BillingCountry', 'Gender__c', 
        'PersonBirthdate','Relationship_with_contact__c'},false);
    static Boolean isBlufyConfigAccessible = FieldPremissionCrudUtility.checkReadPermission('Blufy_Config__mdt',new Set<String>{'Id','MasterLabel', 
        'Monthly_Invoice_Cycle__c', 'Overlap_Holiday_For_Monthly_Session__c', 'Terms_and_Conditions_Description__c','Terms_and_Conditions_Title__c'},false);
    //static CourseFeeData crsFeeData = new CourseFeeData();
    
    //Its used for fetch active course records
    @auraEnabled
    public static List<Course__c> fetchCourses(){   
        if(isCourseAccessible)
            return [select Id, Name  from Course__c WHERE Status__c =: ConstantClass.activeStatus ORDER BY Name ];
        else
            return null;
    }
    
    //This function is used to get dynmically picklist values of the object
    @auraEnabled
    public static Map<String,String> fetchTermAndCondition(){ 
        Map<String,String> configMap = new Map<String,String>();      
        if(isBlufyConfigAccessible){
            List<Blufy_Config__mdt> systemConfig = [SELECT Terms_and_Conditions_Description__c,Terms_and_Conditions_Title__c FROM Blufy_Config__mdt WHERE DeveloperName='Default'];
            if(systemConfig.size() > 0){
                configMap.put('TermsTitle',systemConfig[0].Terms_and_Conditions_Title__c);
                configMap.put('TermsDesription',systemConfig[0].Terms_and_Conditions_Description__c);
            }
            return configMap;
        }
        else{
            System.debug('Metadata Not Accessible');
            return null;
        }
        
    }
    
    
    //This function is used to get selected contact details when user select existing customer
    @auraEnabled
    public static Account getchSlcdAccDetails(String accId){
        Account acc = new Account();
        if(isAccountAccessible){
            List<Account> accList = [SELECT Id, FirstName, LastName, PersonEmail, Phone, Block__c, Unit__c, BillingStreet,
                                     BillingPostalCode, BillingCountry, Gender__c, PersonBirthDate, Relationship_with_contact__c
                                     FROM Account WHERE Id=:accId LIMIT 1];
            if(accList.size() > 0){
                acc= accList.get(0);
                /*
Map<String, String> pickLstMap = UtilityClass.getPickValues('Account', 'BillingCountryCode');
Map<String, String> pickLstTempMap = new Map<String, String>();
for(String str: pickLstMap.keySet()){
pickLstTempMap.put(pickLstMap.get(str), str);
}
if(String.isNotBlank(acc.BillingCountryCode) && pickLstTempMap.containsKey(acc.BillingCountryCode))
acc.BillingCountryCode = pickLstTempMap.get(acc.BillingCountryCode);*/
            }
        }
        return acc;
    }
    
    //This function is used to fetch course classes when user select specific course
    @auraEnabled
    public static CourseFeeWrapper fetchCrsClsDetails(String crId){
        CourseFeeWrapper crsFeeWrap = new CourseFeeWrapper();
        List<ClassWrapper> cwList   = new List<ClassWrapper>();
        List<DisWrapper>   disList  = new List<DisWrapper>();
        
        if(isCourseFeeAccessible && isClassAccessible && isCourseDiscAccessible){
            /*for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c, Fee__r.Override__c
FROM Course_Fee__c WHERE Course__c =: crId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null]){

FeeWrapper fw = new FeeWrapper();
fw.feeId      = crFee.Fee__c;
fw.feeName    = crFee.Fee__r.Name;
fw.feeType    = crFee.Fee__r.Type__c;
fw.payFrequency = crFee.Fee__r.Frequency__c;  
fw.feeAmount   = crFee.Fee__r.Amount__c;
fw.feeSchType  = crFee.Fee__r.Schedule__c;  
fw.noOfUnit    = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;   
if(crFee.Fee__r.Type__c == ConstantClass.depositFeeType){
fw.isSelected = crFee.Fee__r.Required__c;
fw.isOverride = crFee.Fee__r.Override__c;
crsFeeWrap.depositWrapperList.add(fw);
if(fw.isSelected){
crsFeeWrap.totFee += fw.feeAmount; 
crsFeeWrap.totWithProratedFee += fw.feeAmount;
}
}else if(crFee.Fee__r.Type__c != ConstantClass.tutionFeeType){
fw.isSelected = crFee.Fee__r.Required__c;
fw.isOverride = crFee.Fee__r.Override__c;
crsFeeWrap.feeWrapperList.add(fw);
if(fw.isSelected){
crsFeeWrap.totFee += fw.feeAmount; 
crsFeeWrap.totWithProratedFee += fw.feeAmount;
}
}                      
}*/
            //CourseFeeData crsFeeData = new CourseFeeData();
            //List<CourseFee> crFeeLs  = crsFeeData.getByCourseId(crId);
            List<Course_Fee__c> listCourseFee = CourseFeeService.getByCourseIdWithSharing(crId);
            //if(crFeeLs != null){
            if(listCourseFee != null && listCourseFee.size() > 0){
                for(Course_Fee__c crFee: listCourseFee){
                    FeeWrapper fw = new FeeWrapper();
                    fw.feeId      = crFee.Fee__c;
                    fw.feeName    = crFee.Fee__r.Name;
                    fw.feeType    = crFee.Fee__r.Type__c;
                    fw.payFrequency = crFee.Fee__r.Frequency__c;  
                    fw.feeAmount   = crFee.Fee__r.Amount__c;
                    fw.feeSchType  = crFee.Fee__r.Schedule__c;  
                    fw.noOfUnit    = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;
                    fw.isGSTApplicable = crFee.Fee__r.GST_Applicable__c;
                    
                    if(crFee.Fee__r.Type__c == ConstantClass.depositFeeType){
                        fw.isSelected = crFee.Fee__r.Required__c;
                        fw.isOverride = crFee.Fee__r.Override__c;
                        crsFeeWrap.depositWrapperList.add(fw);
                        if(fw.isSelected){
                            crsFeeWrap.totFee += fw.feeAmount; 
                            crsFeeWrap.totWithProratedFee += fw.feeAmount;
                        }
                    }else if(crFee.Fee__r.Type__c != ConstantClass.tutionFeeType){
                        fw.isSelected = crFee.Fee__r.Required__c;
                        fw.isOverride = crFee.Fee__r.Override__c;
                        crsFeeWrap.feeWrapperList.add(fw);
                        if(fw.isSelected){
                            crsFeeWrap.totFee += fw.feeAmount; 
                            crsFeeWrap.totWithProratedFee += fw.feeAmount;
                        }
                    } 
                }
            }
            
            
            Integer counter = 0;
            for(Class__c cls:[SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c, Location__r.Name, 
                              Teacher__r.Name, Type__c, Frequency__c, Status__c, Capacity__c, Days_of_Week__c, Seats_Available__c,
                              (SELECT Id, Name, Start_Date__c, End_Date__c,Sessions__c, Status__c FROM  Class_Terms__r
                               WHERE Status__c =:ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND
                               Sessions__c > 0 AND  Start_Date__c != null AND  End_Date__c != null ORDER BY Sequence__c)
                              FROM Class__c 
                              WHERE Course__c =:crId AND  Type__c != null AND Frequency__c != null AND (Status__c =: ConstantClass.clsOpenStatus OR (Allow_Overbooking__c = True AND Status__c =: ConstantClass.clsClosedStatus))]){   
                                  
                                  //     for(Class_Term__c clsTerm : cls.Class_Terms__r){
                                  //if(clsTerm.End_Date__c >= System.today()){
                                  
                                  ClassWrapper cw = new ClassWrapper();
                                  // cw.recNo        = counter;
                                  cw.clsId        = cls.Id;                  
                                  cw.clsName      = cls.Name;
                                  cw.clsDays      = cls.Days_of_Week__c;     
                                  cw.clsType      = cls.Type__c;    
                                  cw.clsFrequency	= cls.Frequency__c;
                                  cw.locationId   = cls.Location__c;
                                  cw.location     = cls.Location__r.Name;
                                  cw.teacherName  = cls.Teacher__r.Name;
                                  cw.clsEndDate   = (cls.End_Date__c != NULL ? cls.End_Date__c : null);
                                  //  cw.clsTermId    = clsTerm.Id;
                                  //cw.clsTermName  = clsTerm.Name;
                                  cw.seatsAlv     = cls.Seats_Available__c != null ? Integer.valueOf(cls.Seats_Available__c) : 0;
                                  
                                  //  if(clsTerm.Start_Date__c != null)
                                  //    cw.stEndDate    = Datetime.newInstance(clsTerm.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM');  
                                  //if(clsTerm.End_Date__c != null)
                                  //  cw.stEndDate    += ' - '+Datetime.newInstance(clsTerm.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM yyyy');
                                  
                                  if(cls.Start_Time__c != null)
                                      cw.stEndTime= Datetime.newInstance(System.today(), cls.Start_Time__c).format('hh:mm a');
                                  if(cls.End_Time__c != null)
                                      cw.stEndTime += ' - '+ Datetime.newInstance(System.today(), cls.End_Time__c).format('hh:mm a');    
                                  
                                  
                                  //}
                                  //}
                                  
                                  //For Monthly classes        
                                  if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){        
                                      counter  = counter + 1;     
                                      cw.recNo = counter;               
                                      cwList.add(cw);     
                                  }else{//For fixed Term and fixed classes                 
                                      for(Class_Term__c clsTerm : cls.Class_Terms__r){
                                          if(clsTerm.End_Date__c >= System.today()){
                                              TermWrapper tm = new TermWrapper();
                                              tm.clsTermId = clsTerm.Id;
                                              tm.clsTermName = clsTerm.Name;
                                              if(clsTerm.Start_Date__c != null)
                                                  tm.stEndDate    = Datetime.newInstance(clsTerm.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM');  
                                              if(clsTerm.End_Date__c != null)
                                                  tm.stEndDate    += ' - '+Datetime.newInstance(clsTerm.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM yyyy');
                                              
                                              cw.termList.add(tm);
                                          }
                                      }
                                      if(cw.termList.size() > 0){
                                          counter = counter + 1; 
                                          cw.recNo = counter;  
                                          cwList.add(cw); 
                                      }
                                  }
                              }
            
            for(Course_Discount__c crsDis: [SELECT Id, Name, Discount__c, Discount__r.Name, Discount__r.Days_Before_Class__c, Discount__r.Value__c, Discount__r.Override__c, Discount__r.Required__c,
                                            Discount__r.Type__c, Discount__r.Format__c, Discount__r.Start_Date__c, Discount__r.End_Date__c 
                                            FROM Course_Discount__c 
                                            WHERE Course__c =:crId AND Discount__r.Format__c != null AND Discount__r.Global__c=False AND 
                                            Discount__r.Active__c = True AND Discount__r.Value__c != null AND Discount__r.Type__c !=:ConstantClass.earlyBirdDiscount]){
                                                
                                                Decimal amtVal = 0;
                                                if(crsDis.Discount__r.Format__c.equalsIgnoreCase(ConstantClass.amountFormat)){
                                                    amtVal = crsDis.Discount__r.Value__c;
                                                }else if(crsDis.Discount__r.Format__c.equalsIgnoreCase(ConstantClass.percentFormat)){
                                                    //  amtVal = crsDis.Discount__r.Value__c;
                                                }
                                                
                                                DisWrapper dw = new DisWrapper();
                                                dw.disId      = crsDis.Discount__c;
                                                dw.isSelected = crsDis.Discount__r.Required__c;
                                                dw.isOverride = crsDis.Discount__r.Override__c;
                                                dw.name       = crsDis.Discount__r.Name;
                                                dw.amount     = amtVal;
                                                dw.type       = crsDis.Discount__r.Type__c;
                                                
                                                if(dw.isSelected){
                                                    crsFeeWrap.totFee -= dw.amount; 
                                                    crsFeeWrap.totWithProratedFee -= dw.amount;
                                                }
                                                
                                                disList.add(dw);
                                            }
            
            crsFeeWrap.classWrapperList.addAll(cwList);
            crsFeeWrap.disWrapperList.addAll(disList);
        }
        return crsFeeWrap;
    }
    
    //This function is used to get class term amount on the bases of class term session and selected course unit price
    @auraEnabled
    public static List<FeeWrapper> fetchClsTermSessionAmount(String clsStr, String tutionFeeWrapperListStr){
        /* List<Class_Term__c> clsTermList = [SELECT Id, Name, Sessions__c FROM Class_Term__c WHERE Id=: cls.clsTermId];
if(clsTermList.size() > 0){
for(FeeWrapper fw : tutionFeeWrapperList){
if(fw.payFrequency == ConstantClass.termFrequency){
fw.feeAmount = fw.tutionFeeUnitPrice*clsTermList.get(0).Sessions__c;
}
}
}*/
        ClassWrapper cls = (ClassWrapper) System.JSON.deserialize(clsStr, ClassWrapper.class);
        List<FeeWrapper> tutionFeeWrapperList = String.isNotBlank(tutionFeeWrapperListStr) ? (List<FeeWrapper>) JSON.deserialize(tutionFeeWrapperListStr,List<FeeWrapper>.class) : new List<FeeWrapper>(); 
        
        tutionFeeWrapperList = new List<FeeWrapper>();
        if(isCourseFeeAccessible && isClassAccessible){
            List<Class__c> clsList = [SELECT Id, Name, Course__c, Start_Date__c, End_Date__c, Type__c, Frequency__c FROM Class__c
                                      WHERE Id =:cls.clsId];
            if(clsList.size() > 0){
                /*   for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c,Fee__r.Schedule__c, Fee__r.Units__c, 
Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c, Fee__r.Override__c
FROM Course_Fee__c 
WHERE Course__c =: clsList.get(0).Course__c AND Fee__r.Amount__c != null
AND Fee__r.Type__c =: ConstantClass.tutionFeeType]){

FeeWrapper fw = new FeeWrapper();
fw.feeId      = crFee.Fee__c;
fw.feeName    = crFee.Fee__r.Name;
fw.feeType    = crFee.Fee__r.Type__c;
fw.payFrequency = crFee.Fee__r.Frequency__c;  
fw.feeAmount = crFee.Fee__r.Amount__c;
fw.tutionFeeUnitPrice = crFee.Fee__r.Unit_Price__c;
fw.isSelected = crFee.Fee__r.Required__c;
fw.isOverride = crFee.Fee__r.Override__c;                                                   
fw.feeSchType  = crFee.Fee__r.Schedule__c;  
fw.noOfUnit    = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;                                    
tutionFeeWrapperList.add(fw);                        
}*/
                //CourseFeeData crsFeeData = new CourseFeeData();
               // List<CourseFee> crFeeLs  = crsFeeData.getByCourseIdOrType(clsList.get(0).Course__c, ConstantClass.tutionFeeType, clsList.get(0).Frequency__c);
                List<Course_Fee__c> listCourseFee = CourseFeeService.getByCourseIdOrTypeWithSharing(clsList.get(0).Course__c, ConstantClass.tutionFeeType, clsList.get(0).Frequency__c);
                //if(crFeeLs != null){
                    if(listCourseFee != NULL && listCourseFee.size() > 0){
                    for(Course_Fee__c crFee: listCourseFee){
                        FeeWrapper fw = new FeeWrapper();
                        fw.feeId      = crFee.Fee__c;
                        fw.feeName    = crFee.Fee__r.Name;
                        fw.feeType    = crFee.Fee__r.Type__c;
                        fw.payFrequency = crFee.Fee__r.Frequency__c;  
                        fw.feeAmount = crFee.Fee__r.Amount__c;
                        fw.tutionFeeUnitPrice = crFee.Fee__r.Units__c;
                        // fw.isSelected = crFee.Fee.Required;
                        fw.isOverride = crFee.Fee__r.Override__c;                                                   
                        fw.feeSchType  = crFee.Fee__r.Schedule__c;  
                        fw.noOfUnit    = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;  
                        fw.isGSTApplicable = crFee.Fee__r.GST_Applicable__c;
                        tutionFeeWrapperList.add(fw);  
                    }
                }
            }                            
        }
        return tutionFeeWrapperList;
    }
    
    //This function is used to Edis selected courses, So in this we were fetching all course and class details
    @auraEnabled
    public static CourseFeeWrapper editCrsClsDetails(String cfStr){
        CourseFeeWrapper cf = (CourseFeeWrapper) System.JSON.deserialize(cfStr, CourseFeeWrapper.class);
        
        CourseFeeWrapper crsFeeWrap = cf;
        if(isCourseFeeAccessible && isClassAccessible && isClassTermAccessible){
            
            String clsId = cf.slcdClsWrapObj.clsId;
            crsFeeWrap.classWrapperList     = new List<ClassWrapper>();
            
            List<ClassWrapper> cwList = new List<ClassWrapper>();
            if(String.isNotBlank(clsId)){
                Set<String> slcdFee = new Set<String>();
                
                for(FeeWrapper fw : crsFeeWrap.tutionFeeWrapperList){
                    slcdFee.add(fw.feeId);
                }
                for(FeeWrapper fw : crsFeeWrap.depositWrapperList){
                    slcdFee.add(fw.feeId);
                }
                for(FeeWrapper fw : crsFeeWrap.feeWrapperList){
                    slcdFee.add(fw.feeId); 
                }
                
                List<Class__c> clsList = [SELECT Id, Name, Start_Date__c, Course__c, Frequency__c FROM Class__c WHERE Id =:clsId];
                if(clsList.size() > 0){
                    String   crId= clsList.get(0).Course__c;
                    
                    /*for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Schedule__c,Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c,Fee__r.Override__c
FROM Course_Fee__c WHERE Course__c =:crId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null]){

FeeWrapper fw = new FeeWrapper();
fw.feeId      = crFee.Fee__c;                         
fw.feeName    = crFee.Fee__r.Name;
fw.feeType    = crFee.Fee__r.Type__c;
fw.payFrequency = crFee.Fee__r.Frequency__c;  
fw.feeAmount = crFee.Fee__r.Amount__c;
fw.isSelected = crFee.Fee__r.Required__c;
fw.isOverride = crFee.Fee__r.Override__c;
//  fw.tutionFeeUnitPrice = crFee.Fee__r.Unit_Price__c;
fw.feeSchType  = crFee.Fee__r.Schedule__c;  
fw.noOfUnit    = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;   

if(crFee.Fee__r.Type__c == ConstantClass.tutionFeeType){
if(!slcdFee.contains(crFee.Fee__c) &&  crFee.Fee__r.Frequency__c==clsList.get(0).Frequency__c)
crsFeeWrap.tutionFeeWrapperList.add(fw);
}else if(crFee.Fee__r.Type__c == ConstantClass.depositFeeType){                       
if(!slcdFee.contains(crFee.Fee__c))
crsFeeWrap.depositWrapperList.add(fw);
}else{
if(!slcdFee.contains(crFee.Fee__c))
crsFeeWrap.feeWrapperList.add(fw);
}   
}*/
                    //  CourseFeeData crsFeeData = new CourseFeeData();
                    //List<CourseFee> crFeeLs  = crsFeeData.getByCourseId(crId);
                    List<Course_Fee__c> listCourseFee = CourseFeeService.getByCourseIdWithSharing(crId);
                    //if(crFeeLs != null){
                    if(listCourseFee != NULL && listCourseFee.size() > 0){
                        for(Course_Fee__c crFee: listCourseFee){
                            FeeWrapper fw = new FeeWrapper();
                            fw.feeId      = crFee.Fee__c;                         
                            fw.feeName    = crFee.Fee__r.Name;
                            fw.feeType    = crFee.Fee__r.Type__c;
                            fw.payFrequency = crFee.Fee__r.Frequency__c;  
                            fw.feeAmount  = crFee.Fee__r.Amount__c;
                            fw.isSelected = crFee.Fee__r.Required__c;
                            fw.isOverride = crFee.Fee__r.Override__c;
                            fw.isGSTApplicable = crFee.Fee__r.GST_Applicable__c;
                            //  fw.tutionFeeUnitPrice = crFee.Fee__r.Unit_Price__c;
                            fw.feeSchType = crFee.Fee__r.Schedule__c;  
                            fw.noOfUnit   = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;   
                            
                            if(crFee.Fee__r.Type__c == ConstantClass.tutionFeeType){
                                fw.isSelected = false;
                                if(!slcdFee.contains(crFee.Fee__c) &&  crFee.Fee__r.Frequency__c ==clsList.get(0).Frequency__c)
                                    crsFeeWrap.tutionFeeWrapperList.add(fw);
                            }else if(crFee.Fee__r.Type__c == ConstantClass.depositFeeType){                       
                                if(!slcdFee.contains(crFee.Fee__c))
                                    crsFeeWrap.depositWrapperList.add(fw);
                            }else{
                                if(!slcdFee.contains(crFee.Fee__c))
                                    crsFeeWrap.feeWrapperList.add(fw);
                            }   
                        }
                    }
                    
                    Integer counter = 0;      
                    for(Class__c cls:[SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c, Location__r.Name, 
                                      Teacher__r.Name, Type__c, Frequency__c, Status__c, Capacity__c, Days_of_Week__c, Seats_Available__c,
                                      (SELECT Id, Name, Start_Date__c, End_Date__c, Sessions__c, Status__c FROM  Class_Terms__r
                                       WHERE Status__c =:ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND
                                       Sessions__c > 0 AND  Start_Date__c != null AND End_Date__c != null ORDER BY Sequence__c)
                                      FROM Class__c 
                                      WHERE Course__c =:crId AND  Type__c != null AND Frequency__c != null AND (Status__c =: ConstantClass.clsOpenStatus OR (Allow_Overbooking__c = True AND Status__c =: ConstantClass.clsClosedStatus))]){   
                                          
                                          
                                          ClassWrapper cw = new ClassWrapper();
                                          cw.clsId        = cls.Id;                  
                                          cw.clsName      = cls.Name;
                                          cw.clsDays      = cls.Days_of_Week__c;     
                                          cw.clsType      = cls.Type__c;   
                                          cw.clsFrequency	= cls.Frequency__c;
                                          cw.locationId   = cls.Location__c;
                                          cw.location     = cls.Location__r.Name;
                                          cw.teacherName  = cls.Teacher__r.Name;
                                          cw.seatsAlv     = cls.Seats_Available__c != null ? Integer.valueOf(cls.Seats_Available__c) : 0;
                                          if(cls.Id == clsId)                  
                                              cw.isSelected = true;                
                                          if(cls.Start_Time__c != null)
                                              cw.stEndTime= Datetime.newInstance(System.today(), cls.Start_Time__c).format('hh:mm a');
                                          if(cls.End_Time__c != null)
                                              cw.stEndTime += ' - '+ Datetime.newInstance(System.today(), cls.End_Time__c).format('hh:mm a');    
                                          
                                          
                                          //For Monthly classes        
                                          if(cls.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){        
                                              counter  = counter + 1;     
                                              cw.recNo = counter;               
                                              cwList.add(cw);     
                                          }else{//For fixed Term and fixed classes                 
                                              for(Class_Term__c clsTerm : cls.Class_Terms__r){
                                                  if(clsTerm.End_Date__c >= System.today()){
                                                      TermWrapper tm = new TermWrapper();
                                                      tm.clsTermId = clsTerm.Id;
                                                      tm.clsTermName = clsTerm.Name;
                                                      if(clsTerm.Start_Date__c != null)
                                                          tm.stEndDate    = Datetime.newInstance(clsTerm.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM');  
                                                      if(clsTerm.End_Date__c != null)
                                                          tm.stEndDate    += ' - '+Datetime.newInstance(clsTerm.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM yyyy');
                                                      
                                                      cw.termList.add(tm);
                                                  }
                                              }
                                              if(cw.termList.size() > 0){
                                                  counter = counter + 1; 
                                                  cw.recNo = counter;  
                                                  cwList.add(cw); 
                                              }
                                          }
                                      }
                }
            }
            crsFeeWrap.classWrapperList.addAll(cwList);
        }
        /* CourseFeeWrapper crsFeeWrap = cf;
crsFeeWrap.classWrapperList     = new List<ClassWrapper>();

List<ClassWrapper> cwList = new List<ClassWrapper>();
String clsId = cf.slcdClsWrapObj.clsId;
String clsTermId = cf.slcdClsWrapObj.slctClsTermId;

if(String.isNotBlank(clsId)){
Set<String> slcdFee = new Set<String>();
List<Class__c> clsList = [SELECT Id, Name, Start_Date__c, Course__c FROM Class__c WHERE Id =:clsId];

for(FeeWrapper fw : crsFeeWrap.tutionFeeWrapperList){
slcdFee.add(fw.feeId);
}for(FeeWrapper fw : crsFeeWrap.depositWrapperList)
slcdFee.add(fw.feeId);
for(FeeWrapper fw : crsFeeWrap.feeWrapperList)
slcdFee.add(fw.feeId); 

if(clsList.size() > 0){
String   crId= clsList.get(0).Course__c;

for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Schedule__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c
FROM Course_Fee__c WHERE Course__c =:crId AND Fee__r.Amount__c != null]){

FeeWrapper fw = new FeeWrapper();
fw.feeId      = crFee.Fee__c;                         
fw.feeName    = crFee.Fee__r.Name;
fw.feeType    = crFee.Fee__r.Type__c;
fw.payFrequency = crFee.Fee__r.Frequency__c;  
fw.feeAmount = crFee.Fee__r.Amount__c;
fw.tutionFeeUnitPrice = crFee.Fee__r.Unit_Price__c;

if(crFee.Fee__r.Type__c == ConstantClass.tutionFeeType){
if(!slcdFee.contains(crFee.Fee__c))
crsFeeWrap.tutionFeeWrapperList.add(fw);
}else if(crFee.Fee__r.Type__c == ConstantClass.depositFeeType){
if(!slcdFee.contains(crFee.Fee__c))
crsFeeWrap.depositWrapperList.add(fw);
}else{
if(!slcdFee.contains(crFee.Fee__c))
crsFeeWrap.feeWrapperList.add(fw);
}
}


Integer counter = 0;
for(Class__c cls:[SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c, Location__r.Name, 
Teacher__r.Name, Type__c, Status__c, Capacity__c, Days_of_Week__c,Seats_Available__c,
(SELECT Id, Name, Start_Date__c, End_Date__c, Sessions__c, Status__c FROM  Class_Terms__r
WHERE Status__c =: ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND Sessions__c > 0 ORDER BY Sequence__c)
FROM Class__c 
WHERE Course__c =:crId AND (Status__c =: ConstantClass.clsOpenStatus OR (Allow_Overbooking__c = True AND Status__c =: ConstantClass.clsClosedStatus))]){
if(cls.Class_Terms__r.size() > 0){                         
for(Class_Term__c clsTerm : cls.Class_Terms__r){
if(clsTerm.End_Date__c >= System.today()){
counter = counter + 1;                    
ClassWrapper cw = new ClassWrapper();
cw.recNo        = counter;
cw.clsId        = cls.Id;                  
cw.clsName      = cls.Name;
cw.clsDays      = cls.Days_of_Week__c;     
cw.clsType      = cls.Type__c;               
cw.locationId   = cls.Location__c;
cw.location     = cls.Location__r.Name;
cw.teacherName  = cls.Teacher__r.Name;
cw.slctClsTermId    = clsTerm.Id;
cw.slctclsTermName  = clsTerm.Name;
cw.seatsAlv     = cls.Seats_Available__c != null ? Integer.valueOf(cls.Seats_Available__c) : 0;

if(clsTerm.Start_Date__c != null)
cw.stEndDate    = Datetime.newInstance(clsTerm.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM');  
if(clsTerm.End_Date__c != null)
cw.stEndDate    += ' - '+Datetime.newInstance(clsTerm.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM yyyy');

if(cls.Start_Time__c != null)
cw.stEndTime= Datetime.newInstance(System.today(), cls.Start_Time__c).format('hh:mm a');
if(cls.End_Time__c != null)
cw.stEndTime += ' - '+ Datetime.newInstance(System.today(), cls.End_Time__c).format('hh:mm a');    

if(clsTerm.Id == clsTermId)                  
cw.isSelected = true;

cwList.add(cw); 
}
}
}
}
}
}
crsFeeWrap.classWrapperList.addAll(cwList);
*/
        return crsFeeWrap;
    }
    
    /* @auraEnabled
public static CourseFeeWrapper filterByCheckbox(String crId){
CourseFeeWrapper crsFeeWrap = new CourseFeeWrapper();
List<ClassWrapper> cwList = new List<ClassWrapper>();

for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Override__c,
Fee__r.Schedule__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c
FROM Course_Fee__c WHERE Course__c =: crId AND Fee__r.Amount__c != null]){

FeeWrapper fw = new FeeWrapper();
fw.feeName    = crFee.Fee__r.Name;
fw.feeType    = crFee.Fee__r.Type__c;
fw.payFrequency = crFee.Fee__r.Frequency__c;  
fw.feeAmount = crFee.Fee__r.Amount__c;

if(crFee.Fee__r.Type__c == 'Tuition Fee'){
crsFeeWrap.tutionFeeWrapperList.add(fw);
}else if(crFee.Fee__r.Type__c == 'Deposit'){
fw.isSelected = true;
fw.isOverride = crFee.Fee__r.Override__c;
//  if(!fw.isSelected)
//    fw.isOverride = true;
crsFeeWrap.depositWrapperList.add(fw);
crsFeeWrap.totFee += fw.feeAmount; 
}else{
fw.isSelected = true;
fw.isOverride = crFee.Fee__r.Override__c;
//if(!fw.isSelected)
//   fw.isOverride = true;
crsFeeWrap.feeWrapperList.add(fw);
crsFeeWrap.totFee += fw.feeAmount;
}
}


Integer counter = 0;
for(Class__c cls:[SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c, Location__r.Name, 
Teacher__r.Name, Type__c, Status__c, Capacity__c, Days_of_Week__c
FROM Class__c 
WHERE Course__c =:crId]){
counter = counter + 1;                    
ClassWrapper cw = new ClassWrapper();
cw.recNo        = counter;
cw.clsId        = cls.Id;                  
cw.clsName      = cls.Name;
cw.clsDays      = cls.Days_of_Week__c;                  
cw.locationId   = cls.Location__c;
cw.location     = cls.Location__r.Name;
cw.teacherName  = cls.Teacher__r.Name;
if(cls.Start_Date__c != null)
cw.stEndDate    = Datetime.newInstance(cls.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM');  
if(cls.End_Date__c != null)
cw.stEndDate += ' - '+Datetime.newInstance(cls.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('d MMM yyyy');               
if(cls.Start_Time__c != null)
cw.stEndTime= Datetime.newInstance(System.today(), cls.Start_Time__c).format('hh:mm a');
if(cls.End_Time__c != null)
cw.stEndTime += ' - '+ Datetime.newInstance(System.today(), cls.End_Time__c).format('hh:mm a');    

cwList.add(cw); 
}
crsFeeWrap.classWrapperList.addAll(cwList);

return crsFeeWrap;
}
*/
    
    //This function is used to get Early bird discount, If any avaialble on selected course
    @auraEnabled
    public static List<DisWrapper> checkEarlyBirdDiscount(String clsWrapStr){ 
        ClassWrapper clsWrap = (ClassWrapper) System.JSON.deserialize(clsWrapStr, ClassWrapper.class);
        List<DisWrapper> disWrapList = new List<DisWrapper>();
        if(isCourseFeeAccessible && isClassAccessible && isDiscountAccessible && isCourseDiscAccessible){
            if(String.isNotBlank(clsWrap.clsId)){
                List<Class__c> clsList = [SELECT Id, Name, Start_Date__c, Course__c FROM Class__c WHERE Id =:clsWrap.clsId AND Start_Date__c != null];
                
                if(clsList.size() > 0){
                    Class__c cls = clsList.get(0);
                    
                    Integer diffInDays = System.today().daysBetween(cls.Start_Date__c);
                    for(Course_Discount__c crsDis: [SELECT Id, Name, Discount__c, Discount__r.Name, Discount__r.Days_Before_Class__c, Discount__r.Value__c, Discount__r.Override__c, Discount__r.Required__c,
                                                    Discount__r.Type__c, Discount__r.Format__c, Discount__r.Start_Date__c, Discount__r.End_Date__c 
                                                    FROM Course_Discount__c 
                                                    WHERE Course__c =:cls.Course__c AND Discount__r.Days_Before_Class__c != null AND Discount__r.Format__c != null AND
                                                    Discount__r.Active__c = True AND Discount__r.Value__c != null AND Discount__r.Type__c =:ConstantClass.earlyBirdDiscount]){
                                                        
                                                        if(diffInDays >= crsDis.Discount__r.Days_Before_Class__c){ 
                                                            Decimal amtVal = 0;
                                                            if(crsDis.Discount__r.Format__c.equalsIgnoreCase(ConstantClass.amountFormat)){
                                                                amtVal = crsDis.Discount__r.Value__c;
                                                            }else if(crsDis.Discount__r.Format__c.equalsIgnoreCase(ConstantClass.percentFormat)){
                                                                //  amtVal = crsDis.Discount__r.Value__c;
                                                            }
                                                            
                                                            DisWrapper dw = new DisWrapper();
                                                            dw.disId      = crsDis.Discount__c;
                                                            dw.isSelected = crsDis.Discount__r.Required__c;
                                                            dw.isOverride = crsDis.Discount__r.Override__c;
                                                            dw.name       = crsDis.Discount__r.Name;
                                                            dw.amount     = amtVal;
                                                            dw.type       = crsDis.Discount__r.Type__c;
                                                            disWrapList.add(dw);
                                                        }
                                                    }
                }
            }
        }
        return disWrapList;
    }
    
    //This function is used to fetch other discount which configured globally
    @auraEnabled
    public static List<DisWrapper> fetchOtherDiscount(){ 
        List<DisWrapper> disWrapList = new List<DisWrapper>();
        
        List<DisWrapper> refDisWrapList  = new List<DisWrapper>();
        List<DisWrapper> proDisWrapList  = new List<DisWrapper>();
        List<DisWrapper> othrDisWrapList = new List<DisWrapper>();
        
        if(isDiscountAccessible){
            for(Discount__c dis: [SELECT Id, Name, Value__c, Type__c, Format__c, Code__c, Start_Date__c, End_Date__c 
                                  FROM Discount__c 
                                  WHERE Format__c != null AND Active__c = True AND Value__c != null AND 
                                  Global__c = true AND (Start_Date__c <= Today AND  End_Date__c >= Today)]){
                                      DisWrapper dw = new DisWrapper();
                                      Decimal amtVal = 0;
                                      if(dis.Format__c.equalsIgnoreCase(ConstantClass.amountFormat)){
                                          amtVal = dis.Value__c;
                                      }else if(dis.Format__c.equalsIgnoreCase(ConstantClass.percentFormat)){
                                          //  amtVal = crsDis.Discount__r.Value__c;
                                      }           
                                      dw.disId   = dis.Id;                
                                      dw.name    = dis.Name;
                                      dw.format  = dis.Format__c;
                                      dw.amount  = amtVal;
                                      dw.type    = dis.Type__c;
                                      if(dw.type.equalsIgnoreCase(ConstantClass.referralType)){
                                          refDisWrapList.add(dw);
                                      }else if(dw.type.equalsIgnoreCase(ConstantClass.promoType)){
                                          dw.promoCode = dis.Code__c;
                                          proDisWrapList.add(dw);
                                      }else if(dw.type.equalsIgnoreCase(ConstantClass.discountType)){
                                          othrDisWrapList.add(dw);   
                                      }
                                  }
            
            if(refDisWrapList.size() > 0)
                disWrapList.addAll(refDisWrapList); 
            if(proDisWrapList.size() > 0)
                disWrapList.addAll(proDisWrapList); 
            if(othrDisWrapList.size() > 0)
                disWrapList.addAll(othrDisWrapList); 
        }    
        return disWrapList;
    }
    
    //This function is used to calculate prorated amount on the bases of enrollment date when user click on save button on class model
    @auraEnabled
    public static CourseFeeWrapper calculateProratedAmount(String slcdCrsObjStr){ 
        CourseFeeWrapper slcdCrsObj = (CourseFeeWrapper) System.JSON.deserialize(slcdCrsObjStr, CourseFeeWrapper.class);
        if(isAccountAccessible && isClassAccessible && isFeeAccessible && isSessionAccessible && isClassTermAccessible){
            if(slcdCrsObj != null && slcdCrsObj.enrolDate != null
               && slcdCrsObj.slcdClsWrapObj != null && slcdCrsObj.slcdClsWrapObj.fees > 0){
                   
                   FeeWrapper fwT = new FeeWrapper();
                   System.debug('fee-->>'+ slcdCrsObj.tutionFeeWrapperList);
                   for(FeeWrapper twTemp: slcdCrsObj.tutionFeeWrapperList){
                       if(twTemp.isSelected)
                           fwT = twTemp;
                   }  
                   
                   slcdCrsObj.tutionFeeWrapperList = new List<FeeWrapper>();
                   slcdCrsObj.tutionFeeWrapperList.add(fwT);
                   
                   
                   FeeWrapper fw = slcdCrsObj.tutionFeeWrapperList[0];
                   slcdCrsObj.slcdClsWrapObj.slctClsTermId = '';
                   slcdCrsObj.slcdClsWrapObj.slctclsTermName = '';
                   
                   Date tempDt = slcdCrsObj.enrolDate;   
                   
                   //Fetch selected class
                   List<Class__c> clsList = [SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c, Location__r.Name,  
                                             Teacher__r.Name, Type__c, Frequency__c, Status__c, Capacity__c, Days_of_Week__c, Sessions__c,
                                             (SELECT Id, Name, Sequence__c, Sessions__c, Start_Date__c, End_Date__c FROM Class_Terms__r
                                              WHERE Status__c =:ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND 
                                              Sessions__c > 0 AND Start_Date__c != null AND End_Date__c >: tempDt ORDER BY Sequence__c)
                                             FROM Class__c WHERE Id =:slcdCrsObj.slcdClsWrapObj.clsId AND Days_of_Week__c != null AND Format__c != null];
                   
                   Class_Term__c clsTerm = new Class_Term__c();
                   if(clsList[0].Class_Terms__r.size() > 0){
                       //get specifi class term according to the selected enrolment date
                       for(Class_Term__c clsTermTemp: clsList[0].Class_Terms__r){
                           if(clsTermTemp.Start_Date__c <= tempDt && tempDt < clsTermTemp.End_Date__c){
                               clsTerm = clsTermTemp;
                               slcdCrsObj.slcdClsWrapObj.slctClsTermId   = clsTermTemp.Id;
                               slcdCrsObj.slcdClsWrapObj.slctclsTermName = clsTermTemp.Name;
                               break;
                           }
                       }    
                       //Check if no class term avaialble according to the enrolment date, Then check next term
                       if(clsTerm.Id == null){
                           for(Class_Term__c clsTermTemp: clsList[0].Class_Terms__r){
                               if(clsTermTemp.End_Date__c > tempDt){
                                   clsTerm = clsTermTemp;
                                   slcdCrsObj.slcdClsWrapObj.slctClsTermId   = clsTermTemp.Id;
                                   slcdCrsObj.slcdClsWrapObj.slctclsTermName = clsTermTemp.Name;
                                   break;
                               }
                           } 
                       }    
                   }
                   
                   //Fetch selected tution fee for prorated amount
                   List<Fee__c> feeList   = [SELECT Id, Name, Amount__c, Units__c, Unit_Price__c, Frequency__c, Schedule__c FROM Fee__c 
                                             WHERE Id =:fw.feeId AND Amount__c > 0 AND  Unit_Price__c != null AND Prorate__c = true];  
                   system.debug('feeList-->'+feeList);
                   system.debug('clsList-->'+clsList);
                   if(clsList.size() > 0 && feeList.size() > 0){
                       Class__c cls          = clsList.get(0);                 
                       Fee__c   fee          = feeList.get(0);
                       Integer noOfLessInCurrMonth = 0;
                       system.debug('test');
                       //Calculate prorated number of lesson for month type class on the bases of selected date
                     /*  if(fee.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
                           if(tempDt.month() == System.today().month()){
                               Integer numberOfDays = Date.daysInMonth(tempDt.year(), tempDt.month());
                               Date lastDayOfMonth = Date.newInstance(tempDt.year(), tempDt.month(), numberOfDays);
                               
                               List<Session__c> sessList  = [SELECT Id, Name, Class__c, Sequence__c, Session_Date__c, Teacher__c, Status__c  
                                                             FROM Session__c
                                                             WHERE Class__c =:cls.Id AND Status__c =: ConstantClass.scheduledStatus
                                                             AND Session_Date__c >=:tempDt AND Session_Date__c <=: lastDayOfMonth];  
                               noOfLessInCurrMonth = sessList.size();
                               // if(sessList.size() > 4)
                               //  noOfLessInCurrMonth = 4;
                           }
                       }else{//Calculate prorated number of lesson for Term/Fixed type class on the bases of selected date
                           
                           List<Class_Term__c> clsTermList = [SELECT Id, Name, Sequence__c, Sessions__c, Start_Date__c, End_Date__c 
                                                              FROM Class_Term__c
                                                              WHERE Class__c=: cls.Id AND Status__c =:ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND 
                                                              Sessions__c > 0 AND Start_Date__c != null AND End_Date__c >: tempDt ORDER BY Sequence__c];
                           Class_Term__c clsTerm = new Class_Term__c();
                           if(clsTermList.size() > 0){
                               //get specifi class term according to the selected enrolment date
                               for(Class_Term__c clsTermTemp: clsTermList){
                                   if(clsTermTemp.Start_Date__c <= tempDt && tempDt < clsTermTemp.End_Date__c){
                                       clsTerm = clsTermTemp;
                                       slcdCrsObj.slcdClsWrapObj.slctClsTermId   = clsTermTemp.Id;
                                       slcdCrsObj.slcdClsWrapObj.slctclsTermName = clsTermTemp.Name;
                                       break;
                                   }
                               }    
                               //Check if no class term avaialble according to the enrolment date, Then check next term
                               if(clsTerm.Id == null){
                                   for(Class_Term__c clsTermTemp: clsTermList){
                                       if(clsTermTemp.End_Date__c > tempDt){
                                           clsTerm = clsTermTemp;
                                           slcdCrsObj.slcdClsWrapObj.slctClsTermId   = clsTermTemp.Id;
                                           slcdCrsObj.slcdClsWrapObj.slctclsTermName = clsTermTemp.Name;
                                           break;
                                       }
                                   } 
                               }    
                           }       */ 
                           //Fetch number of remaining session on the bases of term selected
                           if(clsTerm.Id != null){
                               List<Session__c> sessList  = [SELECT Id, Name, Class__c, Sequence__c, Session_Date__c, Teacher__c, Status__c  
                                                             FROM Session__c
                                                             WHERE Class_Term__c =:clsTerm.Id AND Status__c =: ConstantClass.scheduledStatus
                                                             AND Session_Date__c >=: tempDt];  
                               noOfLessInCurrMonth = sessList.size();
                               System.debug('@@--->'+clsTerm.Id );
                               System.debug('@@--->'+sessList.size());
                           }
                       //}
                       System.debug('@@--->'+noOfLessInCurrMonth);
                       Decimal packFee = fee.Unit_Price__c * noOfLessInCurrMonth;
                       /*if(String.isNotBlank(fee.Schedule__c) && fee.Schedule__c.equalsIgnoreCase(ConstantClass.fixedType)){
packFee = fee.Amount__c;
}*/
                       fw.feeProratedAmount = packFee;
                   }                           
                   slcdCrsObj.tutionFeeWrapperList[0] = fw; 
                   /*  List<Class__c> clsList = [SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Location__c, Location__r.Name,  
Teacher__r.Name, Type__c, Status__c, Capacity__c, Days_of_Week__c, Sessions__c, 
(SELECT Id, Name, Sequence__c, Sessions__c, Term__r.Start_Date__c, Term__r.End_Date__c FROM Class_Terms__r
WHERE Status__c =:ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND 
Sessions__c > 0 AND Term__r.Start_Date__c != null AND Term__r.End_Date__c >: tempDt ORDER BY Sequence__c)
FROM Class__c 
WHERE Id =:slcdCrsObj.slcdClsWrapObj.clsId AND Days_of_Week__c != null AND Format__c != null];

List<Fee__c> feeList   = [SELECT Id, Name, Amount__c, Units__c, Unit_Price__c, Frequency__c FROM Fee__c 
WHERE Id =:fw.feeId AND Amount__c > 0 AND  Unit_Price__c != null]; 


if(clsList.size() > 0 && feeList.size() > 0){
Class__c cls          = clsList.get(0);                  
Fee__c   fee          = feeList.get(0);
Class_Term__c clsTerm = new Class_Term__c();
if(cls.Class_Terms__r.size() > 0){
//get specifi class term according to the selected enrolment date
for(Class_Term__c clsTermTemp: cls.Class_Terms__r){
if(clsTermTemp.Term__r.Start_Date__c <= tempDt && tempDt < clsTermTemp.Term__r.End_Date__c){
clsTerm = clsTermTemp;
slcdCrsObj.slcdClsWrapObj.slctClsTermId   = clsTermTemp.Id;
slcdCrsObj.slcdClsWrapObj.slctclsTermName = clsTermTemp.Name;
break;
}
}    
//Check if no class term avaialble according to the enrolment date, Then check next term
if(clsTerm.Id == null){
for(Integer i=0; i< cls.Class_Terms__r.size(); i++){
if(cls.Class_Terms__r.get(i).Term__r.End_Date__c > tempDt){
clsTerm = cls.Class_Terms__r.get(i);
slcdCrsObj.slcdClsWrapObj.slctClsTermId   = cls.Class_Terms__r.get(i).Id;
slcdCrsObj.slcdClsWrapObj.slctclsTermName = cls.Class_Terms__r.get(i).Name;
break;
}
} 
}    
}

Integer noOfLessInCurrMonth = 0;

if(fee.Frequency__c.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
tempDt = System.today();
while(slcdCrsObj.enrolDate.month() == tempDt.month()){
String slcdDay = Datetime.newInstance(tempDt, Time.newInstance(0, 0, 0, 0)).format('E');
if(cls.Days_of_Week__c.contains(slcdDay))
noOfLessInCurrMonth = noOfLessInCurrMonth+1;
tempDt = tempDt.addDays(1);
}
}else{
Date clsTermStDate  = Null;
Date clsTermEndDate = Null;
Integer noOfSess    = Integer.valueOf(cls.Sessions__c);
if(clsTerm != null){
clsTermStDate = clsTerm.Term__r.Start_Date__c;
clsTermEndDate= clsTerm.Term__r.End_Date__c;
noOfSess      = Integer.valueOf(clsTerm.Sessions__c);
}                    
while(noOfLessInCurrMonth < noOfSess){
if(clsTermEndDate != null && tempDt > clsTermEndDate)  
break;  

String slcdDay = Datetime.newInstance(tempDt, Time.newInstance(0, 0, 0, 0)).format('E');
if(cls.Days_of_Week__c.contains(slcdDay))
noOfLessInCurrMonth = noOfLessInCurrMonth+1;
tempDt = tempDt.addDays(1);
}
}
Decimal packFee = fee.Unit_Price__c * noOfLessInCurrMonth;
fw.feeProratedAmount = packFee; 
}
slcdCrsObj.tutionFeeWrapperList[0] = fw; */
               }
        }         
        return slcdCrsObj;
    }
    
    @auraEnabled
    public static List<FeeWrapper> getRelatedFeeApex(String feeId){
        List<FeeWrapper> listFeeWrapper = new List<FeeWrapper>();
        if(String.isNotBlank(feeId)){
            List<Fee__c> listRelatedFee = [SELECT Id, Name, Type__c, Frequency__c, Amount__c, Schedule__c, Units__c, Unit_Price__c,Parent__c,
                                           Override__c,Required__c,GST_Applicable__c
                                           FROM Fee__c WHERE Parent__c =: feeId  AND RecordType.Name = 'Secondary'];
            if(listRelatedFee != NULL && listRelatedFee.size() > 0){
                for(Fee__c rFee : listRelatedFee){
                    FeeWrapper fw = new FeeWrapper();
                    fw.feeId      = rFee.Id;
                    fw.feeName    = rFee.Name;
                    fw.feeType    = rFee.Type__c;
                    fw.payFrequency = rFee.Frequency__c;  
                    fw.feeAmount   = rFee.Amount__c;
                    fw.feeSchType  = rFee.Schedule__c;  
                    fw.noOfUnit    = rFee.Units__c != null ? Integer.valueOf(rFee.Units__c):0;
                    fw.feeParent   = rFee.Parent__c;
                    fw.isSelected  = rFee.Required__c;
                    fw.isOverride  = rFee.Override__c;
                    fw.isGSTApplicable = rFee.GST_Applicable__c;
                    listFeeWrapper.add(fw);
                }
            }
        }
        system.debug('listFeeWrapper-->'+listFeeWrapper);
        return listFeeWrapper;
    }
    //This function is used to get dynmically picklist values of the object
    @auraEnabled
    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name){ 
        return UtilityClass.getPickValues(ObjectApi_name, Field_name);
        //List<String> lstPickvals = new List<String>();        
        
        /* Map<String, String> pickLstMap = UtilityClass.getPickValues(ObjectApi_name, Field_name);
for(String str: pickLstMap.keySet()){
if(Field_name.equalsIgnoreCase('BillingCountry')){
lstPickvals.add(str);
}else{
lstPickvals.add(pickLstMap.get(str));
}
}
return lstPickvals;*/
    }
    
    //This function is used to save and complete the whole enrolment process.
    @auraEnabled
    public static String completeEnrolment(String parAccStr, String slctdEnrolmentsStr, String globalDisListStr, Decimal totPayAmt, String refNo, String payMode){
        Account parAcc = (Account) System.JSON.deserialize(parAccStr, Account.class);
        List<CustomerWrapper> slctdEnrolments = String.isNotBlank(slctdEnrolmentsStr) ? (List<CustomerWrapper>) JSON.deserialize(slctdEnrolmentsStr,List<CustomerWrapper>.class) : new List<CustomerWrapper>(); 
        List<DisWrapper> globalDisList = String.isNotBlank(globalDisListStr) ? (List<DisWrapper>) JSON.deserialize(globalDisListStr,List<DisWrapper>.class) : new List<DisWrapper>();
        
        String strMsg = 'Success';
        Savepoint sp;
        try{  
            // Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',  
            //new Set<String>{'Id', 'Name', 'Sequence__c','Start_Date__c','End_Date__c','Teacher__c','Advance_Billing_Unit__c','Advance_Billing__c'},false);
            //  Boolean isClassTermAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',  
            //new Set<String>{'Id', 'Name', 'Sequence__c','Start_Date__c','End_Date__c','Teacher__c'},false);
            //   Boolean isSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Session__c',  
            // new Set<String>{'Id', 'Class__c', 'Class_Term__c', 'Sequence__c','Session_Date__c','Teacher__c','Status__c'},false);
            
            Boolean isAccountCreatableAccessible = FieldPremissionCrudUtility.checkReadPermission('Account',  
                                                                                                  new Set<String>{'RecordTypeId', 'FirstName', 'LastName', 'PersonEmail','Phone','Block__c','Unit__c',
                                                                                                      'BillingStreet','BillingPostalCode', 'BillingCountry', 'Gender__c', 'PersonBirthdate','Relationship_with_contact__c'},true,false);
            Boolean isSubscriptionAccessible = FieldPremissionCrudUtility.checkReadPermission('Subscription__c',  
                                                                                              new Set<String>{'Location__c', 'Status__c', 'Payment_Frequency__c','Customer__c','Subscription_Start_Date__c'},true,false);
            Boolean isSubLnItmAccessible = FieldPremissionCrudUtility.checkReadPermission('Subscription_Line_Item__c',  
                                                                                          new Set<String>{'Enrollment__c', 'Fee__c','Status__c','Subscription_Start_Date__c','Next_Bill_Date__c'},true,false);
            Boolean isInvoiceAccessible = FieldPremissionCrudUtility.checkReadPermission('Invoice__c',  
                                                                                         new Set<String>{'Customer__c', 'Location__c', 'Subscription__c','Status__c','Invoice_Type__c','Invoice_Date__c'},true,false);
            Boolean isEnrollmentAccessible = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c',  
                                                                                            new Set<String>{'Location__c', 'Start_Date__c','Parent__c','Student__c','Status__c','Enrollment_Date__c',
                                                                                                'Parent_Email__c','Comments__c','Terms_and_Conditions__c','Referred_By__c'},true,false);
            Boolean isStudentSessionAccessible = FieldPremissionCrudUtility.checkReadPermission('Student_Session__c',  
                                                                                                new Set<String>{'Account__c', 'Session__c', 'Enrollment__c','Status__c','Billable__c'},true,false);
            Boolean isInvLnItmAccessible = FieldPremissionCrudUtility.checkReadPermission('Invoice_Line_Item__c',  
                                                                                          new Set<String>{'Enrollment__c', 'Subscription_Line_Item__c','Fee__c','Discount__c','Type__c','Amount__c'},true,false);
            Boolean isPaymentAccessible = FieldPremissionCrudUtility.checkReadPermission('Payment__c',  
                                                                                         new Set<String>{'Parent__c', 'Amount__c','Status__c','Payment_Date__c','Transaction_Id__c','Cash_Mode__c'},true,false);
            //   Boolean isCreditNoteAccessible = FieldPremissionCrudUtility.checkReadPermission('Credit_Note__c',  
            //   new Set<String>{'Amount__c', 'Customer__c', 'Date_Issued__c','Status__c'},true);
            
            
            if(isAccountCreatableAccessible && isSubscriptionAccessible && isSubLnItmAccessible && isInvoiceAccessible && isEnrollmentAccessible && isStudentSessionAccessible && isStudentSessionAccessible && isInvLnItmAccessible && isPaymentAccessible){
                sp = Database.setSavepoint();
                
                /* Map<String,String> billCntryMap = UtilityClass.getPickValues('Account', 'BillingCountry');
if(String.isNotBlank(parAcc.BillingCountry) && billCntryMap.containsKey(parAcc.BillingCountry)){
parAcc.BillingCountry = billCntryMap.get(parAcc.BillingCountry);
}*/
                Account cstmrAlreadyAvl = new Account();
                
                String recTypeId = ConstantClass.customerRecTypeId;//Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantClass.customerRecType).getRecordTypeId(); 
                parAcc.RecordTypeId = recTypeId;
                if(String.isBlank(parAcc.Id)){
                    List<Account> accList = [SELECT Id, Name, (SELECT Id, FirstName, LastName, PersonBirthDate FROM Students__r) 
                                             FROM Account WHERE PersonEmail =: parAcc.PersonEmail LIMIT 1];
                    if(accList.size() > 0){
                        cstmrAlreadyAvl = accList.get(0);
                        parAcc.Id = cstmrAlreadyAvl.Id;
                    }
                }
                upsert parAcc;
                
                Map<String, Subscription__c> subsMap = new Map<String, Subscription__c>();
                for(Subscription__c sub: [SELECT Id, Location__c, Status__c, Payment_Frequency__c 
                                          FROM Subscription__c 
                                          WHERE Customer__c =: parAcc.Id AND Status__c =:ConstantClass.activeStatus  AND Payment_Frequency__c != null]){
                                              String paFre = sub.Payment_Frequency__c;
                                              subsMap.put(paFre, sub);
                                          }
                
                //Fill invoice
                Invoice__c inv = UtilityClass.fillInvoice(parAcc.Id, null, null, ConstantClass.newEnrollmentInvType, ConstantClass.paidStatus);
                insert inv;
                
                
                //Map<String, Class_Term__c> clsSessonMap = new Map<String, Class_Term__c>();
                Map<String, List<Session__c>> clsSessonMap  = new Map<String, List<Session__c>>();
                Map<String, Class_Term__c> slcdClsTermMap   = new Map<String, Class_Term__c>();
                for(CustomerWrapper cw: slctdEnrolments){
                    for(CourseFeeWrapper crsWrap : cw.slctdClsDetails){
                        ClassWrapper slcdClsWrap = crsWrap.slcdClsWrapObj;
                        system.debug('slcdClsWrap.slctClsTermId-->'+slcdClsWrap.slctClsTermId);
                        system.debug('slcdClsWrap.clsId-->'+slcdClsWrap.clsId);
                        clsSessonMap.put(slcdClsWrap.slctClsTermId, null);
                        clsSessonMap.put(slcdClsWrap.clsId, null);
                        
                        if(String.isNotBlank(slcdClsWrap.slctClsTermId))
                            slcdClsTermMap.put(slcdClsWrap.clsId, null);
                        
                        //   System.debug('@@@@slcdClsWrap.slctClsTermId  '+slcdClsWrap.slctClsTermId);
                    }
                }
                
                if(clsSessonMap.size() > 0){
                    /*clsSessonMap = new Map<String, Class_Term__c>([SELECT Id, Name, End_Date__c, (SELECT Id, Name, Class__c, Sequence__c, Session_Date__c, Teacher__c, Status__c  
FROM Sessions__r WHERE Session_Date__c >= TODAY ORDER BY Sequence__c) 
FROM   Class_Term__c    
WHERE Id IN: clsSessonMap.keySet()]);*/
                    for(Session__c sess: [SELECT Id, Name, Class__c, Class_Term__c, Sequence__c, Session_Date__c, Teacher__c, Status__c, 
                                          Class_Term__r.Sequence__c, Class_Term__r.Start_Date__c, Class_Term__r.End_Date__c 
                                          FROM Session__c 
                                          WHERE (Class__c IN:clsSessonMap.keySet() OR Class_Term__c IN:clsSessonMap.keySet()) 
                                          AND Class__c != null AND Session_Date__c >= TODAY ORDER BY Sequence__c]){
                                              //For term or fixed based sessions                        
                                              if(sess.Class_Term__c != null){
                                                  // System.debug('@@@@slcdClsTermMap   '+clsSessonMap.containsKey(sess.Class_Term__c));
                                                  if(clsSessonMap.containsKey(sess.Class_Term__c)){
                                                      List<Session__c> sessList = clsSessonMap.get(sess.Class_Term__c);
                                                      sessList = sessList != null ? sessList : new List<Session__c>();
                                                      sessList.add(sess);
                                                      clsSessonMap.put(sess.Class_Term__c, sessList);
                                                      
                                                      if(slcdClsTermMap.get(sess.Class__c) == null){
                                                          slcdClsTermMap.put(sess.Class__c, new Class_Term__c(Id = sess.Class_Term__c, 
                                                                                                              Sequence__c = sess.Class_Term__r.Sequence__c, 
                                                                                                              Start_Date__c = sess.Class_Term__r.Start_Date__c, 
                                                                                                              End_Date__c = sess.Class_Term__r.End_Date__c));
                                                      }
                                                  }
                                              }else{//For monthly sessions
                                                  List<Session__c> sessList = clsSessonMap.get(sess.Class__c);
                                                  sessList = sessList != null ? sessList : new List<Session__c>();
                                                  sessList.add(sess);
                                                  
                                                  clsSessonMap.put(sess.Class__c, sessList);
                                              }
                                          }                                                  
                }
                
                System.debug('@@@@clsSessonMap   '+clsSessonMap);
                //find next class term
                Map<String, Class_Term__c> nextClassTermMap = new Map<String, Class_Term__c>();
                if(slcdClsTermMap.size() > 0){
                    for(Class__c cls: [SELECT Id, Name, (SELECT Id, Name, Sequence__c, Start_Date__c, End_Date__c, Class__r.Advance_Billing_Unit__c, Class__r.Advance_Billing__c 
                                                         FROM Class_Terms__r 
                                                         WHERE Start_Date__c > TODAY AND Sequence__c != null ORDER BY Start_Date__c) 
                                       FROM Class__c WHERE Id IN: slcdClsTermMap.keySet()]){
                                           //System.debug('@@@@'+cls.Class_Terms__r);
                                           // System.debug('@@@@slcdClsTermMap   '+slcdClsTermMap);
                                           //  System.debug('@@@@slcdClsTermMap.get(cls.Id)   '+  slcdClsTermMap.get(cls.Id) );
                                           if(slcdClsTermMap.get(cls.Id) != null){
                                               Class_Term__c slcdClsTerm = slcdClsTermMap.get(cls.Id);
                                               //      System.debug('@@@@slcdClsTerm.Start_Date__c   '+  slcdClsTerm.Start_Date__c);
                                               for(Class_Term__c clsTerm : cls.Class_Terms__r){
                                                   //     System.debug('@@@@clsTerm.Start_Date__c   '+  clsTerm.Start_Date__c);
                                                   if(clsTerm.Start_Date__c > slcdClsTerm.Start_Date__c){
                                                       nextClassTermMap.put(cls.Id, clsTerm);
                                                       break;
                                                   }       
                                               }
                                           }
                                       }
                }
                
                List<Account>                   stuList   = new List<Account>();
                List<Enrollment__c>             enrList   = new List<Enrollment__c>();
                List<Class__c> listClass = new List<Class__c>();
                //  List<Subscription__c>           insSubList= new List<Subscription__c>();
                List<Subscription_Line_Item__c> subLnList = new List<Subscription_Line_Item__c>();
                List<Student_Session__c> stuSessList = new List<Student_Session__c>();
                List<Invoice_Line_Item__c> invLnItms = new List<Invoice_Line_Item__c>();
                for(CustomerWrapper cw: slctdEnrolments){
                    Account stuDet = cw.studentDetails;
                    stuDet.RecordTypeId = recTypeId;
                    if(String.isNotBlank(stuDet.Relationship_with_contact__c) && stuDet.Relationship_with_contact__c.equalsIgnoreCase('Self')){
                        stuDet.Id = parAcc.Id;              
                    }else{
                        stuDet.Parent__c = parAcc.Id;
                    }
                    
                    if(String.isBlank(stuDet.Id)){
                        String tempName = stuDet.FirstName+' '+stuDet.LastName+' '+stuDet.PersonBirthDate;
                        for(Account exisStu: cstmrAlreadyAvl.Students__r){
                            String existingStu = exisStu.FirstName+' '+exisStu.LastName+' '+exisStu.PersonBirthDate;
                            if(tempName.equalsIgnoreCase(existingStu)){
                                stuDet.Id = exisStu.Id;
                                break;
                            }
                        }
                    }
                    
                    //   if(String.isNotBlank(stuDet.BillingCountryCode) && billCntryMap.containsKey(stuDet.BillingCountryCode))
                    // stuDet.BillingCountryCode = billCntryMap.get(stuDet.BillingCountryCode);
                    
                    stuList.add(stuDet);
                    for(CourseFeeWrapper crsWrap : cw.slctdClsDetails){
                        ClassWrapper slcdClsWrap = crsWrap.slcdClsWrapObj;
                        
                        FeeWrapper slcdTutionFee = new FeeWrapper();
                        if(crsWrap.tutionFeeWrapperList.size() > 0)
                            slcdTutionFee = crsWrap.tutionFeeWrapperList.get(0);
                        
                        Enrollment__c enr  = UtilityClass.fillEnrollment(parAcc.Id, slcdClsWrap.locationId, slcdClsWrap.clsId, crsWrap.enrolDate, ConstantClass.enrolledStatus);
                        enr.Parent_Email__c= parAcc.PersonEmail;
                        enr.Student__r     = stuDet;
                        enr.Comments__c    = crsWrap.comments;
                        enr.Terms_and_Conditions__c = true;
                        enr.Type__c = slcdTutionFee.feeSchType;
                        system.debug('crsWrap.enrolEndDate-->'+crsWrap.enrolEndDate);
                        enr.Enrollment_End_Date__c = (crsWrap.enrolEndDate != NULL ? crsWrap.enrolEndDate : null);
                        enrList.add(enr);
                        
                        
                        
                        //System.debug('@@@@nextSchDt  '+slcdClsWrap.clsType);
                        //Insert subscription line items
                        if(slcdClsWrap.clsType.equalsIgnoreCase(ConstantClass.ongoingClsType) && crsWrap.tutionFeeWrapperList.size() > 0 && !(slcdTutionFee.payFrequency.equalsIgnoreCase(ConstantClass.oneTimeFrequency))){
                            //FeeWrapper slcdTutionFee = crsWrap.tutionFeeWrapperList.get(0);
                            Subscription__c subs = new Subscription__c();
                            
                            Date subsNextBillingDate; 
                            //Next bill date on the bases of selected frequency
                            system.debug('clsSessonMap.get(slcdClsWrap.slctClsTermId)..==>'+clsSessonMap.get(slcdClsWrap.slctClsTermId));
                            if(clsSessonMap.get(slcdClsWrap.slctClsTermId) != null /*&& slcdTutionFee.payFrequency.equalsIgnoreCase(ConstantClass.termFrequency)*/){
                                //subsNextBillingDate = clsSessonMap.get(slcdClsWrap.slctClsTermId).get(0).Class_Term__r.End_Date__c;
                                
                                //Added on 27th May 2020
                                Boolean isNeedToCheckStuSess = False;
                                Integer noOfSess = 0;
                                if(String.isNotBlank(slcdTutionFee.feeSchType) && slcdTutionFee.feeSchType.equalsIgnoreCase(ConstantClass.fixedType))
                                    isNeedToCheckStuSess = true;
                                
                                //Filling student session records for term frequency
                                for(Session__c sess : clsSessonMap.get(slcdClsWrap.slctClsTermId)){
                                    if(sess.Session_Date__c >= crsWrap.enrolDate){
                                        Student_Session__c stuSess = new Student_Session__c();
                                        stuSess.Account__r   = stuDet;
                                        stuSess.Session__c   = sess.Id;
                                        stuSess.Enrollment__r= enr;
                                        stuSess.Status__c= ConstantClass.ScheduledStatus;
                                        stuSess.Billable__c= True;
                                        stuSessList.add(stuSess); 
                                        system.debug('stuSessList-->'+stuSessList);
                                        noOfSess = noOfSess+1;
                                        if(isNeedToCheckStuSess && slcdTutionFee.noOfUnit < noOfSess)
                                            break;
                                    }
                                }
                            }
                            /*else if(slcdTutionFee.payFrequency.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
                                Date tempDt = crsWrap.enrolDate;
                                if(tempDt.month() == System.today().month())
                                    tempDt = tempDt.addMonths(1);
                                subsNextBillingDate = Date.newInstance(tempDt.year(), tempDt.month(), 1);
                                
                                //Added on 27th May 2020
                                Boolean isNeedToCheckStuSess = False;
                                Integer noOfSess = 0;
                                if(String.isNotBlank(slcdTutionFee.feeSchType) && slcdTutionFee.feeSchType.equalsIgnoreCase(ConstantClass.fixedType))
                                    isNeedToCheckStuSess = true;
                                system.debug(' clsSessonMap-->'+ clsSessonMap);
                                for(Session__c sess : clsSessonMap.get(slcdClsWrap.clsId)){
                                    if(sess.Session_Date__c >= crsWrap.enrolDate){
                                        Student_Session__c stuSess = new Student_Session__c();
                                        stuSess.Account__r   = stuDet;
                                        stuSess.Session__c   = sess.Id;
                                        stuSess.Enrollment__r= enr;
                                        stuSess.Status__c= ConstantClass.ScheduledStatus;
                                        stuSess.Billable__c= True;
                                        stuSessList.add(stuSess);  
                                        
                                        noOfSess = noOfSess+1;
                                        if(isNeedToCheckStuSess && slcdTutionFee.noOfUnit <= noOfSess)
                                            break;
                                    }
                                }
                            }*/
                            
                            if(subsMap.containsKey(slcdTutionFee.payFrequency)){
                                subs = subsMap.get(slcdTutionFee.payFrequency);
                            }else{
                                subs.Location__c = slcdClsWrap.locationId;
                                subs.Customer__c = parAcc.Id;
                                subs.Status__c   = ConstantClass.activeStatus;
                                subs.Payment_Frequency__c = slcdTutionFee.payFrequency;
                                subs.Subscription_Start_Date__c = crsWrap.enrolDate;
                                
                                // subs.Next_Bill_Date__c = subsNextBillingDate;
                                subsMap.put(subs.Payment_Frequency__c, subs);
                            }
                            /*    if(slcdTutionFee.payFrequency.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
if(subsList.size() > 0){
subs = subsList.get(0);
}else{
subs.Location__c = slcdClsWrap.locationId;
subs.Customer__c = parAcc.Id;
subs.Status__c   = ConstantClass.activeStatus;
subs.Payment_Frequency__c = ConstantClass.monthlyFrequency;
subs.Subscription_Start_Date__c = crsWrap.enrolDate;

subs.Next_Bill_Date__c = subsNextBillingDate;
subsList.add(subs);    
} 
}else{
subs.Location__c = slcdClsWrap.locationId;
subs.Customer__c = parAcc.Id;
subs.Status__c   = ConstantClass.activeStatus;
subs.Payment_Frequency__c = ConstantClass.termFrequency;
subs.Subscription_Start_Date__c = crsWrap.enrolDate;
// if(clsSessonMap.get(slcdClsWrap.clsTermId) != null)
//    subs.Next_Bill_Date__c = clsSessonMap.get(slcdClsWrap.clsTermId).End_Date__c;
subs.Next_Bill_Date__c = subsNextBillingDate;
subsList.add(subs);    
}*/
                            
                            Subscription_Line_Item__c subsLnItem = new Subscription_Line_Item__c();
                            subsLnItem.Subscription__r  = subs;
                            subsLnItem.Enrollment__r    = enr;
                            subsLnItem.Fee__c           = slcdTutionFee.feeId;
                            subsLnItem.Status__c        = ConstantClass.activeStatus;
                            subsLnItem.Subscription_Start_Date__c = crsWrap.enrolDate;
                            if(slcdTutionFee.payFrequency.equalsIgnoreCase(ConstantClass.termFrequency)){
                                //System.debug('@@@@nextClassTermMap  '+nextClassTermMap);
                                // System.debug('@@@@slcdClsWrap.clsId   '+slcdClsWrap.clsId);
                                if(nextClassTermMap.get(slcdClsWrap.clsId) != null){
                                    Class_Term__c nextClsTerm = nextClassTermMap.get(slcdClsWrap.clsId);
                                    
                                    String schUnit  = nextClsTerm.Class__r.Advance_Billing_Unit__c;
                                    Date nextSchDt  = nextClsTerm.Start_Date__c;
                                    
                                    // System.debug('@@@@nextSchDt  '+nextSchDt);
                                    
                                    if(String.isNotBlank(schUnit) && nextClsTerm.Class__r.Advance_Billing__c != null){
                                        Integer advSchVal = Integer.valueOf(nextClsTerm.Class__r.Advance_Billing__c);
                                        
                                        if(schUnit.equalsIgnoreCase('Day(s)'))
                                            nextSchDt = nextSchDt.addDays(-advSchVal);
                                        else if(schUnit.equalsIgnoreCase('Week(s)'))
                                            nextSchDt = nextSchDt.addDays(-(7*advSchVal));
                                        else if(schUnit.equalsIgnoreCase('Month(s)'))
                                            nextSchDt = nextSchDt.addMonths(-advSchVal);
                                    }
                                    
                                    subsLnItem.Class_Term__c     = nextClsTerm.Id;
                                    subsLnItem.Next_Bill_Date__c = nextSchDt;
                                }
                            }else{
                                subsLnItem.Next_Bill_Date__c = subsNextBillingDate;
                            }
                            subLnList.add(subsLnItem);    
                        }else if(slcdClsWrap.clsType.equalsIgnoreCase(ConstantClass.fixedType) || slcdTutionFee.payFrequency.equalsIgnoreCase(ConstantClass.oneTimeFrequency)){
                            //Filling student session records for fixed course
                            system.debug('slcdClsWrap.slctClsTermId==>'+slcdClsWrap.slctClsTermId);
                            system.debug('clsSessonMap-->'+clsSessonMap);
                            if(clsSessonMap.get(slcdClsWrap.slctClsTermId) != null){
                                for(Session__c sess : clsSessonMap.get(slcdClsWrap.slctClsTermId)){
                                    if(sess.Session_Date__c >= crsWrap.enrolDate){
                                        Student_Session__c stuSess = new Student_Session__c();
                                        stuSess.Account__r   = stuDet;
                                        stuSess.Session__c   = sess.Id;
                                        stuSess.Enrollment__r= enr;
                                        stuSess.Status__c= ConstantClass.ScheduledStatus;
                                        stuSess.Billable__c= True;
                                        stuSessList.add(stuSess);   
                                    }
                                }
                            }
                        }
                        
                        
                        //Inserting student session records
                        /*   if(clsSessonMap.get(slcdClsWrap.slctClsTermId) != null){
for(Session__c sess : clsSessonMap.get(slcdClsWrap.slctClsTermId).Sessions__r){
Student_Session__c stuSess = new Student_Session__c();
stuSess.Account__r   = stuDet;
stuSess.Session__c   = sess.Id;
stuSess.Enrollment__r= enr;
stuSess.Status__c= ConstantClass.ScheduledStatus;
stuSessList.add(stuSess);   
}
}*/
                        
                        //Class End date updation with Last Session's Date 
                        if(slcdClsWrap.clsType.equalsIgnoreCase(ConstantClass.fixedType)){
                            if(String.isNotBlank(slcdClsWrap.slctClsTermId)){
                                if(clsSessonMap.get(slcdClsWrap.slctClsTermId) != null){
                                    List<Session__c> sessList = clsSessonMap.get(slcdClsWrap.slctClsTermId);
                                    Class__c cls = new Class__c();
                                    cls.Id = slcdClsWrap.clsId;
                                    cls.End_Date__c = sessList[sessList.size() - 1].Session_Date__c; 
                                    listClass.add(cls);
                                }  
                            }
                        }                         
                        
                        
                        //Invoice line items for tution fee
                        for(FeeWrapper fw: crsWrap.tutionFeeWrapperList){
                            Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, fw.feeId, null, ConstantClass.feeType,
                                                                                         (fw.feeProratedAmount > 0 ? fw.feeProratedAmount : fw.feeAmount) ,
                                                                                         fw.isGSTApplicable);
                            invLnItm.Enrollment__r = enr;
                            invLnItms.add(invLnItm);
                        }
                        
                        //Invoice line items for Other fee
                        for(FeeWrapper fw: crsWrap.feeWrapperList){
                            Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, fw.feeId, null, ConstantClass.feeType, fw.feeAmount, fw.isGSTApplicable);
                            invLnItm.Enrollment__r = enr;
                            invLnItms.add(invLnItm);
                        }
                        
                        //Invoice line items for Deposit fee
                        for(FeeWrapper fw: crsWrap.depositWrapperList){
                            Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, fw.feeId, null, ConstantClass.depositFeeType, fw.feeAmount, fw.isGSTApplicable);
                            invLnItm.Enrollment__r = enr;
                            invLnItms.add(invLnItm);
                        }
                        
                        //Invoice line items for other course discount Amount
                        for(DisWrapper dis: crsWrap.disWrapperList){
                            Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, null, dis.disId, ConstantClass.discountType, dis.amount, true);
                            invLnItm.Enrollment__r = enr;
                            invLnItms.add(invLnItm);
                        }
                        
                        //Invoice line items for earlybird Discount Amount
                        for(DisWrapper dis: crsWrap.earlybirdDisWrapperList){
                            Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, null, dis.disId, ConstantClass.discountType, dis.amount, true);
                            invLnItm.Enrollment__r = enr;
                            invLnItms.add(invLnItm);
                        }
                    }
                }
                
                //Invoice line items for global Discount Amount
                DisWrapper referralDis;
                for(DisWrapper dis: globalDisList){
                    Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, null, dis.disId, ConstantClass.discountType, dis.amount, true);
                    invLnItms.add(invLnItm);
                    
                    if(String.isNotBlank(dis.type) && dis.type.equalsIgnoreCase(ConstantClass.referralType)){
                        referralDis = dis;
                    }
                }
                
                //update class
                if(listClass.size() > 0)
                    update listClass;
                
                //Upserting Students
                if(stuList.size() > 0)
                    upsert stuList;
                
                //Inserting enrollments
                if(enrList.size() > 0){
                    for(Enrollment__c enr: enrList){
                        enr.Student__c = enr.Student__r.Id;
                        if(referralDis != null)
                            enr.Referred_By__c = referralDis.referralById;
                    }
                    insert enrList;
                }
                
                if(subsMap.values().size() > 0){
                    //Upserting Subscription
                    upsert subsMap.values();
                    
                    //Inserting Subscription Line Items
                    if(subLnList.size() > 0){
                        for(Subscription_Line_Item__c subLnItm : subLnList){
                            subLnItm.Subscription__c  = subLnItm.Subscription__r.Id;
                            subLnItm.Enrollment__c    = subLnItm.Enrollment__r.Id;
                        }
                        insert subLnList;
                    }
                }
                
                //Inserting student session bases of the session term
                if(stuSessList.size() > 0){
                    for(Student_Session__c stuSess: stuSessList){
                        stuSess.Account__c   = stuSess.Account__r.Id;
                        stuSess.Enrollment__c= stuSess.Enrollment__r.Id;
                    }
                    insert stuSessList;
                }
                
                //Inserting Invoice line items
                if(invLnItms.size() > 0){
                    for(Invoice_Line_Item__c invItm: invLnItms)
                        invItm.Enrollment__c = invItm.Enrollment__r.Id;
                    insert invLnItms;
                }
                
                //Insert Payment record
                Payment__c payment = UtilityClass.fillPayment(parAcc.Id, inv.Id, ConstantClass.paidStatus , totPayAmt);
                //   payment.RecordTypeId= Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Transaction').getRecordTypeId(); 
                payment.Transaction_Id__c = refNo;
                payment.Cash_Mode__c = payMode;
                insert payment;
                
                //Payment credit for referral discount
                if(referralDis != null){
                    //Payment__c reffCreditPay  = EnrollmentUtility.fillPayment(referralDis.referralById , null, 'Pending' , referralDis.amount);
                    // reffCreditPay.RecordTypeId= Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment As Credit').getRecordTypeId(); 
                    //insPayList.add(reffCreditPay);
                    
                    /* Credit_Note__c crNote = new Credit_Note__c();
crNote.Amount__c =  referralDis.amount;
crNote.Customer__c = referralDis.referralById;
crNote.Date_Issued__c = System.today();
crNote.Status__c = 'Issued';
insert crNote;*/
                    Payment__c paymentAsCredit = UtilityClass.fillPayment(referralDis.referralById, null, 'Pending' , referralDis.amount);
                    paymentAsCredit.Type__c = 'Credit';
                    insert paymentAsCredit;
                }
                strMsg = enrList[enrList.size() - 1].Id;
            }else{
                strMsg = 'Error: Object permission issue, please check with Admin.';
            }    
        }catch(Exception e){
            Database.rollback(sp);
            System.debug('@@@@ Error:   '+e.getMessage() + e.getLineNumber());
            strMsg = 'Error: '+e.getMessage();
        }
        
        return strMsg;
    }
    
    //Its used to find next class term
    public static Map<String, Class_Term__c> getNextClassTerm(List<Subscription_Line_Item__c> subLnItmList){
        Map<String, Class_Term__c> nextClsTermMap = new Map<String, Class_Term__c>();
        
        return nextClsTermMap;
    }
    
    //Its used to initialize blank customer wrapper
    @auraEnabled
    public static CustomerWrapper blankInitializeCstmrWrpr(){
        return new CustomerWrapper();
    }
    
    //This function is used to add blank student on Enrollment page
    @auraEnabled
    public static List<CustomerWrapper> addStudents(List<CustomerWrapper> stuClsWrapperList){
        if(stuClsWrapperList == null)
            stuClsWrapperList = new List<CustomerWrapper>();
        
        stuClsWrapperList.add(new CustomerWrapper());
        return stuClsWrapperList;
    }
    
    public class CustomerWrapper{
        @AuraEnabled public Integer stuRecNo{get;set;}
        @AuraEnabled public Account studentDetails{get;set;}
        @AuraEnabled public List<CourseFeeWrapper> slctdClsDetails{get;set;}
        
        public CustomerWrapper(){
            this.stuRecNo   = stuRecNo;
            studentDetails  = new Account();
            slctdClsDetails = new List<CourseFeeWrapper>();
        }
    }
    
    public class CourseFeeWrapper{
        @AuraEnabled public List<ClassWrapper> classWrapperList{get;set;}
        @AuraEnabled public List<FeeWrapper>   tutionFeeWrapperList{get;set;}
        @AuraEnabled public List<FeeWrapper>   depositWrapperList{get;set;}
        @AuraEnabled public List<FeeWrapper>   feeWrapperList{get;set;}
        @AuraEnabled public List<DisWrapper>   disWrapperList{get;set;}
        @AuraEnabled public List<DisWrapper>   earlybirdDisWrapperList{get;set;}
        @AuraEnabled public ClassWrapper slcdClsWrapObj{get;set;}  
        @AuraEnabled public Date         enrolDate{get;set;}
        @AuraEnabled public Date 		 enrolEndDate{get;set;}
        @AuraEnabled public String       comments{get;set;}
        @AuraEnabled public Decimal      totFee{get;set;}
        @AuraEnabled public Decimal      totWithProratedFee{get;set;}
        @AuraEnabled public String       typeAddEdit{get;set;}
        @AuraEnabled public Integer      recNo{get;set;} 
        
        public CourseFeeWrapper(){
            this.classWrapperList = new List<ClassWrapper>();
            this.tutionFeeWrapperList = new List<FeeWrapper>();
            this.depositWrapperList   = new List<FeeWrapper>();
            this.feeWrapperList       = new List<FeeWrapper>();
            this.disWrapperList       = new List<DisWrapper>();
            this.earlybirdDisWrapperList= new List<DisWrapper>();
            this.totFee               = 0 ;
            this.totWithProratedFee   = 0;
            this.enrolDate            = System.today();
            this.enrolEndDate 		  = null;
            this.slcdClsWrapObj       = new ClassWrapper();
            this.typeAddEdit          = 'Add';
        }
    }
    
    public class ClassWrapper{
        @AuraEnabled public Integer recNo{get;set;}
        @AuraEnabled public String  clsId{get;set;}
        @AuraEnabled public String  clsName{get;set;}
        @AuraEnabled public String  clsType{get;set;}
        @AuraEnabled public String  clsFrequency{get;set;}
        @AuraEnabled public String  clsDays{get;set;}
        @AuraEnabled public Date    clsEndDate{get;set;}
        @AuraEnabled public String  locationId{get;set;}
        @AuraEnabled public String  location{get;set;}
        @AuraEnabled public String  stEndDate{get;set;}
        @AuraEnabled public String  stEndTime{get;set;}
        @AuraEnabled public String  teacherName{get;set;}
        @AuraEnabled public Integer seatsAlv{get;set;}
        @AuraEnabled public Decimal fees{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        
        @AuraEnabled public String slctClsTermId{get;set;} 
        @AuraEnabled public String slctclsTermName{get;set;}
        
        @AuraEnabled public List<TermWrapper> termList{get;set;}
        public ClassWrapper(){
            this.fees = this.seatsAlv = 0;
            this.isSelected = false;
            this.termList = new  List<TermWrapper>();
        }
    }
    
    public class TermWrapper{ 
        @AuraEnabled public String clsTermId{get;set;} 
        @AuraEnabled public String clsTermName{get;set;}
        @AuraEnabled public String stEndDate{get;set;}
        
        public TermWrapper(){}
    }
    
    public class FeeWrapper{ 
        @AuraEnabled public String  feeId{get;set;}
        @AuraEnabled public String  feeName{get;set;}
        @AuraEnabled public String  feeType{get;set;}
        @AuraEnabled public String  payFrequency{get;set;}
        @AuraEnabled public String  feeSchType{get;set;}
        @AuraEnabled public String  feeParent{get;set;}
        @AuraEnabled public Integer noOfUnit{get;set;}
        @AuraEnabled public Decimal tutionFeeUnitPrice{get;set;}
        @AuraEnabled public Decimal feeAmount{get;set;}
        @AuraEnabled public Decimal feeProratedAmount{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public Boolean isOverride{get;set;}
        @AuraEnabled public Boolean isGSTApplicable{get;set;}
        
        public FeeWrapper(){
            this.feeAmount  = 0;
            this.feeProratedAmount  = 0;
            this.tutionFeeUnitPrice = 0;
            this.noOfUnit   = 0;
            this.isSelected = False;
            this.isOverride = False;
            this.isGSTApplicable = False;
        }
    }
    
    public class DisWrapper{ 
        @AuraEnabled public String  disId{get;set;}
        @AuraEnabled public String  name{get;set;}
        @AuraEnabled public String  type{get;set;}
        @AuraEnabled public Decimal amount{get;set;}
        @AuraEnabled public String  format{get;set;}
        @AuraEnabled public String  referralBy{get;set;}
        @AuraEnabled public String  referralById{get;set;}
        @AuraEnabled public String  enterCode{get;set;}
        @AuraEnabled public String  promoCode{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public Boolean isOverride{get;set;}
        
        public DisWrapper(){
            this.amount   = 0;
            this.isSelected = False;
            this.isOverride = False;
        }
    }
}