public class metadata_Controller {
    
    //Wrapper for store metadata object xmlName.
    public class MetadataObjectWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<MetadataObjectWrapper> items = new List<MetadataObjectWrapper>();
        @AuraEnabled
        public boolean expanded;
        @AuraEnabled
        public String name;
        
        public MetadataObjectWrapper(String label, String fileId){
            this.label = label;
            this.expanded = true;
            this.name = fileId;
        }
        
        public MetadataObjectWrapper(String label, List<MetadataObjectWrapper> items){
            this.label = label;  
            this.items = items;
            this.name = label;
            this.expanded = true;
        }
    }
    
    //Method for retreve all metadata objects.
    @AuraEnabled
    public static List<MetadataObjectWrapper> describeMetaData(Double version){
        System.debug(userInfo.getUserId());
        List<MetadataObjectWrapper> metadataList = new List<MetadataObjectWrapper>();
        MetadataFactory.MetadataOutlet describeMetadataObject =	MetadataFactoryUtil.getPort();
        MetadataFactory.DescribeMetadataResult result = describeMetadataObject.describeMetadata(version);
        for(MetadataFactory.DescribeMetadataObject MD : result.metadataObjects){
            List<MetadataObjectWrapper> innerEliment = new List<MetadataObjectWrapper>();           
            metadataList.add(new MetadataObjectWrapper(MD.xmlName, innerEliment));
        }
        return metadataList;        
    }
    
    
    //Method for retreve ListMetadata.
    @AuraEnabled
    public static MetadataObjectWrapper describeMetaDataList(String metadataName){
        
        List<MetadataObjectWrapper> innerEliment = new List<MetadataObjectWrapper>(); 
        MetadataFactory.MetadataOutlet describeMetadataList = MetadataFactoryUtil.getPort();
        List<MetadataFactory.ListMetadataQuery> storexmlNameForQuery = new List<MetadataFactory.ListMetadataQuery>();
        MetadataFactory.ListMetadataQuery ML1 = new MetadataFactory.ListMetadataQuery();
        ML1.type_x = metadataName;
        ML1.folder = null;
        storexmlNameForQuery.add(ML1);
        Double dc = 58.0;
        List<MetadataFactory.FileProperties> metadataListResult = describeMetadataList.listMetadata(storexmlNameForQuery, dc);
        System.debug(metadataListResult);
        if(metadataListResult != null){
            for(MetadataFactory.FileProperties MF : metadataListResult){
                System.debug(MF);
                innerEliment.add(new MetadataObjectWrapper(MF.fullName, MF.id+' '+MF.type_x));
            }  
        }
        MetadataObjectWrapper MO = new MetadataObjectWrapper(metadataName, innerEliment);  
        System.debug(MO);
        return MO;  
        
        
        
    }
    
    
    @AuraEnabled
    public static object getBody(String fileId, String metadataName){
        Map<String, object> responseMap = new  Map<String, object>();
        String s = '/services/data/v58.0/tooling/sobjects/'+metadataName+'/'+fileId;
        System.debug(fileId);
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm() +'/services/data/v58.0/tooling/sobjects/'+metadataName+'/'+fileId;
        // req.setEndpoint('callout:salesforce_named_credential/'+s);
        Map<String, String> headers = new Map<String, String>();
        headers.put('Authorization', 'Bearer 00D5i00000EUVZA!AQ8AQG0PvI0qGFbgHbQ.k7fKrHkNIDo5NBG1ZU5YnX9gF8Bv6_pnggG90zE8OKl2aDyu53G2SZqvIC.FjKlSaRBbuZns6JGh');
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getResponse('GET', endPoint, headers, '');
        System.debug(res.getBody());
        if(res.getStatusCode() == 200) {
            responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody()); 
            for(String st: responseMap.keyset()){
                System.debug(st+' -->  '+responseMap.get(st));
            }
            if(metadataName == 'ApexPage'){
                return responseMap.get('Markup');
            }else if(metadataName == 'ApexClass' || metadataName == 'ApexTrigger'){
                return responseMap.get('Body');
            }else{
                return responseMap.get('Metadata');
            }
            
        }
        return 'no code found';
    }
}