public with sharing class SM002_AccountMirrorManager {
    public static void manageMirroring(List<AccountMirror__c> newAccounts) {
        List<Account> mirroredAccounts = new List<Account>();

        for(AccountMirror__c acc : newAccounts) {
            Account mirror = (Account) U001_SObjectUtils.getMirroredSObject(acc);
            mirror.Id = acc.MirrorId__c;
            mirroredAccounts.add(mirror);
        }

        System.debug('###### mirroredAccounts : ' + mirroredAccounts);

        TM000_TriggerHandler.ByPassAllTriggers = true;
        upsert mirroredAccounts;
        TM000_TriggerHandler.ByPassAllTriggers = false;
    }
}
