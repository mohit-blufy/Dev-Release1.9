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
