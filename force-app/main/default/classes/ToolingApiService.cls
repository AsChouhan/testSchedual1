public with sharing class ToolingApiService {
    public static final String ACCESS_TOKEN = '00D5i00000EUVZA!AQ8AQPX_2jNVbkbAIXTXyHF8t0P1cQUn.orEkbDNLmjVNEujHYpMYfkgCQF4rA2r0GUJr7ScErt3ZrWmwXW0dom7ZnoOJ5Pe';
    public static final String OBJ_QUERY = '/services/data/v58.0/tooling/query/?q=SELECT+QualifiedApiName+From+EntityDefinition+where+IsCustomizable=true';
    public static final String RELETED_OBJ_QUERY = '/services/data/v58.0/tooling/query/?q=SELECT+ChildSobjectId,RelationshipName+From+RelationshipDomain+where+ParentSobjectId=';
    public static final String GET_RECORDS_ENDPOINT = '/services/data/v58.0/query/?q=';
    public static final String TARGET_ENDPOINT = 'https://briskmind9-dev-ed.my.salesforce.com';
    public static final String BRISKMINDS_ENDPOINT = TARGET_ENDPOINT+'/services/data/v58.0/composite/tree/Account';
    public static final String INSTANCEURL = URL.getSalesforceBaseUrl().toExternalForm();
    public static final String POST = 'POST';
    public static final String GET = 'GET';
    public static final String RECEIVER_ACCESS_TOKEN = 'https://briskmind9-dev-ed.my.salesforce.com/secur/frontdoor.jsp?sid=00D5g00000KCl9K!AQ0AQD1nqAV26258lwB2vKyB1RJWo7coJwwxnhCAKTxRkMpIjfZx210MoXXURx8OWLW1yeGrdsNsjPJhuaTdYm3X5WX.WmCm';
    
    public static Object getObjectList(){
        Map<String, object> responseMap = new Map<String, object>();
        String endPoint = instanceUrl + OBJ_QUERY;
        map<string,string> headersMap = new map<string,string>();
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Authorization', 'Bearer ' + ACCESS_TOKEN);
        String reqBody ='';
        HttpResponse res = getResponse(endPoint,GET,reqBody,headersMap);
        if (res.getStatusCode() == 200){
            responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody());
            for (String key : responseMap.keyset()){
                System.debug(key + ' -->  ' + responseMap.get(key));
            }
            return responseMap.get('records');
        }
        	return 'Error';
    }
    
    public static object getRelatedObject(String parentObject) {
        
        Map<String, object> responseMap = new Map<String, object>();
        String endPoint = INSTANCEURL + RELETED_OBJ_QUERY + '\'' + parentObject + '\'' + '+limit+10';
        map<string,string> headersMap = new map<string,string>();
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Authorization', 'Bearer ' + ACCESS_TOKEN);
        String reqBody ='';
        HttpResponse res = getResponse(endPoint,GET,reqBody,headersMap);
        System.debug(res.getStatusCode() + ' ' + res.getBody());
        if (res.getStatusCode() == 200){
            responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody());
            for (String Key : responseMap.keyset()){
                System.debug(Key + ' -->  ' + responseMap.get(Key));
            }
            return responseMap.get('records');
        }
        return 'Error in Callout';
    }
    
    public static List<Object> getRecords(String parentObject,List <String>childObjects){
        HttpRequest request = new HttpRequest();
        String query = 'SELECT+Id,Name';
        System.debug(childObjects);
       // if(childObjects == null || childObjects == ''){
            for(String st : childObjects){
                query+=',(SELECT+Id,Name+FROM+'+st+')';
            }
       // }
        query+='+FROM+'+parentObject;
        String endPoint = INSTANCEURL + GET_RECORDS_ENDPOINT +query;
        map<string,string> headersMap = new map<string,string>();
        headersMap.put('Authorization', 'Bearer ' + ACCESS_TOKEN);
        String reqBody = '';
        HttpResponse response = getResponse(endPoint,GET,reqBody,headersMap);
        system.debug(response.getStatus()+ 'StatusCode');
        Map<String, List<Object>> recordsMap = new Map<String, List<Object>>();
        List<Object> records = new List<Object> ();
        String jsonResponse = response.getBody();
        
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        records = (List<Object>) result.get('records');
        return records;
    }
    
    public static String sendRecords(String data){
        List<Map<String, Object>> records = new List<Map<String, Object>>();       
        Map<String, Object> requestBody = new Map<String, Object>{
            'records' => data
                };
                    
        string reqBody = JSON.serialize(requestBody);
        map<string,string> headersMap = new map<string,string>();
        headersMap.put('Content-Type', 'application/json');
        headersMap.put('Authorization', 'Bearer '+RECEIVER_ACCESS_TOKEN);
        HttpResponse res = getResponse(BRISKMINDS_ENDPOINT,POST,reqBody,headersMap);
        
        return res.getBody();
    }
    
    public static HTTPResponse getResponse(String endPoint,string methodName,string reqBody ,map<string,string> headersMap) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(methodName);
        if(reqBody!=null && reqBody!=''){
            req.setbody(reqBody);
        }
        if(headersMap.size()>0){
            for(String key : headersMap.keyset()){
                req.setHeader(key,headersMap.get(key));   
            }
        }
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
    public static HTTPResponse getResponse(String endPoint,string methodName) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(methodName);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
}