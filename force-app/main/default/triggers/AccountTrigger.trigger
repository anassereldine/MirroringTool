/**
 * @author Amer Nassereldine
 * @created 10/09/2019
 * @description Trigger actions on Account Object
 */
trigger AccountTrigger on Account ( before insert, after insert,
									before update, after update,
									before delete, after delete ) {
    new TM001_AccountTriggerHandler().run();
}