public with sharing class DataTransferInDifferentOrg{
    @AuraEnabled
    public static object objectList(){
       object  serObj = ToolingApiService.getObjectList();
       return serObj;
    }

    @AuraEnabled
    public static object getRelatedObject(String parentObject){
        object serObj = ToolingApiService.getRelatedObject(parentObject);
        return serObj;
    }
 
    @AuraEnabled
    public static List<Object> getRecords(String parentObject,List <String>childObjects){
        System.debug(childObjects + 'Hello Rahul');
        List<Object> serObj = ToolingApiService.getRecords(parentObject,childObjects);
        system.debug(serObj+ 'Hello bhai');
        return serObj;
    }

    @AuraEnabled
    public static String sendRecords(String Data){
        String serObj = ToolingApiService.sendRecords(data);
        return serObj;

    }
   
}