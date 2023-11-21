public with sharing class ConfigureApexUsingTooling {

    public static String sessionId = '00D5i00000EUVZA!AQ8AQB9XF7T2Se8PQ4TfqtskJnm2e5lDOC47tRCbKUn1QCoupMD0qK9KDhI8xmVeTw7s4Fsed0VbYp.AQO8ajXV3wyoMK_MH';

    // classMetadata contains class name and class body for deploy..
    // sameple classMetadata = '{"name":"aasheesh","body":"public class aasheesh{public String name = \'bhanu\';}"}'
    public static void createApexClass(String classMetadata){
        ConfigureMetadataWrapper.createApexWrapper meta = (ConfigureMetadataWrapper.createApexWrapper)System.JSON.deserialize(classMetadata, ConfigureMetadataWrapper.createApexWrapper.class);
        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ApexClass';
        String body = '{"Name": "'+meta.name+'","Body" : "'+meta.body+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfidMetadataSeviceClass.getRresponse('POST',endPoint, headers, body);
        SYstem.debug(res.getBody());
    }
    
    // Update apex class...   
    
    //Ganreting metadata containor id...
    public static String getMetadataContainer(){ 
        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/query/?q=select+id+from+MetadataContainer+where+name=\'myContainor\'';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfidMetadataSeviceClass.getRresponse('GET',endPoint, headers, '');
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

    // Ganreting apex class mamber id...
    public static String createApexClassMember(String apexClassMetadata){
        ConfigureMetadataWrapper.UpdateApexWrapper meta = (ConfigureMetadataWrapper.UpdateApexWrapper)System.JSON.deserialize(apexClassMetadata, ConfigureMetadataWrapper.UpdateApexWrapper.class);
        HttpRequest req = new HttpRequest();
        //Metadata container Id...
        String MetadataContainerId = getMetadataContainer();
        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ApexClassMember';
        String body = '{"ContentEntityId":"'+meta.id+'","MetadataContainerId":"'+MetadataContainerId+'","Body":"'+meta.body+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfidMetadataSeviceClass.getRresponse('POST',endPoint, headers, body);
        SYstem.debug(res.getBody());
        return MetadataContainerId;
    }

    // apexMetadata contains apexClass Id and body(updated code)...   
    // sample apexMetadata = '{"id":"01p5i00000WKLSQAA5","body":"public class aasheesh{public String name = \'aasheesh singh chouhan\';}"}'
    public static void updateApex(String apexMetadata){
        String metadataContainerId = createApexClassMember(apexMetadata);
        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ContainerAsyncRequest';
        String body = '{ "IsCheckOnly": "false","MetadataContainerId":"'+metadataContainerId+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfidMetadataSeviceClass.getRresponse('POST',endPoint, headers, body);
        SYstem.debug(res.getBody());
    }   
}