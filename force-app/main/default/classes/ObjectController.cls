public class ObjectController {
    public static String sessionId = '00D5g00000KCl9K!AQ0AQAgDvJJk8DygaRqb9PyE0bR_wRckz5qtVnAeqI9DFO4K9t1aUvSX2eYvlskjKmMT3OgUMiYSJjKKE8AH8MiDRuzbxLVg';
    public static String baseUrl = 'https://briskmind9-dev-ed.my.salesforce.com'; 
    @AuraEnabled
    public static object objectList(){
        Map<String, object> responseMap = new  Map<String, object>();
        String str = baseUrl +'/services/data/v58.0/tooling/query/?q=SELECT+QualifiedApiName+From+EntityDefinition+where+IsCustomizable=true';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(str);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+sessionId);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode()+' '+res.getBody());
        if(res.getStatusCode() == 200) {
            responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody()); 
            for(String st: responseMap.keyset()){
                System.debug(st+' -->  '+responseMap.get(st));
            }
            return responseMap.get('records');
        }
       return 'no code found';
    }


    @AuraEnabled
    public static List<String> upsertObject(Map<String, object> dtMap, String fieldsString){  
        // fieldsString = fieldsString.replace('[', '');
        // fieldsString = fieldsString.replace(']', '');
        System.debug(fieldsString);
        List<String> returnList = new List<String>();
        try {
            List<ganrateFieldsWrapper> wrp = ganrateFieldsWrapper.parse(fieldsString);
            for(ganrateFieldsWrapper wr : wrp){
                System.debug(wr);
            } 
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();  
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = sessionId;
            List<MetadataService.Metadata> metaD = new List<MetadataService.Metadata>();
            MetadataService.CustomObject  customobject = new MetadataService.CustomObject();
            customobject.fullName = (String)dtMap.get('fullName');
            customobject.label = (String)dtMap.get('label');
            customobject.pluralLabel = (String)dtMap.get('pluralLabel');
            customObject.nameField = new MetadataService.CustomField();
            customobject.nameField.type_x = (String)dtMap.get('nameFieldType');
            customobject.nameField.label = (String)dtMap.get('nameFieldLabel');
            customobject.deploymentStatus = 'Deployed';
            customObject.sharingModel = 'ReadWrite';
            if(wrp.size() != 0){
                List<MetadataService.CustomField> fields = new List<MetadataService.CustomField>();
                for(ganrateFieldsWrapper sf : wrp){
                    MetadataService.CustomField singleField = new MetadataService.CustomField();
                    singleField.fullName = sf.fullName;
                    singleField.type_x = sf.FieldType;
                    singleField.label = sf.label;
                    if(sf.FieldType == 'Number' || sf.FieldType == 'Currency' || sf.FieldType == 'Percent'){
                        singleField.scale = sf.DecimalPlaces;
                        singleField.precision = sf.precision;
                    }else if(sf.FieldType == 'Text' || sf.FieldType == 'TextArea'){
                        singleField.length = (sf.length!='' && sf.length!= null)?Integer.valueOf(sf.length):null;
                    }
                    fields.add(singleField);
                }         
                customobject.fields = fields;
            }
            metaD.add(customobject);
            MetadataService.UpsertResult[] res = service.upsertMetadata(metaD);
            for(MetadataService.UpsertResult sV : res){
                if(sV.errors != null){
                    for(MetadataService.Error err : sV.errors){
                        System.debug(err.message);
                        returnList.add(err.message);
                    }
                    return returnList;
                }
            }
            returnList.add('created');
            return returnList;
        } catch (Exception e) {
            returnList.add(e.getMessage());
            return returnList;
        }       
    }   
    
    @AuraEnabled
    public static String createFields(String fieldsString){
        try {
            List<ganrateFieldsWrapper> wrp = ganrateFieldsWrapper.parse(fieldsString);
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();  
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = sessionId;
            List<MetadataService.Metadata> metaD = new List<MetadataService.Metadata>();
            

            for(ganrateFieldsWrapper sf : wrp){
                MetadataService.CustomField customField = new MetadataService.CustomField();
                customField.fullName = sf.fullName;
                customField.type_x = sf.FieldType;
                customField.label = sf.label;
                customField.length = (sf.length!='' && sf.length!= null)?Integer.valueOf(sf.length):null;
                metaD.add(customField);
            }     

            MetadataService.SaveResult[] res = service.createMetadata(metaD);
            for(MetadataService.SaveResult sV : res){
                if(sV.errors != null){
                    for(MetadataService.Error err : sV.errors){
                        System.debug(err.message);
                    }
                    return sv.errors[0].message;
                }
            }
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }


    @AuraEnabled
    public static object getDescribeObject(String apiName){
        try {
            Map<String, object> responseMap = new  Map<String, object>();
            String str = baseUrl +'/services/data/v58.0/sobjects/'+apiName+'/describe';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(str);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+sessionId);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getStatusCode()+' '+res.getBody());
            if(res.getStatusCode() == 200) {
                responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody()); 
                for(String st: responseMap.keyset()){
                    System.debug(st+' -->  '+responseMap.get(st));
                }
                return res.getBody();
            }
           return 'no code found';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}