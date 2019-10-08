/**
 * @author Amer Nassereldine
 * @created 10/09/2019
 * @description Trigger actions on AccountMirror__c Object
 */
trigger AccountMirrorTrigger on AccountMirror__c ( before insert, after insert,
									before update, after update,
									before delete, after delete ) {
    new TM002_AccountMirrorTriggerHandler().run();
}