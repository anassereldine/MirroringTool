/**
 * @author Amer Nassereldine
 * @created 15/07/2019
 * @description Trigger action handler on Account Object
 */
public with sharing class TM001_AccountTriggerHandler extends TM000_TriggerHandler {
    
    private Map<Id, Account> newAccounts;
	private Map<Id, Account> oldAccounts;

	private List<Account> newAccountsList;
	private List<Account> oldAccountsList;

	public TM001_AccountTriggerHandler() {
		newAccounts = (Map<Id, Account>) Trigger.newMap;
		oldAccounts = (Map<Id, Account>) Trigger.oldMap;

		newAccountsList = (List<Account>) Trigger.new;
		oldAccountsList = (List<Account>) Trigger.old;
	}

	//execute After Insert processes 
	protected override void afterInsert() {
        SM001_AccountManager.manageMirroring(newAccountsList);
	}
    
    //execute After Update processes 
	protected override void afterUpdate() {
        SM001_AccountManager.manageMirroring(newAccountsList);
	}
}