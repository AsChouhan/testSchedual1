public without sharing class ConfigureMetadataServiceClass {
    static final String LWCR_TOOLING_ENDPOINT = '/services/data/v49.0/tooling/sobjects/LightningComponentResource/';
    static final String TOOLING_QUERY_ENDPOINT = '/services/data/v49.0/tooling/query/';
    static final String LWCR_QUERY = '?q=select+id,source,format,lightningComponentBundleId+from+LightningComponentResource+where+lightningComponentBundleId=\'{ID}\'';
    static final String SOURCE = 'Source';
    static final String PATCH = 'PATCH';

    //sample lwcResouceMetadata = '{"sourceFileId":"0Rd5i000005rUHACA2","source":"<template><p>aasheesh singh chouhan</p></template>"}';
    //sourceFileId = html file id retreve using tooling query.
    public static String updateLwcResource(String LWC_ID, String source){   
        Map<String, String> headers = new Map<String, String>();
        Map<String,Object> bodyMap = new Map<String,Object>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm() + LWCR_TOOLING_ENDPOINT + LWC_ID;
        bodyMap.put( SOURCE, source);
        String body = JSON.serialize(bodyMap);
        HttpResponse res = getResponse(PATCH, endPoint, body);
        return res.getBody();
    }
    
    public static String getLWC(String LWC_ID, String source){   
        Map<String, String> headers = new Map<String, String>();
        Map<String,Object> bodyMap = new Map<String,Object>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm() + TOOLING_QUERY_ENDPOINT + LWC_ID;
        bodyMap.put( SOURCE, source);
        String body = JSON.serialize(bodyMap);
        HttpResponse res = getResponse(PATCH, endPoint, body);
        return res.getBody();
    }

   

    // apexMetadata contains apexClass Id and body(updated code)...   
    // sample apexMetadata = '{"id":"01p5i00000WKLSQAA5","body":"public class aasheesh{public String name = \'aasheesh singh chouhan\';}"}'
    public static String updateApex(String Id, String body){
        String metadataContainerId = createApexClassMember(Id, body);
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ContainerAsyncRequest';
        String reqBody = '{ "IsCheckOnly": "false","MetadataContainerId":"'+metadataContainerId+'"}';
       
        HttpResponse res = getResponse('POST',endPoint, reqBody);
        SYstem.debug(res.getBody());
        return res.getBody();
    }

     // Ganreting apex class mamber id...
     public static String createApexClassMember(String Id, String body){
        HttpRequest req = new HttpRequest();
        //Metadata container Id...
        String MetadataContainerId = getMetadataContainer();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ApexClassMember';
        String reqBody = '{"ContentEntityId":"'+Id+'","MetadataContainerId":"'+MetadataContainerId+'","Body":"'+body+'"}';
        
        HttpResponse res = getResponse('POST',endPoint, reqBody);
        SYstem.debug(res.getBody());
        return MetadataContainerId;
    }

    //Ganreting metadata containor id...
    public static String getMetadataContainer(){ 
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/query/?q=select+id+from+MetadataContainer+where+name=\'myContainor\'';

        HttpResponse res = getResponse('GET', endPoint, '');
        SYstem.debug(res.getBody());        
        
        //Getting container id.
        JSONParser parser = JSON.createParser(res.getBody());
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
        return null;
    }

    
    
    public static HttpResponse getResponse(String methodName, String endPoint, String body){
        HttpRequest req = new HttpRequest();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Authorization', 'Bearer '+ToolingApiService.RECEIVER_ACCESS_TOKEN);
        headers.put('Content-Type', 'application/json');
        req.setEndpoint(endPoint);
        for(String st : headers.keySet()){
            req.setHeader(st,  headers.get(st));
        }       
        req.setMethod(methodName);
        if(body != ''){
            req.setBody(body);
        }
        Http ht = new Http();
        HttpResponse res = ht.send(req);
        if (res.getStatusCode() == 302) {
            System.debug('inside 302');
            endPoint = res.getHeader('Location');
            res = getResponse(methodName, endPoint, body);
        }
        return res;
    }
}