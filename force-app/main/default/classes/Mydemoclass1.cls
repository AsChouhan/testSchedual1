public class Mydemoclass1{
    public static String sessionId = '00D5i00000EUVZA!AQ8AQB9XF7T2Se8PQ4TfqtskJnm2e5lDOC47tRCbKUn1QCoupMD0qK9KDhI8xmVeTw7s4Fsed0VbYp.AQO8ajXV3wyoMK_MH';
    public static void createApexClass(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ApexClass');
        String className = 'asc111';
        String body = '{"Name": "'+className+'","Body" : "public class '+className+'{ public Void sayHello(){ string name= \'ashish\' system.debug(\'***Name: \'+name);} }" }';
        req.setBody(body);
        req.setHeader('Authorization', 'Bearer '+sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        
        
        Http ht =new Http();
        HttpResponse res = new HttpResponse();
        System.debug(req);
        res = ht.send(req);
        SYstem.debug(res.getBody());
    }
    
    // Update apex class...   
    
    //Ganreting metadata containor id...
    public static String createMetadataContainer(){ 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/MetadataContainer');
        req.setBody('{ "Name": "myContainor"}');
        req.setHeader('Authorization', 'Bearer '+sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        
        
        Http ht =new Http();
        HttpResponse res = new HttpResponse();
        System.debug(req);
        res = ht.send(req);
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
    public static String createApexClassMember(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ApexClassMember');
        // Id of apex class.
        String ContentEntityId = '01p5i00000WKEXJAA5';  
        //Metadata container Id...
        String MetadataContainerId = createMetadataContainer();
        // Updated code for apex class.
        String updatedCode = 'public class asc1{ public Void sayHello(){String name = \'ashish singh\';}}';  
        
        
        String body = '{"ContentEntityId":"'+ContentEntityId+'","MetadataContainerId":"'+MetadataContainerId+'","Body":"'+updatedCode+'"}';
        System.debug(body);
        req.setBody(body);
        req.setHeader('Authorization', 'Bearer '+sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        
        
        Http ht =new Http();
        HttpResponse res = new HttpResponse();
        System.debug(req);
        res = ht.send(req);
        SYstem.debug(res.getBody()); 
        
        
        return MetadataContainerId;
    }
    
    public static void createContainerAsyncRequest(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ContainerAsyncRequest');
        String mContainerId = createApexClassMember();
        req.setBody('{ "IsCheckOnly": "false","MetadataContainerId":"'+mContainerId+'"}');
        req.setHeader('Authorization', 'Bearer '+sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
       
        
        Http ht =new Http();
        HttpResponse res = new HttpResponse();
        System.debug(req);
        res = ht.send(req);
        SYstem.debug(res.getBody());
    }   
}