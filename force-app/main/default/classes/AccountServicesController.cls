public class AccountServicesController {
    public AccountServicesController() {

    }
    public static void excuteFuntions(){
        AccountServicesWithSharing accWithSharingObj = new AccountServicesWithSharing();
        AccountServicesWithoutSharing accWithoutSharingObj = new AccountServicesWithoutSharing();
       
        List<Account> newAccounts = new List<Account>();
        Account a1 = new Account(Name='Asif');
        Account b1 = new Account(Name='Blaze Comics', Rating='Warm');
        newAccounts.add(a1);
        newAccounts.add(b1);
        accWithSharingObj.insertAccountRecords(newAccounts);
        List<Account> accListWithSharing = accWithSharingObj.getAccountRecords();
        for(account acc : accListWithSharing){
            acc.phone = '0000000111';
        }
        accListWithSharing = accWithSharingObj.updateAccountRecords(accListWithSharing);
        accWithSharingObj.deleteAccountRecords(accListWithSharing);
        //======================= Without Sharing====================
        newAccounts = new List<Account>();
        Account a2 = new Account(Name='Asif1');
        Account b2 = new Account(Name='Blaze Comics1', Rating='Warm');
        newAccounts.add(a2);
        newAccounts.add(b2);

        accWithoutSharingObj.insertAccountRecords(newAccounts);
        List<Account> accListWithoutSharing = accWithoutSharingObj.getAccountRecords();
        
        for(account acc : accListWithoutSharing){
            acc.phone = '1245100111';
        }
        accListWithoutSharing = accWithoutSharingObj.updateAccountRecords(accListWithoutSharing);
        accWithoutSharingObj.deleteAccountRecords(accListWithoutSharing);
    }
}