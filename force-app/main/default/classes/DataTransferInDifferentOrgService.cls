public with sharing class DataTransferInDifferentOrgService {
    public Static Final String ACCESSTOKEN = '00D5i00000EUVZA!AQ8AQBmkmWRP9n3kqs83YtVz2ny96pf05Y2fy_b7JvdONuF96LUGeVJ8yrZ.d_BLQjStaAGh.I40LT7D502pLOr2riMng5YE';

   public static object objectList(){
    Map<String, object> responseMap = new Map<String, object>();
        String str = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v58.0/tooling/query/?q=SELECT+QualifiedApiName+From+EntityDefinition+where+IsCustomizable=true';
        HttpResponse res = getResponse(str);
        System.debug(res.getStatusCode() + ' ' + res.getBody());
        if (res.getStatusCode() == 200){
            responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody());
            for (String st : responseMap.keyset()){
                System.debug(st + ' -->  ' + responseMap.get(st));
            }
            return responseMap.get('records');
        }
        return 'no code found';
   }

   public static object getRelatedObject(String parentObject) {

    Map<String, object> responseMap = new Map<String, object>();
        String str = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v58.0/tooling/query/?q=SELECT+ChildSobjectId,RelationshipName+From+RelationshipDomain+where+ParentSobjectId=' + '\'' + parentObject + '\'' + '+limit+10';
            HttpResponse res = getResponse(str);
        System.debug(res.getStatusCode() + ' ' + res.getBody());
        if (res.getStatusCode() == 200){
            responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody());
            for (String st : responseMap.keyset()){
                System.debug(st + ' -->  ' + responseMap.get(st));
            }
            return responseMap.get('records');
        }
        return 'no code found';
   }

    public static List<Object> getRecords(String parentObject,List <String>childObjects){
        String instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String objectApiName = parentObject;
        HttpRequest request = new HttpRequest();
        String query = 'SELECT+Id,Name';
        for(String st : childObjects){
            query+=',(SELECT+Id,Name+FROM+'+st+')';
        }
        query+='+FROM+'+objectApiName;
        request.setEndpoint(instanceUrl + '/services/data/v58.0/query/?q='+query);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + ACCESSTOKEN);
        Map<String, List<Object>> recordsMap = new Map<String, List<Object>>();
        HttpResponse response = new Http().send(request);
            List<Object> records = new List<Object> ();
        if (response.getStatusCode() == 200){
            String jsonResponse = response.getBody();
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
             records = (List<Object>) result.get('records');

        }
       return records;
    }
    
    public static String sendRecords(String Data){
       List<Map<String, Object>> records = new List<Map<String, Object>>();       
       Map<String, Object> requestBody = new Map<String, Object>{
           'records' => Data
       };
        String str = 'https://briskmind9-dev-ed.my.salesforce.com/services/data/v58.0/composite/tree/Account';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(str);
        req.setMethod('POST');
        req.setBody(JSON.serialize(requestBody));
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer 00D5g00000KCl9K!AQ0AQCICxd7De8oRS_Bwr73jG63J_4lcUt2pujN4Wm5yUlclxFq0TD9gMMDTMDun9BCOrgH4VhPHbxMEcbA0D1gJ2wj8yayC');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if(res.getStatusCode() == 201) {
            
            return 'DOne';
        }
         return 'no code found';
    }

    public static HTTPResponse getResponse(String str) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(str);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + ACCESSTOKEN);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
}