/*
	Name		: 	IBlufyInvoiceEngine
	Date		:	03/23/2020
	Author		:	Arpit vijayvergiya
	Description :	This interface is parent for all the invoice handlers.
*/

/*public Interface IBlufyInvoiceEngine {
    List<Invoice_Line_Item__c> createInvoiceLineItems(Invoice__c objInv,LineItemCalculateWrapper objWrap);
}*/

public Abstract class IBlufyInvoiceEngine{
    public Subscription_Line_Item__c objLineItem;
	public Abstract List<Invoice_Line_Item__c> createInvoiceLineItems(Invoice__c objInv,LineItemCalculateWrapper objWrap);
}