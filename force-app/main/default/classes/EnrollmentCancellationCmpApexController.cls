/*
* Author : Shubhi Saxena
* Date : 09/04/2020
* 
*
* Objects : Account,Enrollment__c,Credit_Note__c,Payment__c,Invoice__c,Invoice_Line_Item__c,Subscription_Line_Item__c  
* Description : This class is used to cancel enrollement for all parents and process invoice if one enrolment is present corresponding to 
single parent.
*/

public class EnrollmentCancellationCmpApexController{
    
    @AuraEnabled
    public static WrapperClass doInitApex(String recordId){
        WrapperClass wrpcls = new WrapperClass();
        try{
            List<Account> listParentAccount = new List<Account>();
            
            /* *************** Query for getting Enrollment with enrolled status,invoice line item with type deposit 
* & subscription line item with active status ***************** */
            List<Enrollment__c> listEnrollment = EnrollmentService.getEnrollmentByIdForCancellation(recordId);
            if(listEnrollment != NULL && listEnrollment.size() > 0){
                Enrollment__c enrollment = listEnrollment[0];
                wrpCls.enrolId = enrollment.Id;
                wrpCls.enrolName = enrollment.Name;
                wrpCls.enrolClassId = enrollment.Class__c;
                wrpCls.enrolClassName = enrollment.Class__r.Name;
                wrpCls.enrolClassType = enrollment.Class__r.Type__c;
                wrpCls.enrolClassFreqncy = enrollment.Class__r.Frequency__c;
                wrpCls.enrolCancelResn = enrollment.Reason_for_Cancellation__c;
                wrpCls.enrolCancelComm = enrollment.Cancellation_Comments__c;
                wrpCls.enrolCanDate = Date.today();
                wrpCls.enrolEndDate = Date.today().addDays(Integer.valueOf(Label.EnrollCancelNoticeTime)); 
                wrpCls.enrolParent = enrollment.Parent__c;
                /* Query for getting count of total enrollments corresponding to parent of current enrollment with enrolled status 
* & all the credit notes corresponding to that parent */ 
                listParentAccount = AccountService.getEnrollmentByParentIdAlongWithEnrolId(wrpCls.enrolParent,recordId);
                
                if(listParentAccount.size() > 0){
                    if(listParentAccount[0].Enrollments1__r.size() > 0){
                        wrpCls.custEnrolCount = true;
                    }
                }
                
                //****Deposited amount is the amount present on invoice line item got from the query of deposit fee type.****
                if(enrollment.Invoice_Line_Items__r.size() > 0 && enrollment.Invoice_Line_Items__r[0].Amount__c != NULL)
                    wrpCls.depositedAmount = enrollment.Invoice_Line_Items__r[0].Amount__c;          
                
                /* *****************Calculation for unbilled amount **********************************
* Unit price of fee present Subscription Line Item * no. of student sessions betweeen next bill date of
* subscription line item & Enrollment end date
*/
                if(enrollment.Subscription_Line_Items__r.size() > 0 && enrollment.Subscription_Line_Items__r[0].Next_Bill_Date__c != NULL){
                    Date nextBillDate = enrollment.Subscription_Line_Items__r[0].Next_Bill_Date__c;
                    Date enrolEndDate = enrollment.Enrollment_End_Date__c;
                    wrpCls.subLineItemId =  enrollment.Subscription_Line_Items__r[0].Id;
                    if(enrollment.Subscription_Line_Items__r[0].Fee__r.Unit_Price__c != NULL){
                        Decimal feeUnitPrice = enrollment.Subscription_Line_Items__r[0].Fee__r.Unit_Price__c;
                        List<Student_Session__c> listStudentSession = StudentSessionService.getByEnrolDetails(recordId, nextBilldate, enrolEndDate);
                        if(listStudentSession != NULL && listStudentSession.size() > 0){
                            wrpCls.unBilledAmount = listStudentSession.size() * feeUnitPrice;
                        }
                    }
                }
                Schema.DescribeFieldResult canReasonField = Enrollment__c.Reason_for_Cancellation__c.getDescribe();
                List<Schema.PicklistEntry> picList= canReasonField.getPicklistvalues();
                for(Schema.PicklistEntry plist : picList){
                    wrpCls.picklistCanReasValues.add(plist.getLabel());
                }
                wrpCls.status = enrollment.Status__c;
            }
            wrpCls.message = 'SUCCESS'; 
            return wrpcls;
        }
        catch(Exception e){
            wrpcls.message = e.getMessage();
            return wrpCls;
        }
    }
    
