public with sharing class DevAutomaterController {
    
    @AuraEnabled
    public static string updateApex(String body){
        try {
            String respose = ConfigureMetadataServiceClass.updateApex('01p5i00000WKLSQAA5', body);
            return respose;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}