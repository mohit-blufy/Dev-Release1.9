/*
* Author : Shubhi Saxena
* Date : 01/04/2020
*
* 
* Objects :-  Class__c, Class_Term__c,Term__c  
* Trigger Helper Class name : TermTriggerHelper
* Description : Creation of Class Term when term status changes to Open under Classes with open status & term frequency.
* */
trigger TermTrigger on Term__c (after update) { 
    
    if(trigger.isAfter && trigger.isUpdate){
        TermTriggerHelper.classTermCreation(trigger.New, trigger.oldMap);
    }
    
}