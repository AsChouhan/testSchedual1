public class ganrateFieldsWrapper {

        public Integer Id;
        public String fullName;
        public String label;
        public String length;
        public String FieldType;
        public Integer DecimalPlaces;
        public Integer precision;
    
        
        public static List<ganrateFieldsWrapper> parse(String json) {
            return (List<ganrateFieldsWrapper>) System.JSON.deserialize(json, List<ganrateFieldsWrapper>.class);
        }
    }