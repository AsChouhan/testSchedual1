public with sharing class ConfigureMetadataUsingTooling {
    public static String sessionId = '00D5i00000EUVZA!AQ8AQJb_QImWnrVEBl9bxC6AfooiosEhLdqzkQDl6rEvDeFq4lE0TWk.zvEtD8gMlIVOyKFKKefNjaOGSHv575xcPn0SqU.P';
    
    
    // classMetadata contains class name and class body for deploy..
    // sameple classMetadata = '{"name":"aasheesh","body":"public class aasheesh{public String name = \'bhanu\';}"}'
    public static void createApexClass(String classMetadata){
        ConfigureMetadataWrapper.createApexWrapper meta = (ConfigureMetadataWrapper.createApexWrapper)System.JSON.deserialize(classMetadata, ConfigureMetadataWrapper.createApexWrapper.class);
        Map<String, String> headers = new Map<String, String>();
        String endPoint = 'callout:salesforce_named_credential/services/data/v36.0/tooling/sobjects/ApexClass';
        String body = '{"Name": "'+meta.name+'","Body" : "'+meta.body+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json'); 
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('POST',endPoint, body);
        SYstem.debug(res.getBody());
    }
    
    // Update apex class...   
    
    public static String getIdFromJson(String jsonString){
        system.debug(jsonString);
        JSONParser parser = JSON.createParser(jsonString);
        System.JSONToken jt;        
        while (parser.nextToken() != null) {   
            if(parser.getCurrentToken()==JSONToken.FIELD_NAME && parser.getText() == 'id'){
                jt = parser.nextToken();       
            }   
            if(jt== parser.getCurrentToken()){
                System.debug(parser.getText());
                return parser.getText();
            }
        }
        return 'MetadataContainor not found';
    }
    
    //Create metadata containor ...
    public static String createMetadataContainor(){
        String endPoint = 'callout:salesforce_named_credential/services/data/v36.0/tooling/sobjects/MetadataContainer';
        String body = '{"Name":"TestContainer"}';
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('POST', endPoint, body);
        return getIdFromJson(res.getBody());   
    }
    
    //Ganreting metadata containor id...
    public static String getMetadataContainer(String oldContainorName){ 
        if(oldContainorName != 'no containor found'){ 
            System.debug('inside deleting containor...');
            //Deleting and creating containor...
            String endPoint = 'callout:salesforce_named_credential/services/data/v36.0/tooling/sobjects/MetadataContainer/'+oldContainorName;                   
            HttpResponse res = ConfigureMetadataServiceClass.getResponse('DELETE', endPoint, '');
            System.debug(res.getBody());
        }
        return createMetadataContainor();
    }
    
    public static String getOldContainorId(String containorName){
        String endPoint = 'callout:salesforce_named_credential/services/data/v36.0/tooling/query/?q=select+id+from+MetadataContainer+where+name=\''+containorName+'\'';
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('GET', endPoint, '');
        if(res.getStatusCode() == 200){
            System.debug(getIdFromJson(res.getBody()));
            return getIdFromJson(res.getBody());
        }      
        return 'no containor found';
    }
    
    // Ganreting apex class mamber id...
    public static String createApexClassMember(String apexClassMetadata){
        SYstem.debug('apex class member...   ');
        ConfigureMetadataWrapper.UpdateApexWrapper meta = (ConfigureMetadataWrapper.UpdateApexWrapper)System.JSON.deserialize(apexClassMetadata, ConfigureMetadataWrapper.UpdateApexWrapper.class);
        HttpRequest req = new HttpRequest();
        //Metadata container Id...
        String oldContainorId = getOldContainorId('TestContainer');
        System.debug('old containor-> '+ oldContainorId);
        String MetadataContainerId = getMetadataContainer(oldContainorId);
        System.debug('new metadatacon. Id -> '+MetadataContainerId);
        Map<String, String> headers = new Map<String, String>();
        String endPoint = 'callout:salesforce_named_credential/services/data/v36.0/tooling/sobjects/ApexClassMember';
        String body = '{"ContentEntityId":"'+meta.id+'","MetadataContainerId":"'+MetadataContainerId+'","Body":"'+meta.body+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('POST',endPoint, body);
        SYstem.debug(res.getBody());
        return MetadataContainerId;
    }
    
    // apexMetadata contains apexClass Id and body(updated code)...   
    // sample apexMetadata = '{"id":"01p5i00000WKLSQAA5","body":"public class aasheesh{public String name = \'aasheesh singh chouhan\';}"}'
    public static void updateApex(String apexMetadata){
        System.debug('update apex called');
        String metadataContainerId = createApexClassMember(apexMetadata);
        System.debug(metadataContainerId);
        Map<String, String> headers = new Map<String, String>();
        String endPoint = 'callout:salesforce_named_credential/services/data/v36.0/tooling/sobjects/ContainerAsyncRequest';
        String body = '{ "IsCheckOnly": "false","MetadataContainerId":"'+metadataContainerId+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('POST',endPoint, body);
        SYstem.debug(res.getBody());
    }   
    
    
    // Lwc Configuration methods....
    // Sample lwcComponentMetadata = '{ "fullName": "CommName", "description" : "description123", "masterLabel": "masterLabel123", "target" : [ "lightning__RecordPage", "lightning__AppPage", "lightning__HomePage" ] }';
    
    public static void createLwcComponent(String lwcComponentMetadata){   
        ConfigureMetadataWrapper.LwcMetaWrapper meta = (ConfigureMetadataWrapper.LwcMetaWrapper)System.JSON.deserialize(lwcComponentMetadata, ConfigureMetadataWrapper.LwcMetaWrapper.class);
        String targ =  '"targets": {"target": '+JSON.serialize(meta.target)+'}';
        targ = targ.replace('(','[').replace(')',']');
        String body = '{"FullName":"'+meta.fullName+'","Metadata":{"apiVersion":48,"description": "'+meta.description+'","isExplicitImport": false,"isExposed": true,"masterLabel": "'+meta.masterLabel+'",'+targ+'}}';
        
        Map<String, String> headers = new Map<String, String>();
        String endPoint = 'callout:salesforce_named_credential/services/data/v49.0/tooling/sobjects/LightningComponentBundle';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('POST',endPoint, body);
        system.debug(res.getBody());
        
        JSONParser parser = JSON.createParser(res.getBody());
        System.JSONToken jt;
        String bundleId;
        while (parser.nextToken() != null) {   
            if(parser.getCurrentToken()==JSONToken.FIELD_NAME && parser.getText() == 'id'){
                jt = parser.nextToken();       
            }   
            if(jt== parser.getCurrentToken()){
                bundleId = parser.getText();
                
                System.debug(bundleId);
            }
        }       
    }
    
    public static void insertSourceToLwcComponent(String lwcInsertMetadata){
        ConfigureMetadataWrapper.LwcInsertWrapper meta = (ConfigureMetadataWrapper.LwcInsertWrapper)System.JSON.deserialize(lwcInsertMetadata, ConfigureMetadataWrapper.LwcInsertWrapper.class);
        String path = 'lwc/'+meta.devloperName+'/'+meta.devloperName+'.'+meta.formate;
        String body = '{"FilePath": "'+path+'","LightningComponentBundleId":"'+meta.componentId+'","Format":"'+meta.formate+'", "Source" : "' + meta.sourceCode + '"}';
        System.debug(body);
        
        Map<String, String> headers = new Map<String, String>();
        String endPoint = 'callout:salesforce_named_credential/services/data/v49.0/tooling/sobjects/LightningComponentResource';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('POST',endPoint, body);
        system.debug(res.getBody());
    }    
    
    
    //sample lwcResouceMetadata = '{"sourceFileId":"0Rd5i000005rUHACA2","source":"<template><p>aasheesh singh chouhan</p></template>"}';
    //sourceFileId = html file id retreve using tooling query.
    public static String updateLwcResource(String LWC_ID, String source){   
        Map<String, String> headers = new Map<String, String>();
        String body = '{"Source" : "' + source + '"}';
        String endPoint = 'callout:salesforce_named_credential/services/data/v49.0/tooling/sobjects/LightningComponentResource/'+LWC_ID;
        headers.put('Authorization', 'Bearer '+UserInfo.getSessionId());
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('PATCH',endPoint, body);
        while (res.getStatusCode() == 302) {
            System.debug('inside 302');
            endPoint = res.getHeader('Location');
            res = ConfigureMetadataServiceClass.getResponse('PATCH',endPoint, body);
        }
        System.debug(res.getStatusCode());
        system.debug(res.getBody());
        return res.getBody();
    }    
}