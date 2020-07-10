@isTest
public class InvoiceDetailControllerTest {    
    @testSetup
    static void testDataSetup(){
        BlufyTestUtil.init();        
    }
    
    public static testmethod void validateInvoiceDetailController(){ 
        List<Invoice__c> invList = [SELECT Id,Name FROM Invoice__c];
        System.debug('invList-->'+invList);
        
        if(invList.size() > 0){
            Apexpages.currentPage().getParameters().put('Id', invList.get(0).Id);
            InvoiceDetailController invDet= new InvoiceDetailController();
        }
        System.assertEquals(1, invList.size());
    }
}