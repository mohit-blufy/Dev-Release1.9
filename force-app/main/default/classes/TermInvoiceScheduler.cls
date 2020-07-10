global with sharing class TermInvoiceScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
     // mergeNumbers M = new mergeNumbers(); 
     Database.executeBatch(new InvoiceGeneratorBatch(System.today(),'Term'),100);
   }
}