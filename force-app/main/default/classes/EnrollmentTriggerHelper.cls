public with sharing class EnrollmentTriggerHelper {
    public EnrollmentTriggerHelper() {}
    
    public static void insertFeeAlloaction(List<Enrollment__c> enrList, Set<Id> enrIdSet){
        Map<Id,Enrollment__c> enrolmap = new map<Id,Enrollment__c>();
        Date minEnrDate;
        Date maxEnrDate;
        for(Enrollment__c enr: EnrollmentService.getById(enrIdSet)){
            enrolmap.put(enr.Id, enr);
            
            if(minEnrDate == null || minEnrDate > enr.Start_Date__c)
                minEnrDate = enr.Start_Date__c;
            if(maxEnrDate == null || maxEnrDate < enr.Enrollment_End_Date__c)    
                maxEnrDate = enr.Enrollment_End_Date__c;
        }
        Map<Date,Holiday__c> holidayDateMap = new Map<Date,Holiday__c>();
        
        for (Holiday__c holiday : HolidayService.getByDate(minEnrDate, maxEnrDate)){
            for(Date dt=holiday.Start_Date__c; dt<=holiday.End_Date__c; dt=dt.addDays(1))
                holidayDateMap.put(dt, holiday);
        }
        
        Map<String, Decimal> perDaySessFeeMap = new Map<String, Decimal>();
        List<Fee_Allocation__c> feeAllList = new List<Fee_Allocation__c>();
        for(Enrollment__c enrol : enrolmap.values()){ 
            if(enrol.Invoice_Line_Items__r.size() > 0){
                Decimal tutionFee = enrolmap.get(enrol.Id).Invoice_Line_Items__r.get(0).Amount__c;
                
                Integer numberOfDays = 0;
                for(Date dt=enrol.Start_Date__c; dt<=enrol.Enrollment_End_Date__c; dt=dt.addDays(1)){
                    if(!holidayDateMap.containsKey(dt) || (holidayDateMap.containsKey(dt) && enrol.Class__r.Exclude_Public_Holidays__c)){
                        if(enrol.Class__r.Days_of_Week__c.contains(DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('EEE')))
                            numberOfDays = numberOfDays+1;
                    }
                }
                if(numberOfDays > 0)
                    perDaySessFeeMap.put(enrol.Id, UtilityClass.roundOffAmount((tutionFee/numberOfDays)));
            }
        }    
        
        for(Enrollment__c enrol : enrolmap.values()){ 
            if(enrol.Invoice_Line_Items__r.size() > 0 && perDaySessFeeMap.get(enrol.Id) != null && perDaySessFeeMap.get(enrol.Id) > 0){
                Invoice_Line_Item__c tutionFeeInv = enrolmap.get(enrol.Id).Invoice_Line_Items__r.get(0);
                
                Date  currLesDt = null;
                Integer curMonthDays = 0;
                for(Date dt=enrol.Start_Date__c; dt<=enrol.Enrollment_End_Date__c; dt=dt.addDays(1)){
                    if(!holidayDateMap.containsKey(dt) || (holidayDateMap.containsKey(dt) && enrol.Class__r.Exclude_Public_Holidays__c)){
                        if(enrol.Class__r.Days_of_Week__c.contains(DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('EEE'))){
                            if(currLesDt == null)
                                currLesDt = dt;
                            
                            if(currLesDt.month() == dt.month()){
                                curMonthDays = curMonthDays+1;
                                
                                if(dt==enrol.Enrollment_End_Date__c){
                                    Decimal tempTutionFee = UtilityClass.roundOffAmount(perDaySessFeeMap.get(enrol.Id)*curMonthDays);
                                    feeAllList.add(fillFeeAllocation(enrol, tutionFeeInv, curMonthDays, tempTutionFee, currLesDt));
                                    
                                    curMonthDays = 0;
                                }
                            }else{
                                Decimal tempTutionFee = UtilityClass.roundOffAmount(perDaySessFeeMap.get(enrol.Id)*curMonthDays);
                                feeAllList.add(fillFeeAllocation(enrol, tutionFeeInv, curMonthDays, tempTutionFee, currLesDt));
                                
                                curMonthDays = 1;
                                currLesDt = dt;
                            }
                        }
                    }
                }
            }
        }
        if(feeAllList.size() > 0)
            FeeAllocationService.insertRecords(feeAllList);
    }
    
    public static void insertRecordsOnEnrolledEnrollment(List<Enrollment__c> listEnrollment){
        Set<String> setParentAccId = new Set<String>();
        Map<String,String> mapEnrolmentIdToClassId = new Map<String,String>();
        Map<String, Subscription__c> subsMap = new Map<String, Subscription__c>();
        Map<String, List<Class_Term__c>> mapClassToClassTerms = new Map<String, List<Class_Term__c>>();
        Map<String,Enrollment__c> mapEnrolIdToEnrollment = new Map<String,Enrollment__c>();
        Map<String, Subscription__c> mapParentIdToSubscription = new Map<String, Subscription__c>();
        List<Subscription__c> listSubsToInsert = new List<Subscription__c>();
        List<Subscription_Line_Item__c> listSubsItem = new List<Subscription_Line_Item__c>();
        List<Student_Session__c> listStuSession = new List<Student_Session__c>();
        
        for(Enrollment__c enrol : listEnrollment){
            mapEnrolmentIdToClassId.put(enrol.Id,enrol.Class__c);
            if(enrol.Type__c == ConstantClass.ongoingClsType){
                setParentAccId.add(enrol.Parent__c);   
            }
        }
        
        if(setParentAccId.size() > 0){
            List<Subscription__c> listSubscription = SubscriptionService.getClassSessionsByClssId(setParentAccId);
            if(listSubscription.size() > 0){
                for(Subscription__c sub: listSubscription){
                    subsMap.put(sub.Payment_Frequency__c, sub);
                }   
            }
            
        }
        
        if(mapEnrolmentIdToClassId.keySet().size() > 0){
            List<Enrollment__c> listEnroll = EnrollmentService.getEnrollmentRelatedObjectsById(mapEnrolmentIdToClassId.keySet());
            Set<String> setClassId = new Set<String>();
            if(listEnroll.size() > 0){
                for(Enrollment__c enrol :listEnroll)
                    mapEnrolIdToEnrollment.put(enrol.Id,enrol);
            }
            
            setClassId.addAll(mapEnrolmentIdToClassId.values());
            List<Class__c> listClass = ClassService.getClassTermsByClassId(setClassId);
            if(listClass.size() > 0){
                for(Class__c cls : listClass){
                    if(cls.Class_Terms__r.size() > 0){
                        mapClassToClassTerms.put(cls.Id,cls.Class_Terms__r);
                    }
                }
            }
        }
        
        if(mapEnrolIdToEnrollment.keySet().size() > 0){
            for(String key : mapEnrolIdToEnrollment.keySet()){
                Enrollment__c enrolmnt = mapEnrolIdToEnrollment.get(key);
                if(enrolmnt.Student_Sessions__r.size() > 0){
                    for(Student_Session__c stuSess : enrolmnt.Student_Sessions__r){
                        stuSess.Status__c = ConstantClass.ScheduledStatus;
                        listStuSession.add(stuSess);
                    }
                }
                
                if(enrolmnt.Type__c == ConstantClass.ongoingClsType && enrolmnt.Class__r.Type__c == ConstantClass.ongoingClsType
                   && enrolmnt.Invoice_Line_Items__r.size() > 0 && 
                   !(enrolmnt.Invoice_Line_Items__r[0].Fee__r.Frequency__c.equalsIgnoreCase(ConstantClass.oneTimeFrequency))){
                       Subscription__c subs = new Subscription__c();
                       String feeFrequency = enrolmnt.Invoice_Line_Items__r[0].Fee__r.Frequency__c;
                       if(subsMap.containsKey(feeFrequency)){
                           subs = subsMap.get(feeFrequency);
                       }else{
                           subs.Location__c = enrolmnt.Class__r.Location__c;
                           subs.Customer__c = enrolmnt.Parent__c;
                           subs.Status__c   = ConstantClass.activeStatus;
                           subs.Payment_Frequency__c = feeFrequency;
                           System.debug('enrolmnt.Enrollment_Date__c-->'+enrolmnt.Enrollment_Date__c);
                           subs.Subscription_Start_Date__c = enrolmnt.Enrollment_Date__c;
                       }
                       listSubsToInsert.add(subs);
                   }
            }
        }
        
        if(listSubsToInsert.size() > 0){
            listSubsToInsert = SubscriptionService.upsertSubscriptionRecords(listSubsToInsert);
            for(Subscription__c sub : listSubsToInsert){
                mapParentIdToSubscription.put(sub.Customer__c,sub);                
            }
        }
        
        if(mapEnrolIdToEnrollment.keySet().size() > 0 && mapParentIdToSubscription.keySet().size() > 0 &&
           mapClassToClassTerms.keySet().size() > 0){
               for(String key : mapEnrolIdToEnrollment.keySet()){
                   Enrollment__c enrolmnt = mapEnrolIdToEnrollment.get(key);
                   Class_Term__c nextClsTerm = new Class_Term__c();
                   Date currClsTrmStrtDate;
                   Date nextSchDt;
                   if(enrolmnt.Student_Sessions__r.size() > 0){
                       Integer stuSessSize = enrolmnt.Student_Sessions__r.size()-1;
                       currClsTrmStrtDate = enrolmnt.Student_Sessions__r[stuSessSize].Session__r.Class_Term__r.Start_Date__c;
                   }
                   
                   if(mapClassToClassTerms.containsKey(enrolmnt.Class__c) && currClsTrmStrtDate != NULL){
                       List<Class_Term__c> listClsTrm = mapClassToClassTerms.get(enrolmnt.Class__c);
                       for(Class_Term__c clsTrm : listClsTrm){
                           if(clsTrm.Start_Date__c > currClsTrmStrtDate){
                               nextClsTerm = clsTrm;
                               break;
                           }
                       }
                   }
                   
                   if(nextClsTerm != NULL){
                       String schUnit  = nextClsTerm.Class__r.Advance_Billing_Unit__c;
                       nextSchDt = nextClsTerm.Start_Date__c;
                       
                       if(String.isNotBlank(schUnit) && nextClsTerm.Class__r.Advance_Billing__c != null){
                           Integer advSchVal = Integer.valueOf(nextClsTerm.Class__r.Advance_Billing__c);
                           
                           if(schUnit.equalsIgnoreCase('Day(s)'))
                               nextSchDt = nextSchDt.addDays(-advSchVal);
                           else if(schUnit.equalsIgnoreCase('Week(s)'))
                               nextSchDt = nextSchDt.addDays(-(7*advSchVal));
                           else if(schUnit.equalsIgnoreCase('Month(s)'))
                               nextSchDt = nextSchDt.addMonths(-advSchVal);
                           
                           Subscription_Line_Item__c subsLnItem = new Subscription_Line_Item__c();
                           subsLnItem.Subscription__c  = (mapParentIdToSubscription.containsKey(enrolmnt.Parent__c) ? mapParentIdToSubscription.get(enrolmnt.Parent__c).Id : null);
                           subsLnItem.Enrollment__c    = key;
                           subsLnItem.Fee__c           = enrolmnt.Invoice_Line_Items__r[0].Fee__c;
                           subsLnItem.Status__c        = ConstantClass.activeStatus;
                           subsLnItem.Subscription_Start_Date__c = enrolmnt.Enrollment_Date__c;
                           subsLnItem.Class_Term__c     = nextClsTerm.Id;
                           subsLnItem.Next_Bill_Date__c = nextSchDt;
                           listSubsItem.add(subsLnItem);
                       }
                   }
               }
           }
        
        if(listStuSession.size() > 0){
            StudentSessionService.updateStudentSessionRecords(listStuSession);
        }

        if(listSubsItem.size() > 0)
            SubscriptionLineItemService.insertSubsLineItemRecords(listSubsItem);
    }
    
    public static Fee_Allocation__c fillFeeAllocation(Enrollment__c enrol, Invoice_Line_Item__c lnItm, Integer curMonthDays, Decimal tutionFeeAmt, Date currLesDt){
        Fee_Allocation__c fa = new Fee_Allocation__c();
        fa.Enrollment__c = enrol.Id;
        fa.Class__c = enrol.Class__c;
        fa.Course__c = enrol.Class__r.Course__c;
        fa.Actual_Revenue__c = tutionFeeAmt;
        fa.Invoice__c= lnItm.Invoice__c;
        fa.Invoice_Line_Item__c = lnItm.Id;
        fa.Allocated_Days__c = curMonthDays;
        fa.Month__c = Datetime.newInstance(currLesDt.year(),currLesDt.month(), currLesDt.day(), 0, 0,0).format('MMM');
        fa.Year__c = String.valueOf(currLesDt.year());
        return fa;
    }
}
