public with sharing class SM001_AccountManager {
    public static void manageMirroring(List<Account> newAccounts) {
        List<AccountMirror__c> mirroredAccounts = new List<AccountMirror__c>();

        for(Account acc : newAccounts) {
            AccountMirror__c mirror = (AccountMirror__c) U001_SObjectUtils.getMirroredSObject(acc);
            mirror.MirrorId__c = acc.Id;
            mirroredAccounts.add(mirror);
        }

        System.debug('###### mirroredAccounts : ' + mirroredAccounts);

        TM000_TriggerHandler.ByPassAllTriggers = true;
        upsert mirroredAccounts MirrorId__c;
        TM000_TriggerHandler.ByPassAllTriggers = false;
    }
}
