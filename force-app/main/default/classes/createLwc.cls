public class createLwc {
    public static String sessionId = '00D5i00000EUVZA!AQ8AQB9XF7T2Se8PQ4TfqtskJnm2e5lDOC47tRCbKUn1QCoupMD0qK9KDhI8xmVeTw7s4Fsed0VbYp.AQO8ajXV3wyoMK_MH';
    public static void createLwcComponent(String lwcComponentMetadata){   
        ConfigureMetadataWrapper.LwcMetaWrapper meta = (ConfigureMetadataWrapper.LwcMetaWrapper)System.JSON.deserialize(lwcComponentMetadata, ConfigureMetadataWrapper.LwcMetaWrapper.class);
        String targ =  '"targets": {"target": '+JSON.serialize(meta.target)+'}';
        targ = targ.replace('(','[').replace(')',']');
        String body = '{"FullName":"'+meta.fullName+'","Metadata":{"apiVersion":48,"description": "'+meta.description+'","isExplicitImport": false,"isExposed": true,"masterLabel": "'+meta.masterLabel+'",'+targ+'}}';

        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/tooling/sobjects/LightningComponentBundle';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfidMetadataSeviceClass.getRresponse('POST',endPoint, headers, body);
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
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/tooling/sobjects/LightningComponentResource';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfidMetadataSeviceClass.getRresponse('POST',endPoint, headers, body);
        system.debug(res.getBody());
    }
    
    
    public static void updateResource(String lwcResouceMetadata){   
        ConfigureMetadataWrapper.LwcResourceWrapper meta = (ConfigureMetadataWrapper.LwcResourceWrapper)System.JSON.deserialize(lwcResouceMetadata, ConfigureMetadataWrapper.LwcResourceWrapper.class);
        Map<String, String> headers = new Map<String, String>();
        String body = '{"Source" : "' + meta.source + '"}';
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/tooling/sobjects/LightningComponentResource/'+meta.sourceFileId;
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfidMetadataSeviceClass.getRresponse('POST',endPoint, headers, body);
        while (res.getStatusCode() == 302) {
            System.debug('inside 302');
            endPoint = res.getHeader('Location');
            res = ConfidMetadataSeviceClass.getRresponse('POST',endPoint, headers, body);
        }
        System.debug(res.getStatusCode());
        system.debug(res.getBody());
    }    
}