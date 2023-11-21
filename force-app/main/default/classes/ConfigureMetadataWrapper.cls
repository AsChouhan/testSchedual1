public with sharing class ConfigureMetadataWrapper {
    public class CreateApexWrapper{
        public String name;
        public String body;    
    }

    public class UpdateApexWrapper{
        public String id;
        public String body;
    }

    public class LwcMetaWrapper {
        public String fullName;
        public String description;
        public String masterLabel;
        public List<String> target;
    }

    public class LwcInsertWrapper{
        public String componentId;
        public String devloperName;
        public String formate;
        public String sourceCode;
    }

    public class LwcResourceWrapper{
        public String sourceFileId;
        public String source;
    }
}