    @AuraEnabled 
    public static String doProcessEnrolmentApex(String btnLabel,String wrpClsStr){
        try{
            WrapperClass wrpCls = (WrapperClass)System.JSON.deserialize(wrpClsStr, WrapperClass.class);
            String invoiceId = '';
            List<SObject> listSObjectToUpdate = new List<SObject>();
            
            //********************Creating credit note reord with deposited amount for both cases Process Invoice & Cancel Enrollment *************                   
            Enrollment__c enrolObj = new Enrollment__c();
            enrolObj.Id = wrpCls.enrolId;
            enrolObj.Cancellation_Date__c = wrpCls.enrolCanDate;
            enrolObj.Enrollment_End_Date__c = wrpCls.enrolEndDate;
            enrolObj.Cancellation_Comments__c = wrpCls.enrolCancelComm;
            enrolObj.Reason_for_Cancellation__c = wrpCls.enrolCancelResn;
            
            Payment__c payment = new Payment__c();
            payment.Parent__c = wrpCls.enrolParent;
            payment.Enrollment__c = wrpCls.enrolId;
            payment.Status__c = ConstantClass.pendingStatus;
            payment.Payment_Date__c = Date.today();
            payment.Amount__c = wrpCls.depositedAmount;
            PaymentService.insertPaymentRecords(new List<Payment__c>{payment});
            
            if(btnLabel == 'Process Invoice'){
                Invoice__c invoice = new Invoice__c();
                invoice.Customer__c = wrpCls.enrolParent;
                invoice.Status__c = ConstantClass.dueStatus;
                invoice.Invoice_Date__c = Date.today();
                invoice = InvoiceService.insertInvoiceRecords(new List<Invoice__c>{invoice})[0];
                invoiceId = invoice.Id;
                
                Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
                invLineItem.Invoice__c  = invoice.Id;
                invLineItem.Enrollment__c = wrpCls.enrolId;
                invLineItem.Type__c = ConstantClass.feeType;
                invLineItem.GST_Amount__c = 0;
                if(wrpCls.enrolClassType == ConstantClass.ongoingClsType && wrpCls.enrolClassFreqncy == ConstantClass.monthlyFrequency)
                    invLineItem.Amount__c = wrpCls.unBilledAmount;
                else if((wrpCls.enrolClassType == ConstantClass.fixedType) || (wrpCls.enrolClassType == ConstantClass.ongoingClsType && wrpCls.enrolClassFreqncy == ConstantClass.termFrequency))
                    invLineItem.Amount__c = 0.0;
                invLineItem  = InvoiceLineItemService.insertInvoiceLineItemRecords(new List<Invoice_Line_Item__c>{invLineItem})[0];
                enrolObj.Status__c = ConstantClass.cancelledStatus;
            }
            
            if(String.isNotBlank(wrpCls.subLineItemId)){
                Subscription_Line_Item__c subLineItem = new Subscription_Line_Item__c();
                subLineItem.Id = wrpCls.subLineItemId;
                subLineItem.Subscription_Expiry_Date__c = wrpCls.enrolEndDate;
                if(btnLabel == 'Process Invoice')
                    subLineItem.Status__c = ConstantClass.inActiveStatus;
                listSObjectToUpdate.add(subLineItem);
            }
            listSObjectToUpdate.add(enrolObj);
            
            if(listSObjectToUpdate.size() > 0)
                EnrollmentService.updateBySObjectList(listSObjectToUpdate);
            
            If(String.isNotBlank(invoiceId))
                return 'SUCCESS#'+invoiceId;
            else
                return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    public class WrapperClass{
        @AuraEnabled public String enrolId {get;set;}
        @AuraEnabled public String enrolName {get;set;}
        @AuraEnabled public String enrolClassId {get;set;}
        @AuraEnabled public String enrolClassName {get;set;}
        @AuraEnabled public String enrolClassType {get;set;}
        @AuraEnabled public String enrolClassFreqncy {get;set;}
        @AuraEnabled public String enrolCancelResn {get;set;}
        @AuraEnabled public String enrolCancelComm {get;set;}
        @AuraEnabled public Date enrolCanDate {get;set;}
        @AuraEnabled public Date enrolEndDate {get;set;}
        @AuraEnabled public String enrolParent {get;set;}
        @AuraEnabled public List<String> picklistCanReasValues{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public Decimal depositedAmount{get;set;}
        @AuraEnabled public Decimal unBilledAmount {get;set;}
        @AuraEnabled public Boolean custEnrolCount {get;set;}
        @AuraEnabled public String subLineItemId {get;set;}
        @AuraEnabled public String status {get;set;}
        
        public WrapperClass(){
            picklistCanReasValues = new List<String>(); 
            custEnrolCount = false;
            unBilledAmount = 0;
            depositedAmount = 0;
        }
    }
}