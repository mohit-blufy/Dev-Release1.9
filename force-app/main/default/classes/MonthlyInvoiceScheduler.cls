global with sharing class MonthlyInvoiceScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
     // mergeNumbers M = new mergeNumbers(); 
     Database.executeBatch(new InvoiceGeneratorBatch(System.today(),'Month'),100);
   }
}