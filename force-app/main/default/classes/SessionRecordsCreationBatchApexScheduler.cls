global with sharing class SessionRecordsCreationBatchApexScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
     Database.executeBatch(new SessionRecordsCreationBatchApex(), 50);
   }
}