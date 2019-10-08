/**
 * @author Amer Nassereldine
 * @created 15/07/2019
 * @description Trigger action handler on Account Mirror Object
 */
public with sharing class TM002_AccountMirrorTriggerHandler extends TM000_TriggerHandler {
    
    private Map<Id, AccountMirror__c> newAccountMirrors;
	private Map<Id, AccountMirror__c> oldAccountMirrors;

	private List<AccountMirror__c> newAccountMirrorsList;
	private List<AccountMirror__c> oldAccountMirrorsList;

	public TM002_AccountMirrorTriggerHandler() {
		newAccountMirrors = (Map<Id, AccountMirror__c>) Trigger.newMap;
		oldAccountMirrors = (Map<Id, AccountMirror__c>) Trigger.oldMap;

		newAccountMirrorsList = (List<AccountMirror__c>) Trigger.new;
		oldAccountMirrorsList = (List<AccountMirror__c>) Trigger.old;
	}

	//execute After Insert processes 
	protected override void afterInsert() {
        SM002_AccountMirrorManager.manageMirroring(newAccountMirrorsList);
	}
    
    //execute After Update processes 
	protected override void afterUpdate() {
        SM002_AccountMirrorManager.manageMirroring(newAccountMirrorsList);
	}
}