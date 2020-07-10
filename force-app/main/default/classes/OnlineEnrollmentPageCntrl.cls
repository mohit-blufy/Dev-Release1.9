public class OnlineEnrollmentPageCntrl {
  /*  public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    public CourseDetailModel crsDetailObj{get;set;}
    public ContactModel 	 cstmrObj{get;set;}
    public Integer index {get;set;}
    public Boolean termsnCon{get;set;}
    public AccoutStudentModel stuDetailsToAdd {get;set;}
    public String logoImageURL{get;set;}
    public Boolean checkReqFieldsBlank {get;set;}
    public Boolean checkReqFieldsBlankForCourse {get;set;}
    
    public OnlineEnrollmentPageCntrl(){
        stuDetailsToAdd = new AccoutStudentModel();
        crsDetailObj = new CourseDetailModel();
        cstmrObj = new ContactModel();
        termsnCon = false;
        checkReqFieldsBlank = false;
        checkReqFieldsBlankForCourse = false;
        logoImageURL = '/servlet/servlet.FileDownload?file=';
        List<Document> listDocument = [SELECT name FROM document WHERE Name =: Label.LogoDocumentName];
        
        if(listDocument.size()>0){
            logoImageURL = logoImageURL + listDocument[0].id;
        }
        system.debug('logoImageURL-->'+logoImageURL);
        for(Online_Process_Config__mdt procCon: [SELECT MasterLabel, Field_Api_Name__c, Section__c, Type__c, Sequence__c,Required__c 
                                                 FROM Online_Process_Config__mdt WHERE Active__c=True AND 
                                                 Type__c='Visible' AND Section__c != null ORDER BY Sequence__c]){
                                                     FieldsModel fm = new FieldsModel(procCon.MasterLabel, procCon.Field_Api_Name__c,procCon.Required__c);
                                                     if(procCon.Section__c.equalsIgnoreCase('Contact Details')){
                                                         cstmrObj.conFieldList.add(fm);                                             
                                                     }else if(procCon.Section__c.equalsIgnoreCase('Contact Address Details')){
                                                         cstmrObj.conAddFieldList.add(fm);       
                                                     }else if(procCon.Section__c.equalsIgnoreCase('Student Details')){
                                                         stuDetailsToAdd.stuFieldList.add(fm);
                                                         //cstmrObj.stuDetail[0].stuFieldList.add(fm);
                                                     }
                                                     else if(procCon.Section__c.equalsIgnoreCase('Enrollment Details')){
                                                         stuDetailsToAdd.enrolDetails.listEnrolFields.add(fm);
                                                         //cstmrObj.stuDetail[0].stuFieldList.add(fm);
                                                     }
                                                 }
        
        String clsId = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(clsId)){
            fetchClsDetails(clsId);
        }
    }
    
    private void fetchClsDetails(String clsId){
        List<Class__c> clsList = [SELECT Id, Name,Course__c, Course__r.Name,Location__c,Location__r.Name, Teacher__r.Name,
                                  Frequency__c,Course__r.Description__c,Type__c,
                                  Days_of_Week__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c 
                                  FROM Class__c WHERE Id=:clsId];
        if(clsList.size() > 0){
            Class__c cls = clsList.get(0);
            crsDetailObj.cls = clsList.get(0);
            crsDetailObj.crsName  = cls.Course__r.Name;
            crsDetailObj.crDescription = cls.Course__r.Description__c;
            crsDetailObj.clsName  = cls.Name;
            crsDetailObj.location = cls.Location__r.Name;
            crsDetailObj.tchrName = cls.Teacher__r.Name;
            crsDetailObj.strtDate = (cls.Start_Date__c != null ? cls.Start_Date__c : null);
            crsDetailObj.endDate = (cls.End_Date__c != null ? cls.End_Date__c : null);
            crsDetailObj.stTime   =  Datetime.newInstance(System.today(), cls.Start_Time__c);
            crsDetailObj.endTime  =  Datetime.newInstance(System.today(), cls.End_Time__c);
            fetchFeeDetails(cls.Id,cls.Course__c,crsDetailObj.strtDate);
        }
    }
    
    private void fetchFeeDetails(String clsId,String courseId,Date clsStrtDate){
        for(Course_Fee__c crFee: [SELECT Id, Name,Primary__c,Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Schedule__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c, Fee__r.Override__c
                                  FROM Course_Fee__c WHERE Course__c =: courseId AND Fee__r.Amount__c != NULL AND Fee__r.Type__c != NULL 
                                 ]){
                                     FeeWrapper fw = new FeeWrapper();
                                     fw.feeId      = crFee.Fee__c;                         
                                     fw.feeName    = crFee.Fee__r.Name;
                                     fw.feeType    = crFee.Fee__r.Type__c;
                                     fw.feeFrequency = crFee.Fee__r.Frequency__c;  
                                     fw.feeSchedule = crFee.Fee__r.Schedule__c;
                                     fw.feeAmount = crFee.Fee__r.Amount__c;
                                     fw.isSelected = crFee.Fee__r.Required__c;
                                     fw.isOverride = crFee.Fee__r.Override__c;
                                     if(crFee.Fee__r.Type__c == ConstantClass.tutionFeeType && crFee.Primary__c){
                                         crsDetailObj.listTuitionFeeWrpper.add(fw);
                                         fw.isPrimary = crFee.Primary__c;
                                         fw.tutionFeeUnitPrice = crFee.Fee__r.Unit_Price__c;
                                     }
                                     else if(crFee.Fee__r.Type__c != ConstantClass.tutionFeeType){
                                         crsDetailObj.listOtherFeeWrpper.add(fw);
                                     }   
                                 }
        Integer diffInDays = System.today().daysBetween(clsStrtDate);
                    for(Course_Discount__c crsDis: [SELECT Id, Name, Discount__c, Discount__r.Name, Discount__r.Days_Before_Class__c, Discount__r.Value__c, Discount__r.Override__c, Discount__r.Required__c,
                                                    Discount__r.Type__c, Discount__r.Format__c, Discount__r.Start_Date__c, Discount__r.End_Date__c 
                                                    FROM Course_Discount__c 
                                                    WHERE Course__c =:courseId AND Discount__r.Days_Before_Class__c != null AND Discount__r.Format__c != null AND
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
                                                            crsDetailObj.listDisWrapper.add(dw);
                                                        }
                                                    }
        
        if(crsDetailObj.listTuitionFeeWrpper.size() > 0){
            FeeWrapper tutionFee = crsDetailObj.listTuitionFeeWrpper[0];
            if(crsDetailObj.listDisWrapper.size() > 0)
                crsDetailObj.crsefeeWithEBDisCount = tutionFee.feeAmount - crsDetailObj.listDisWrapper[0].amount;
            crsDetailObj.crsefee = tutionFee.feeAmount;
            if(String.isNotBlank(tutionFee.feeSchedule) && tutionFee.feeSchedule.equalsIgnoreCase(ConstantClass.fixedType)){
                tutionFee.feeProratedAmount = tutionFee.feeAmount;
            }
            else{
                Integer noOfLessInCurrMonth = 0;
                if(tutionFee.feeFrequency.equalsIgnoreCase(ConstantClass.monthlyFrequency)){
                    if(crsDetailObj.enrolDate.month() == System.today().month()){
                        Integer numberOfDays = Date.daysInMonth(crsDetailObj.enrolDate.year(), crsDetailObj.enrolDate.month());
                        Date lastDayOfMonth = Date.newInstance(crsDetailObj.enrolDate.year(), crsDetailObj.enrolDate.month(), numberOfDays);
                        
                        List<Session__c> sessList  = [SELECT Id, Name, Class__c, Sequence__c, Session_Date__c
                                                      FROM Session__c
                                                      WHERE Class__c =:clsId AND Status__c =: ConstantClass.scheduledStatus
                                                      AND Session_Date__c >=:crsDetailObj.enrolDate AND Session_Date__c <=: lastDayOfMonth];  
                        noOfLessInCurrMonth = sessList.size();
                    }
                }else{//Calculate prorated number of lesson for Term/Fixed type class on the bases of selected date
                    List<Class_Term__c> clsTermList = [SELECT Id, Name, Sequence__c, Sessions__c, Start_Date__c, End_Date__c,Class__c 
                                                       FROM Class_Term__c
                                                       WHERE Class__c=: clsId AND Status__c =:ConstantClass.ScheduledStatus AND Allow_Enrollment__c = True AND 
                                                       Sessions__c > 0 AND Start_Date__c != null AND End_Date__c >: crsDetailObj.enrolDate ORDER BY Sequence__c];
                    Class_Term__c clsTerm = new Class_Term__c();
                    if(clsTermList.size() > 0){
                        //get specifi class term according to the selected enrolment date
                        for(Class_Term__c clsTermTemp: clsTermList){
                            if(clsTermTemp.Start_Date__c <= crsDetailObj.enrolDate && crsDetailObj.enrolDate < clsTermTemp.End_Date__c){
                                clsTerm = clsTermTemp;
                                break;
                            }
                        }    
                        //Check if no class term avaialble according to the enrolment date, Then check next term
                        if(clsTerm.Id == null){
                            for(Class_Term__c clsTermTemp: clsTermList){
                                if(clsTermTemp.End_Date__c > crsDetailObj.enrolDate){
                                    clsTerm = clsTermTemp;
                                    break;
                                }
                            } 
                        }    
                    }        
                    //Fetch number of remaining session on the bases of term selected
                    if(clsTerm.Id != null){
                        List<Session__c> sessList  = [SELECT Id, Name, Class__c, Sequence__c, Session_Date__c, Teacher__c, Status__c  
                                                      FROM Session__c
                                                      WHERE Class_Term__c =:clsTerm.Id AND Status__c =: ConstantClass.scheduledStatus
                                                      AND Session_Date__c >=: crsDetailObj.enrolDate];  
                        crsDetailObj.clsTrm = clsTerm;
                        noOfLessInCurrMonth = sessList.size();
                        System.debug('crsDetailObj.clsTrm--->'+crsDetailObj.clsTrm);
                        System.debug('sessList.size()--->'+sessList.size());
                    }
                }
                tutionFee.feeProratedAmount = tutionFee.tutionFeeUnitPrice * noOfLessInCurrMonth;
                System.debug('@@--->'+noOfLessInCurrMonth);
            }
            
            
            //Decimal packFee = tutionFee.tutionFeeUnitPrice * noOfLessInCurrMonth;
            
            //tutionFee.feeProratedAmount = packFee;
            crsDetailObj.listTuitionFeeWrpper[0] = tutionFee;
        }
    }
    
    public void addNewStudent(){
        Boolean checkDynStuReqFieldsBlank = false;
        
        if(String.isBlank(stuDetailsToAdd.firstName) || String.isBlank(stuDetailsToAdd.lastName) || String.isBlank(stuDetailsToAdd.slcdGender) ||
           stuDetailsToAdd.stuDob == NULL || String.isBlank(stuDetailsToAdd.slcdRelation)){
               checkReqFieldsBlank = true;
           }
        else
            checkReqFieldsBlank = false;
        
        
        if(stuDetailsToAdd.stuFieldList.size() > 0){
            for(FieldsModel fm : stuDetailsToAdd.stuFieldList){
                if(fm.fieldRequired && String.isBlank(fm.fieldValue)){
                    fm.showRequired = true;
                }
                else
                    fm.showRequired = false;
            }
            
            for(FieldsModel fm : stuDetailsToAdd.stuFieldList){
                if(fm.showRequired){
                    checkDynStuReqFieldsBlank = true;
                    break;
                }
            }
        }
        system.debug('stuDetailsToAdd.stuFieldList-->'+stuDetailsToAdd.stuFieldList);
        system.debug('checkReqFieldsBlank-->'+checkReqFieldsBlank);
        if(!checkReqFieldsBlank && !checkDynStuReqFieldsBlank){
            cstmrObj.stuDetail.add(stuDetailsToAdd);
            generateEnrolmntSummary();
            stuDetailsToAdd = new  AccoutStudentModel();
            for(Online_Process_Config__mdt procCon: [SELECT MasterLabel, Field_Api_Name__c, Section__c, Type__c, Sequence__c,Required__c 
                                                     FROM   Online_Process_Config__mdt WHERE Active__c=True AND 
                                                     Type__c='Visible' AND Section__c IN ('Student Details','Enrollment Details') ORDER BY Sequence__c]){
                                                         FieldsModel fm = new FieldsModel(procCon.MasterLabel, procCon.Field_Api_Name__c,procCon.Required__c);
                                                         if(procCon.Section__c.equalsIgnoreCase('Student Details')){
                                                             stuDetailsToAdd.stuFieldList.add(fm);
                                                             //cstmrObj.stuDetail[0].stuFieldList.add(fm);
                                                         }
                                                         else if(procCon.Section__c.equalsIgnoreCase('Enrollment Details')){
                                                             stuDetailsToAdd.enrolDetails.listEnrolFields.add(fm);
                                                             //cstmrObj.stuDetail[0].stuFieldList.add(fm);
                                                         }
                                                     }
            system.debug('stuDetailsToAdd.stuFieldList-->'+stuDetailsToAdd.stuFieldList);
        }        
    }
    
    public void deleteStudent (){
        system.debug('index-->'+index);
        cstmrObj.stuDetail.remove(index);
        cstmrObj.totalEnrlFee = 0;
        for(AccoutStudentModel stu : cstmrObj.stuDetail){
            cstmrObj.totalEnrlFee += stu.totalFeeAmt;
        }
    }
    
    public void generateEnrolmntSummary(){
        for(AccoutStudentModel stu : cstmrObj.stuDetail){
            if(!stu.isAdded){
                for(FeeWrapper tuitionFee : crsDetailObj.listTuitionFeeWrpper){
                    if(tuitionFee.isSelected){
                        stu.totalFeeAmt += tuitionFee.feeProratedAmount;
                        stu.listStuCrseFeeWrpper.add(tuitionFee);
                        system.debug('stu.totalFeeAmt-->'+stu.totalFeeAmt);
                    }
                }
                
                for(FeeWrapper otherFee : crsDetailObj.listOtherFeeWrpper){
                    if(otherFee.isSelected){
                        stu.totalFeeAmt += otherFee.feeAmount;
                        stu.listStuCrseFeeWrpper.add(otherFee);
                        system.debug('stu.totalFeeAmt-->'+stu.totalFeeAmt);
                    }
                }
                stu.isAdded = true;
            }
        }
        system.debug('cstmrObj.stuDetail-->'+cstmrObj.stuDetail.size());
        cstmrObj.totalEnrlFee = 0;
        for(AccoutStudentModel stu : cstmrObj.stuDetail){
            cstmrObj.totalEnrlFee += stu.totalFeeAmt;
        }
    }
    
    private Boolean validateFieldValues(){
        Boolean checkCusConListReqField = false;
        Boolean checkCusConAddListReqField = false;
        
        if(String.isBlank(cstmrObj.cstmrDetail.firstName) || String.isBlank(cstmrObj.cstmrDetail.lastName) || String.isBlank(cstmrObj.cstmrDetail.phone) ||
           String.isBlank(cstmrObj.cstmrDetail.email)){
               checkReqFieldsBlankForCourse = true;
           }
        else
            checkReqFieldsBlankForCourse = false;
        
        if(cstmrObj.conFieldList.size() > 0){
            for(FieldsModel fm : cstmrObj.conFieldList){
                if(fm.fieldRequired && String.isBlank(fm.fieldValue)){
                    fm.showRequired = true;
                }
                else
                    fm.showRequired = false;
            }
            
            for(FieldsModel fm : cstmrObj.conFieldList){
                if(fm.showRequired){
                    checkCusConListReqField = true;
                    break;
                }
            }
        }
        
        if(cstmrObj.conAddFieldList.size() > 0){
            for(FieldsModel fm : cstmrObj.conAddFieldList){
                if(fm.fieldRequired && String.isBlank(fm.fieldValue)){
                    fm.showRequired = true;
                }
                else
                    fm.showRequired = false;
            }
            
            for(FieldsModel fm : cstmrObj.conAddFieldList){
                if(fm.showRequired){
                    checkCusConAddListReqField = true;
                    break;
                }
            }
        }
        
        return (!checkReqFieldsBlankForCourse && !checkCusConListReqField && !checkCusConAddListReqField);
    }
    
    public Pagereference completeEnrollment(){
        if(!(cstmrObj.stuDetail.size() > 0)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'CONFIRM: Account Created.');
            ApexPages.addMessage(myMsg);
        }
        
        if(validateFieldValues()){
            Savepoint sp;
            try{
                sp = Database.setSavepoint();
                Date enrolDate = crsDetailObj.enrolDate;
                List<Account> listStudentAccount = new List<Account>();
                List<Session__c> listSession = new List<Session__c>();
                List<Class_Term__c> listNextClassTerm = new List<Class_Term__c>();
                Map<String, Subscription__c> mapSubFreqToSubscrption = new Map<String, Subscription__c>();
                List<Enrollment__c> listEnrollment   = new List<Enrollment__c>();
                List<Subscription_Line_Item__c> listSubineItem = new List<Subscription_Line_Item__c>();
                List<Student_Session__c> listStudntSess = new List<Student_Session__c>();
                List<Invoice_Line_Item__c> listInvLinItms = new List<Invoice_Line_Item__c>();
                
                //For term or fixed based sessions 
                if(String.isNotBlank(crsDetailObj.clsTrm.Id)){
                    Class_Term__c clsTrm = crsDetailObj.clsTrm;
                    listSession = [SELECT Id, Name, Class__c, Class_Term__c, Sequence__c, Session_Date__c, Teacher__c, Status__c, 
                                   Class_Term__r.Sequence__c, Class_Term__r.Start_Date__c, Class_Term__r.End_Date__c 
                                   FROM Session__c 
                                   WHERE Class_Term__c =: clsTrm.Id AND Class__c != NULL AND Session_Date__c >=: enrolDate ORDER BY Sequence__c];
                    
                    for(Class__c cls: [SELECT Id, Name, (SELECT Id, Name, Sequence__c, Start_Date__c, End_Date__c, Class__r.Advance_Billing_Unit__c, 
                                                         Class__c,Class__r.Advance_Billing__c 
                                                         FROM Class_Terms__r 
                                                         WHERE Start_Date__c > TODAY AND Sequence__c != null ORDER BY Start_Date__c) 
                                       FROM Class__c WHERE Id =: clsTrm.Class__c]){
                                           for(Class_Term__c clsTerm : cls.Class_Terms__r){
                                               if(clsTerm.Start_Date__c > clsTrm.Start_Date__c){
                                                   listNextClassTerm.add(clsTerm);
                                                   break;
                                               }       
                                           }
                                       }
                }else{
                    String classId = crsDetailObj.clsTrm.Class__c;
                    listSession = [SELECT Id, Name, Class__c, Class_Term__c, Sequence__c, Session_Date__c, Teacher__c, Status__c, 
                                   Class_Term__r.Sequence__c, Class_Term__r.Start_Date__c, Class_Term__r.End_Date__c 
                                   FROM Session__c 
                                   WHERE Class__c =: classId AND Class__c != NULL AND Session_Date__c >=: enrolDate ORDER BY Sequence__c];
                }
                
                String recTypeId = ConstantClass.customerRecTypeId;
                system.debug(cstmrObj.stuDetail.size());
                Account parAcc 		= new Account();
                parAcc.RecordTypeId = recTypeId;
                parAcc.FirstName    = cstmrObj.cstmrDetail.firstName;
                parAcc.LastName     = cstmrObj.cstmrDetail.lastName;
                parAcc.PersonEmail  = cstmrObj.cstmrDetail.email;
                parAcc.phone    	= cstmrObj.cstmrDetail.phone;
                for(FieldsModel fm: cstmrObj.conFieldList)
                    parAcc.put(fm.fieldApiName, fm.fieldValue);  
                for(FieldsModel fm: cstmrObj.conAddFieldList)
                    parAcc.put(fm.fieldApiName, fm.fieldValue);  
                
                List<Account> listExistingAccount = [SELECT Id, Name, (SELECT Id, FirstName, LastName, PersonBirthDate,Gender__c FROM Students__r) 
                                                     FROM Account WHERE PersonEmail =: parAcc.PersonEmail LIMIT 1];
                if(listExistingAccount != NULL && listExistingAccount.size() > 0){
                    parAcc.Id = listExistingAccount[0].Id;
                }
                upsert parAcc;
                
                //Fill invoice
                Invoice__c inv = UtilityClass.fillInvoice(parAcc.Id, null, null, ConstantClass.newEnrollmentInvType, ConstantClass.paidStatus);
                insert inv;
                
                for(Subscription__c sub: [SELECT Id, Location__c, Status__c, Payment_Frequency__c 
                                          FROM Subscription__c 
                                          WHERE Customer__c =: parAcc.Id AND Status__c =:ConstantClass.activeStatus  AND Payment_Frequency__c != null]){
                                              mapSubFreqToSubscrption.put(sub.Payment_Frequency__c, sub);
                                          }
                
                if(cstmrObj.stuDetail.size() > 0){
                    for(AccoutStudentModel stu : cstmrObj.stuDetail){
                        Account stuAcc 		   = new Account();
                        stuAcc.Parent__c	   = parAcc.Id;
                        stuAcc.RecordTypeId    = recTypeId;
                        stuAcc.FirstName       = stu.firstName;
                        stuAcc.LastName        = stu.lastName;
                        stuAcc.Gender__c       = stu.slcdGender;
                        stuAcc.PersonBirthdate = stu.stuDob;
                        stuAcc.Relationship_with_contact__c = stu.slcdRelation;
                        if(stuAcc.Relationship_with_contact__c.equalsIgnoreCase('Self')){
                            stuAcc.Id = parAcc.Id;              
                        }else{
                            stuAcc.Parent__c = parAcc.Id;
                        }
                        for(FieldsModel fm: stu.stuFieldList)
                            stuAcc.put(fm.fieldApiName, fm.fieldValue);
                        
                        if(String.isBlank(stuAcc.Id)){
                            String tempName = stuAcc.FirstName+' '+stuAcc.LastName+' '+stuAcc.PersonBirthDate;
                            if(listExistingAccount != NULL && listExistingAccount.size() > 0){
                                Account parentAcc = listExistingAccount[0];
                                for(Account exisStu: parentAcc.Students__r){
                                    String existingStu = exisStu.FirstName+' '+exisStu.LastName+' '+exisStu.Gender__c+' '+exisStu.PersonBirthDate;
                                    if(tempName.equalsIgnoreCase(existingStu)){
                                        stuAcc.Id = exisStu.Id;
                                        break;
                                    }
                                }
                            }
                            
                        }
                        listStudentAccount.add(stuAcc);
                        
                        Enrollment__c enr  = UtilityClass.fillEnrollment(parAcc.Id,crsDetailObj.cls.Location__c , crsDetailObj.cls.Id, crsDetailObj.enrolDate, ConstantClass.enrolledStatus);
                        enr.Parent_Email__c= parAcc.PersonEmail;
                        enr.Student__r     = stuAcc;
                        //enr.Comments__c    = crsWrap.comments;
                        enr.Terms_and_Conditions__c = true;
                        listEnrollment.add(enr);
                        
                        if(crsDetailObj.listTuitionFeeWrpper.size() > 0){
                            FeeWrapper tutionFee = crsDetailObj.listTuitionFeeWrpper.get(0);
                            if(crsDetailObj.cls.Type__c.equalsIgnoreCase(ConstantClass.ongoingClsType) && tutionFee.feeSchedule.equalsIgnoreCase(ConstantClass.ongoingClsType)){
                                Date subsNextBillingDate; 
                                Subscription__c subs = new Subscription__c();
                                if(mapSubFreqToSubscrption.containsKey(tutionFee.feeFrequency)){
                                    subs = mapSubFreqToSubscrption.get(tutionFee.feeFrequency);
                                }else{
                                    subs.Location__c = crsDetailObj.cls.location__c;
                                    subs.Customer__c = parAcc.Id;
                                    subs.Status__c   = ConstantClass.activeStatus;
                                    subs.Payment_Frequency__c = tutionFee.feeFrequency;
                                    subs.Subscription_Start_Date__c = crsDetailObj.enrolDate;
                                    
                                    // subs.Next_Bill_Date__c = subsNextBillingDate;
                                    mapSubFreqToSubscrption.put(tutionFee.feeFrequency, subs);
                                }
                                
                                Subscription_Line_Item__c subsLnItem = new Subscription_Line_Item__c();
                                subsLnItem.Subscription__r  = subs;
                                subsLnItem.Enrollment__r    = enr;
                                subsLnItem.Fee__c           = tutionFee.feeId;
                                subsLnItem.Status__c        = ConstantClass.activeStatus;
                                subsLnItem.Subscription_Start_Date__c = crsDetailObj.enrolDate;
                                
                                if(tutionFee.feeFrequency.equalsIgnoreCase(ConstantClass.termFrequency)){
                                    if(listNextClassTerm.size() > 0){
                                        Class_Term__c nextClsTerm = listNextClassTerm[0];
                                        
                                        String schUnit  = nextClsTerm.Class__r.Advance_Billing_Unit__c;
                                        Date nextSchDt  = nextClsTerm.Start_Date__c;
                                        
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
                                listSubineItem.add(subsLnItem); 
                            }else if(crsDetailObj.cls.Type__c.equalsIgnoreCase(ConstantClass.fixedType) && tutionFee.feeSchedule.equalsIgnoreCase(ConstantClass.fixedType)){
                                for(Session__c sess : listSession){
                                    Student_Session__c stuSess = new Student_Session__c();
                                    stuSess.Account__r   = stuAcc;
                                    stuSess.Session__c   = sess.Id;
                                    stuSess.Enrollment__r= enr;
                                    stuSess.Status__c= ConstantClass.ScheduledStatus;
                                    stuSess.Billable__c= True;
                                    listStudntSess.add(stuSess);   
                                }
                            }
                            
                            //Invoice line items for tution fee
                            for(FeeWrapper fw: crsDetailObj.listTuitionFeeWrpper){
                                Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, fw.feeId, null, ConstantClass.feeType, fw.feeProratedAmount, true);
                                invLnItm.Enrollment__r = enr;
                                listInvLinItms.add(invLnItm);
                            }
                            
                            //Invoice line items for Other fee
                            for(FeeWrapper fw: crsDetailObj.listOtherFeeWrpper){
                                Invoice_Line_Item__c invLnItm = UtilityClass.fillInvLineItem(inv.Id, null, null, fw.feeId, null, ConstantClass.feeType, fw.feeAmount, true);
                                invLnItm.Enrollment__r = enr;
                                listInvLinItms.add(invLnItm);
                            }
                        }
                    }  
                }
                
                if(listStudentAccount.size() > 0)
                    upsert listStudentAccount;
                
                if(listEnrollment.size() > 0){
                    for(Enrollment__c enr: listEnrollment){
                        enr.Student__c = enr.Student__r.Id;
                    }
                    insert listEnrollment;
                }
                
                if(mapSubFreqToSubscrption.values().size() > 0){
                    upsert mapSubFreqToSubscrption.values();
                    
                    //Inserting Subscription Line Items
                    if(listSubineItem.size() > 0){
                     for(Subscription_Line_Item__c subLnItm : listSubineItem){
                            subLnItm.Subscription__c  = subLnItm.Subscription__r.Id;
                            subLnItm.Enrollment__c    = subLnItm.Enrollment__r.Id;
                        }
                        insert listSubineItem;
                    }
                }
                
                //Inserting student session bases of the session term
                if(listStudntSess.size() > 0){
                    for(Student_Session__c stuSess: listStudntSess){
                        stuSess.Account__c   = stuSess.Account__r.Id;
                        stuSess.Enrollment__c= stuSess.Enrollment__r.Id;
                    }
                    insert listStudntSess;
                }
                
                //Inserting Invoice line items
                if(listInvLinItms.size() > 0){
                    for(Invoice_Line_Item__c invItm: listInvLinItms)
                        invItm.Enrollment__c = invItm.Enrollment__r.Id;
                    insert listInvLinItms;
                }
                
                Payment__c payment = UtilityClass.fillPayment(parAcc.Id, inv.Id, ConstantClass.paidStatus ,cstmrObj.totalEnrlFee);
                //   payment.RecordTypeId= Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Transaction').getRecordTypeId(); 
                // payment.Transaction_Id__c = refNo;
                //payment.Cash_Mode__c = payMode;
                insert payment;
                return new Pagereference('/apex/EnrollmentConfirmationPage');
            }catch(Exception e){
                Database.rollback(sp);
                System.debug('@@@@ Error:   '+e.getMessage() + ' '+e.getLineNumber());
                return null;
            }
        }
        return null;
        
    }
    
    public List<SelectOption> getGenderList(){
        List<SelectOption> genList = new List<SelectOption>();
        genList.add(new SelectOption('','--Select Gender--')); 
        for(String genValue : UtilityClass.getPickValues('Account','Gender__c'))
            genList.add(new SelectOption(genValue,genValue)); 
        return genList;
    }
    
    public List<SelectOption> getRelationList(){
        List<SelectOption> relList = new List<SelectOption>();
        relList.add(new SelectOption('','--Select Relationship--')); 
        for(String relValue : UtilityClass.getPickValues('Account','Relationship_with_contact__c')){
            relList.add(new SelectOption(relValue,relValue));
        } 
        return relList;
    }
    
    public class CourseDetailModel{
        public String crsName {get;set;}
        public String crDescription {get;set;}
        public String clsName {get;set;}
        public String location {get;set;}
        public String tchrName {get;set;}
        public Date strtDate {get;set;}
        public Date endDate {get;set;}
        public DateTime stTime {get;set;}
        public DateTime endTime {get;set;}
        public Date enrolDate {get;set;}
        public String comments {get;set;}
        public Decimal crsefee {get;set;}
        public Decimal crsefeeWithEBDisCount {get;set;}
        public Class__c cls {get;set;}
        public Class_Term__c clsTrm {get;set;}
        public List<FeeWrapper> listTuitionFeeWrpper {get;set;}
        public List<FeeWrapper> listOtherFeeWrpper {get;set;}
        public List<DisWrapper> listDisWrapper {get;set;}
        public CourseDetailModel(){
            cls = new Class__c();
            clsTrm = new Class_Term__c();
            crsefee = 0;
            crsefeeWithEBDisCount = 0;
            listOtherFeeWrpper 	 = new List<FeeWrapper>();
            listTuitionFeeWrpper = new List<FeeWrapper>();
            listDisWrapper 		 = new List<DisWrapper>();  
            enrolDate = System.today();
        }
    }
    
    public class ContactModel{
        public AccoutModel cstmrDetail{get;set;}
        public List<FieldsModel> conFieldList{get;set;}
        public List<FieldsModel> conAddFieldList{get;set;}
        public Decimal totalEnrlFee {get;set;}
        public List<AccoutStudentModel> stuDetail{get;set;}   
        
        public ContactModel(){
            cstmrDetail 	= new AccoutModel();
            totalEnrlFee 	= 0;
            conFieldList 	= new List<FieldsModel>();
            conAddFieldList = new List<FieldsModel>();
            stuDetail  		= new List<AccoutStudentModel>();
        }
    }
    
    public class AccoutModel{
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String email{get;set;}
        public String phone{get;set;}
        
        public AccoutModel(){}
    }
    
    //For student
    public class AccoutStudentModel{
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String slcdGender{get;set;}
        public String slcdRelation{get;set;}
        public Boolean isAdded {get;set;}
        public Date   stuDob{get;set;}
        public Decimal totalFeeAmt {get;set;}
        public List<FieldsModel>  stuFieldList{get;set;}
        public List<FeeWrapper> listStuCrseFeeWrpper {get;set;}
        public EnrollemtModel enrolDetails {get;set;}
        
        public AccoutStudentModel(){
            isAdded = false;
            totalFeeAmt = 0; 
            stuFieldList   = new List<FieldsModel>();
            listStuCrseFeeWrpper = new List<FeeWrapper>();
            enrolDetails 	= new EnrollemtModel();
        }
    }
    
    public class EnrollemtModel{
        public Date   enrolDate {get;set;}
        public List<FieldsModel>  listEnrolFields{get;set;}
        public EnrollemtModel(){ 
            listEnrolFields   = new List<FieldsModel>();
        }
    }
    
    public class FieldsModel{
        public String fieldLabel{get;set;}
        public String fieldValue{get;set;}
        public Boolean fieldRequired{get;set;}
        String fieldApiName;
        public Boolean showRequired {get;set;}
        
        public FieldsModel(String fieldLabel, String fieldApiName,Boolean fieldRequired){
            this.fieldLabel   = fieldLabel;
            this.fieldApiName = fieldApiName;
            this.fieldRequired = fieldRequired;
            this.showRequired = false;
        }
    }
    
    public class FeeWrapper{ 
        public String  feeId{get;set;}
        public String  feeName{get;set;}
        public String  feeSchedule{get;set;}
        public String  feeType{get;set;}
        public String  feeFrequency{get;set;}
        public Decimal tutionFeeUnitPrice{get;set;}
        public Decimal feeAmount{get;set;}
        public Decimal feeProratedAmount{get;set;}
        public Boolean isSelected{get;set;}
        public Boolean isOverride{get;set;}
        public Boolean isPrimary{get;set;}
        
        public FeeWrapper(){
            feeAmount  = 0;
            feeProratedAmount = 0;
            tutionFeeUnitPrice = 0;
            isSelected = false;
            isOverride = false;
            isPrimary = false;
        }
    }
    
    public class DisWrapper{ 
        @AuraEnabled public String  disId{get;set;}
        @AuraEnabled public String  name{get;set;}
        @AuraEnabled public String  type{get;set;}
        @AuraEnabled public Decimal amount{get;set;}
        @AuraEnabled public String  format{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public Boolean isOverride{get;set;}
        
        public DisWrapper(){
            this.amount   = 0;
            this.isSelected = False;
            this.isOverride = False;
        }
    }*/
}