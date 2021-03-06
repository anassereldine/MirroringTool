/**
 * @author Amer Nassereldine
 * @created 09/10/2019
 * @description Utility Class for SOBjects
 */
public with sharing class U001_SObjectUtils {

    //Used to cash request
    public static List<CloneSetting__mdt> globalCloneSettings = null;

    //Used to cash request
    public static Map<String, Schema.SObjectField> globalUpdatebleField = null;

    //Used to cash request
    public static Set<String> globalAllFields = null;

    //Used to cash request
    public static Set<String> fieldDeveloperNameFromFieldSet = null;

    // Get Cloning Settings from salesforce custom metadata
    public static List<CloneSetting__mdt> getCloneSettings(String sobjectType){
        if(globalCloneSettings == null) {
            globalCloneSettings = [SELECT DeveloperName, ClonedInto__c, RestrictedFields__c FROM CloneSetting__mdt WHERE Label =:sobjectType];
        }
        
        return globalCloneSettings;
    }
    
    /**
     * @author Amer Nassereldine
     * @created 09/10/2019
     * @description create a mirror object for the sObject passed in parameters
     * @param SObject toClone: the sObject to clone (mirror)
     * @return result sObject with the same fields as the entry
     */
    public static SObject getMirroredSObject(SObject toClone) {
        //Get the name of the SObject
        String sobjectType = toClone.getSObjectType().getDescribe().getName();

        List<CloneSetting__mdt> cloneSettings = getCloneSettings(sobjectType);//[SELECT DeveloperName, ClonedInto__c, RestrictedFields__c FROM CloneSetting__mdt WHERE DeveloperName =:sobjectType];
        System.debug('#### cloneSettings : ' + cloneSettings);

        CloneSetting__mdt config = null;

        if(cloneSettings != null && cloneSettings.size()>0) {
            config = cloneSettings.get(0);
        } else {
            throw new MissingConfigurationException('No configuration to mirror object [' + sobjectType + '].');
        }

        SObject result;
        if(config.RestrictedFields__c != null) {
            result = restrictedMirroringTreatment(toClone, sobjectType, config);
        } else {
            result = fullMirroringTreatment(toClone, sobjectType, config);
        }

        return result;
        //Get all the field updateable fields

    }

    /**
     * @author Amer Nassereldine
     * @created 09/10/2019
     * @description Perform full mirroring for all updateable fields. Matching fields will be filled.
     * @param SObject toClone: the sObject to clone (mirror)
     * @param String sobjectType: the type of the sObject to clone
     * @param CloneSetting__mdt setting: the cloning settings
     * @return result sObject with the same fields as the entry
     */
    private static SObject fullMirroringTreatment(SObject toClone, String sobjectType, CloneSetting__mdt setting) {
        Map<String,Schema.SObjectField> mfields = getUpdateableFields(sobjectType);
        
        return constructTargetSObject(mfields.KeySet(), toClone, sObjectType, setting);
    }

    /**
     * @author Amer Nassereldine
     * @created 09/10/2019
     * @description Perform restricted mirroring for all updateable fields. Matching fields will be filled. (this
     * mirroring option is based on a Salesforce fieldset containing the fields to mirror)
     * @param SObject toClone: the sObject to clone (mirror)
     * @param String sobjectType: the type of the sObject to clone
     * @param CloneSetting__mdt setting: the cloning settings
     * @return result sObject with the same fields as the entry
     */
    private static SObject restrictedMirroringTreatment(SObject toClone, String sObjectType, CloneSetting__mdt setting) {

        Set<String> fields = getFieldDeveloperNameFromFieldSet(setting.RestrictedFields__c, sobjectType);

        return constructTargetSObject(fields, toClone, sObjectType, setting);

    }

    /**
     * @author Amer Nassereldine
     * @created 09/10/2019
     * @description Utility method to construct the target mirrored object based on a set of fields to mirror
     * @param Set<String> fields: fields to mirror
     * @param SObject toClone: the sObject to clone (mirror)
     * @param String sobjectType: the type of the sObject to clone
     * @param CloneSetting__mdt setting: the cloning settings
     * @return result sObject with the same fields as the entry
     */
    private static SObject constructTargetSObject(Set<String> fields, SObject toClone, String sObjectType, CloneSetting__mdt setting) {

        // String query = constructQueryToGetAllField(fields, (String)toClone.get('Id'), sObjectType);

        // List<SObject> requestedObjects = Database.query(query);
        
        // if(requestedObjects == null || requestedObjects.size() ==0) {
        //     throw new MissingValueException('The object to mirror was not found');
        // }

        // SObject requestedObject = requestedObjects.get(0);

        SObject requestedObject = toClone;

        String targetSObjectType = setting.ClonedInto__c;

        sObject sObj = Schema.getGlobalDescribe().get(targetSObjectType).newSObject();

        Set<String> allTargetSObjectFields = getAllFields(targetSObjectType);

        for(String field : fields) {
            if(!field.contains('__c')) {
                if(allTargetSObjectFields.contains(field)) {
                    sObj.put(field, requestedObject.get(field));
                } else {
                    String potentialField = field + '__c';
                    if(allTargetSObjectFields.contains(potentialField)) {
                        sObj.put(potentialField, requestedObject.get(field));
                    } else {
                        //throw new MissingFieldException('The Field [' + field + '] was not found in the target object');
                    }
                }
            } else {
                if(allTargetSObjectFields.contains(field)) {
                    sObj.put(field, requestedObject.get(field));
                } else {
                    String potentialField = field.replace('__c', '');
                    if(allTargetSObjectFields.contains(potentialField)) {
                        sObj.put(potentialField, requestedObject.get(field));
                    } else {
                        //throw new MissingFieldException('The Field [' + field + '] was not found in the target object');
                    }
                }
            }
        }

        return sObj;
    }

    // private static String constructQueryToGetAllField(Set<String> fields, String id, String sObjectType) {
    //     String query = 'SELECT ';

    //     if(!fields.contains('Id')) {
    //         query += 'Id, ';
    //     }

    //     for(String f : fields) {
    //         query += f + ', ';
    //     }

    //     query = replaceLast(query, ', ', '');

    //     query += ' FROM ' + sObjectType + ' WHERE Id = \'' + id + '\'';

    //     System.debug('#### query : ' + query);

    //     return query;
    // }


    /**
     * @author Amer Nassereldine
     * @created 09/10/2019
     * @description Utility method to get the updateable fields from a given sObject type
     * @param String sobjectName: the type of the sObject to process
     * @return Map<String, Schema.SObjectField> map of the updateable fields by field Name
     */
    public static Map<String, Schema.SObjectField> getUpdateableFields(String sobjectName) {

        if(globalUpdatebleField == null) {
            Map<String, Schema.SObjectField> result = new Map<String, Schema.SObjectField>();

            SObjectType accountType = Schema.getGlobalDescribe().get(sobjectName);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();

            for(String fieldName : mfields.KeySet()) {
                if(mfields.get(fieldName).getDescribe().isUpdateable())
                result.put(fieldName, mfields.get(fieldName));
            }
            globalUpdatebleField = result;
            return result;
        } else {
            return globalUpdatebleField;
        }
        
    }

    /** 
     * @author Amer Nassereldine
     * @created 09/10/2019
     * @description Utility method to get all fields from a given sObject type
     * @param String sobjectName: the type of the sObject to process
     * @return Map<String, Schema.SObjectField> map of all fields by field Name
     */
    public static Set<String> getAllFields(String sobjectName) {
        if(globalAllFields == null) {
            Set<String> result = new Set<String>();

            SObjectType accountType = Schema.getGlobalDescribe().get(sobjectName);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();

            for(String fieldName : mfields.KeySet()) {
                result.add(fieldName);
            }
            
            globalAllFields = result;
            return result;
        } else {
            return globalAllFields;
        }
    }


    /**
     * @author Amer Nassereldine
     * @created 08/07/2019
     * @description get field set field members.
     * @param String fieldSetName: the name of the fieldset
     * @param String ObjectName: The name of the field where the fieldset was created
     * @return N/A
     */
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        return fieldSetObj.getFields(); 
    }


    public static Set<String> getFieldDeveloperNameFromFieldSet(String fieldSetName, String objectName) {
        if(fieldDeveloperNameFromFieldSet == null) {
            List<Schema.FieldSetMember> fsMembers = readFieldSet(fieldSetName, objectName);

            Set<String> result = new Set<String>();

            for(Schema.FieldSetMember fm : fsMembers) {
                result.add(fm.getFieldPath());
            }
            fieldDeveloperNameFromFieldSet = result;
            return result;
        } else {
            return fieldDeveloperNameFromFieldSet;
        }
    }

    /**
     * @author Amer Nassereldine
     * @created 08/07/2019
     * @description Invockable method to process lead assignation
     * @param Id Lead identifier
     * @return N/A
     */
    public static String replaceLast(String input, String substring, String replacement) {
        
        Integer index = input.lastIndexOf(substring);
        if (index == -1) {
            return input;
        }

        return input.substring(0, index) + replacement
                + input.substring(index+substring.length());

    }


    public class MissingConfigurationException extends Exception{}
    public class MissingFieldException extends Exception{}
    public class MissingValueException extends Exception{}
}
