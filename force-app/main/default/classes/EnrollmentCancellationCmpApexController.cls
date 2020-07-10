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
    Static Boolean isEnrollmentAccessible = FieldPremissionCrudUtility.checkReadPermission('Enrollment__c',new Set<String>{'Id','Name','Status__c','Enrollment_End_Date__c','Reason_for_Cancellation__c','Cancellation_Date__c', 
        'Cancellation_Comments__c','Class__c','Parent__c'},false);
    Static Boolean isClassAccessible = FieldPremissionCrudUtility.checkReadPermission('Class__c',new Set<String>{'Id','Name','Type__c','Frequency__c'},false);
    Static Boolean isInvLinItmAccessible = FieldPremissionCrudUtility.checkReadPermission('Invoice_Line_Item__c',new Set<String>{'Id','Amount__c','Type__c'},false);
    Static Boolean isSubLinItmAccessible = FieldPremissionCrudUtility.checkReadPermission('Subscription_Line_Item__c',new Set<String>{'Id','Next_Bill_Date__c','Subscription__c','Fee__c',
        'Subscription_Start_Date__c','Status__c'},false);
    Static Boolean isFeeAccessible = FieldPremissionCrudUtility.checkReadPermission('Fee__c',new Set<String>{'Id','Unit_Price__c'},false);
    //Static Boolean isCreditNoteAccessible = FieldPremissionCrudUtility.checkReadPermission('Credit_Note__c',new Set<String>{'Id','Name','Amount__c','Customer__c','Status__c','Date_Issued__c'},false);
    
    //Static Boolean isCreditNoteAccessibleForInstUpdte = FieldPremissionCrudUtility.checkReadPermission('Credit_Note__c',new Set<String>{'Amount__c','Customer__c','Status__c','Date_Issued__c','Comments__c'},true,false);
    Static Boolean isInvoiceAccessibleForInsrtUpdte = FieldPremissionCrudUtility.checkReadPermission('Invoice__c',new Set<String>{'Invoice_Date__c','Customer__c','Status__c'},true,false);
    Static Boolean isInvLinItmAccessibleForInsrtUpdte = FieldPremissionCrudUtility.checkReadPermission('Invoice_Line_Item__c',new Set<String>{'Amount__c','Type__c','Enrollment__c'},true,false);
    Static Boolean isSubLinItmAccessibleForInsrtUpdte = FieldPremissionCrudUtility.checkReadPermission('Subscription_Line_Item__c',new Set<String>{'Subscription_Expiry_Date__c'},true,false);
    Static Boolean isPaymentAccessibleForInsrtUpdte = FieldPremissionCrudUtility.checkReadPermission('Payment__c',new Set<String>{'Cash_Mode__c','Credit_Note__c','Payment_Date__c','Amount__c'},true,false);
    
    @AuraEnabled
    public static WrapperClass doInitApex(String recordId){
        WrapperClass wrpcls = new WrapperClass();
        try{
            List<Account> listParentAccount = new List<Account>();
            
            if(isEnrollmentAccessible && isClassAccessible && isInvLinItmAccessible && isSubLinItmAccessible && isFeeAccessible){
                /* *************** Query for getting Enrollment with enrolled status,invoice line item with type deposit 
* & subscription line item with active status ***************** */
                List<Enrollment__c> listEnrollment = [SELECT Id, Name,Status__c,Enrollment_End_Date__c,Reason_for_Cancellation__c,Cancellation_Date__c, 
                                                      Cancellation_Comments__c,Class__c,Parent__c,Class__r.Name,Class__r.Type__c,
                                                      Class__r.Frequency__c,
                                                      (SELECT Id,Amount__c FROM Invoice_Line_Items__r WHERE Type__c =: ConstantClass.depositFeeType),
                                                      (SELECT Id,Next_Bill_Date__c,Subscription__c,Fee__c,Fee__r.Unit_Price__c,
                                                       Subscription_Start_Date__c,Status__c
                                                       FROM Subscription_Line_Items__r WHERE Status__c =: ConstantClass.activeStatus)    
                                                      FROM Enrollment__c 
                                                      WHERE Id =: recordId AND Status__c =: ConstantClass.enrolledStatus LIMIT 1];
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
                    listParentAccount = [SELECT Id,(SELECT Id FROM Enrollments1__r WHERE Status__c =: ConstantClass.enrolledStatus
                                                    AND Id !=: recordId)
                                         //  (SELECT Id,Name,Amount__c,Customer__c,Status__c,Date_Issued__c FROM Credit_Notes__r
                                         //    WHERE Status__c =: ConstantClass.issuedStatus)
                                         FROM Account WHERE Id =:wrpCls.enrolParent];
                    
                    if(listParentAccount.size() > 0){
                        if(listParentAccount[0].Enrollments1__r.size() > 0){
                            wrpCls.custEnrolCount = true;
                        }
                        
                        // if(listParentAccount[0].Credit_Notes__r.size() > 0)
                        //     wrpCls.listCreditNote = listParentAccount[0].Credit_Notes__r;
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
                            List<Student_Session__c> listStudentSession = [SELECT Id,Name FROM Student_Session__c WHERE Enrollment__c =: recordId 
                                                                           AND Session_Date__c >= :nextBillDate AND Session_Date__c <=: enrolEndDate];
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
            }
            else
                wrpCls.message = 'FLS NOT FOUND';
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
            List<SObject> listSObjectToInsert = new List<SObject>();
            List<SObject> listSObjectToUpdate = new List<SObject>();
            
            if(isInvoiceAccessibleForInsrtUpdte && isInvLinItmAccessibleForInsrtUpdte && 
               isSubLinItmAccessibleForInsrtUpdte && isPaymentAccessibleForInsrtUpdte){
                   //********************Creating credit note reord with deposited amount for both cases Process Invoice & Cancel Enrollment *************
                   /* Credit_Note__c creditNote = new Credit_Note__c();
creditNote.Amount__c = wrpCls.depositedAmount;
creditNote.Customer__c = wrpCls.enrollment.Parent__c;
creditNote.Date_Issued__c = Date.today();
creditNote.Status__c = ConstantClass.issuedStatus;
creditNote.Comments__c = 'Deposit Adjustment';
insert creditNote;*/
                   
                   Enrollment__c enrolObj = new Enrollment__c();
                   enrolObj.Id = wrpCls.enrolId;
                   enrolObj.Cancellation_Date__c = wrpCls.enrolCanDate;
                   enrolObj.Enrollment_End_Date__c = wrpCls.enrolEndDate;
                   enrolObj.Cancellation_Comments__c = wrpCls.enrolCancelComm;
                   enrolObj.Reason_for_Cancellation__c = wrpCls.enrolCancelResn;
                   
                   Payment__c payment = new Payment__c();
                   //payment.Cash_Mode__c = ConstantClass.creditNoteCashMode;
                   payment.Parent__c = wrpCls.enrolParent;
                   payment.Enrollment__c = wrpCls.enrolId;
                   payment.Status__c = ConstantClass.pendingStatus;
                   payment.Payment_Date__c = Date.today();
                   payment.Amount__c = wrpCls.depositedAmount;
                   listSObjectToInsert.add(payment);
                   
                   if(btnLabel == 'Process Invoice'){
                       Invoice__c invoice = new Invoice__c();
                       invoice.Customer__c = wrpCls.enrolParent;
                       invoice.Status__c = ConstantClass.dueStatus;
                       invoice.Invoice_Date__c = Date.today();
                       insert invoice;
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
                       insert invLineItem;
                       
                       /*  if(wrpCls.enrollment.Class__r.Type__c == ConstantClass.ongoingClsType && wrpCls.enrollment.Class__r.Frequency__c == ConstantClass.monthlyFrequency){
wrpCls.listCreditNote.add(creditNote);
if(wrpCls.listCreditNote.size() > 0){
for(Credit_Note__c crNote : wrpCls.listCreditNote){

}
}
}*/
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
                   
                   if(listSObjectToInsert.size() > 0)
                       insert listSObjectToInsert;
                   
                   if(listSObjectToUpdate.size() > 0)
                       update listSObjectToUpdate;
                   
                   If(String.isNotBlank(invoiceId))
                       return 'SUCCESS#'+invoiceId;
                   else
                       return 'SUCCESS';
               }
            else
                return 'FLS NOT FOUND';
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
        // @AuraEnabled public List<Credit_Note__c> listCreditNote{get;set;}
        @AuraEnabled public Decimal depositedAmount{get;set;}
        @AuraEnabled public Decimal unBilledAmount {get;set;}
        @AuraEnabled public Boolean custEnrolCount {get;set;}
        @AuraEnabled public String subLineItemId {get;set;}
        @AuraEnabled public String status {get;set;}
        
        public WrapperClass(){
            picklistCanReasValues = new List<String>(); 
            //   listCreditNote = new List<Credit_Note__c>();
            custEnrolCount = false;
            unBilledAmount = 0;
            depositedAmount = 0;
        }
    }
}