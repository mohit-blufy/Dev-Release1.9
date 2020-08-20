/*
* Author : Shubhi Saxena
* Date : 01/04/2020
* 
*
* Objects : Class__c, Class_Term__c,Term__c  
* Trigger : TermTrigger
* Description : Creation of Class Term when term status changes to Open under Classes with open status & term frequency.
*/

public class TermTriggerHelper {
    public static void classTermCreation(List<Term__c> triggerNew,Map<Id,Term__c> oldMap){
        Map<String,Term__c> mapTermIdToTerm = new Map<String,Term__c>();
        List<Class__c> listClass = new List<Class__c>();
        List<Class_Term__c> listClassTerm = new List<Class_Term__c>();
        
        for(Term__c term :triggerNew){
            if(String.isNotBlank(term.Status__c) && oldMap.get(term.Id).Status__c.equalsIgnoreCase(ConstantClass.draftStatus) 
               && term.Status__c.equalsIgnoreCase(ConstantClass.termOpenStatus)){
                   mapTermIdToTerm.put(term.Id,term);
               }
        }
        
        if(mapTermIdToTerm.keySet().size() > 0){
            //*********Fetching classes with open status & term frequency *********************// 
            listClass = [SELECT Id FROM Class__c WHERE Status__c =: ConstantClass.clsOpenStatus AND Frequency__c =: ConstantClass.termFrequency];
            if(listClass.size() > 0){
                for(Class__c classRec: listClass){
                    for(String key : mapTermIdToTerm.keySet()){
                        listClassTerm.add(createClassTerm(mapTermIdToTerm.get(key),classRec.Id));
                    }
                }
            }
        }
        
        if(listClassTerm.size() > 0)
            ClassTermService.insertClassTermRecords(listClassTerm);
        
    }
    
    //**********Class Term creation when Term status changes from Draft To Open***********//
    public static Class_Term__c createClassTerm(Term__c term,String classId){
        Class_Term__c classTerm = new Class_Term__c();
        classTerm.put('Name', term.Name);
        classTerm.put('Class__c', classId);
        classTerm.put('Status__c', ConstantClass.draftStatus);
        classTerm.put('Start_Date__c', term.Start_Date__c);
        classTerm.put('End_Date__c', term.End_Date__c);
        classTerm.put('Sessions__c', term.Sessions__c);
        classTerm.put('Sequence__c', term.Sequence__c);
        classTerm.put('Term__c', term.Id);
        return classTerm;
    }
}