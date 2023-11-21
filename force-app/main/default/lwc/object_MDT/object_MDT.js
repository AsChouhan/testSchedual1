import { LightningElement, track, wire } from 'lwc';
import objectList from '@salesforce/apex/ObjectController.objectList';
import upsertObject from '@salesforce/apex/ObjectController.upsertObject';
import getDescribeObject from '@salesforce/apex/ObjectController.getDescribeObject';


export default class Object_MDT extends LightningElement {
    @track LF; //Checkbox, Date, DateTime, Email, Time, Url, Phone
    @track LFL; // Text, TextArea
    @track LFLD; // Number, Percent, Currency
    @track dataTypeSelected = false;
    @track hasField;

    @track displayAddFields = [];
    @track showSpinnerBool = false;
    @track showObject = false;
    @track objList = [];
    @track isCustom = true;
    fullObjectDetails;
    @track basicObjectDetail;
    @track objectFields = [];
    @track selectedField;
    @track dataType = [
        //lable Fullname
        {label : 'Date', value : 'Date'},
        {label : 'DateTime', value : 'Datetime'},
        {label : 'Email', value : 'Email'},
        {label : 'Time', value : 'Time'},
        {label : 'Phone', value : 'Phone'},

        // label fullName length
        {label : 'Text', value : 'Text'},
        {label : 'TextArea', value : 'Textarea'},

        // label, fullName, length, decimal places..
        {label : 'Number', value : 'Number'},
        {label : 'Currency', value : 'Currency'},
        {label : 'Percent', value : 'Percent'},

    ];
    fieldsColumn = [{
        type: 'text',
        fieldName: 'label',
        label: 'Field Name',
    }]

    detailMap = new Map();
    fieldsDetailMap = new Map();
    showAddFields = false;
    Type = 'Text';
    countId = 0;

    constructor(){
        console.log('CONSTRUCTOR HERE');
    }

    connectedCallback(){
        console.log('jhbhjbh');
        var xount = 0;
        console.log(xount++);
        this.showSpinnerBool = true;
        console.log(xount++);
        objectList()
        .then(result=>{
            console.log(xount++);
            result.sort(this.dynamicSortASC('QualifiedApiName'));
            var temp = [];
            for(var x of result){
                var obj = {
                    label : x.QualifiedApiName,
                    name : x.QualifiedApiName,
                    expanded : false
                }
                temp.push(obj)
            }
            console.log(xount++);
            this.objList = temp;
        })
        this.showSpinnerBool = false;
    }

    dynamicSortASC(property) {
        return function (a, b) {
            if (a[property] < b[property]) {
                return -1;
            } else if (a[property] > b[property]) {
                return 1;
            } else {
                return 0;
            }
        };
    }

    getDescribe(event){
        this.showSpinnerBool = true;
        this.showAddFields = false;
        this.displayAddFields = [];
        var objApiName = event.detail.name;
        getDescribeObject({apiName: objApiName})
        .then(result=>{            
            this.fullObjectDetails = JSON.parse(result);
            this.objectFields = this.fullObjectDetails.fields;
            var isAutoNumber = this.objectFields[(this.objectFields).findIndex(item => item.nameField == true)].autoNumber;

            this.Type = (isAutoNumber==true)?'AutoNumber':'Text';
            var obj = {
                objectLabel : this.fullObjectDetails.label,
                objectName : objApiName,
                PluralLabel : this.fullObjectDetails.labelPlural,
                nameFieldLabel : this.objectFields[(this.objectFields).findIndex(item => item.nameField == true)].label,
                isAutoNumber : isAutoNumber
            }

            while (true) {
                var index = this.objectFields.findIndex(item => item.createable == false);
                if(index != -1){
                    this.objectFields.splice(index, 1);
                }else{
                    break;
                }
            }

            this.hasField = (this.objectFields.length != 0)?true:false;
            this.basicObjectDetail = obj;
            this.showObject = true;
            this.isCustom = false;
            this.showSpinnerBool = false;
            this.detailMap.set('fullName', obj.objectName);
            this.detailMap.set('label', obj.objectLabel );
            this.detailMap.set('pluralLabel', obj.PluralLabel);
            this.detailMap.set('nameFieldType', this.Type);
            this.detailMap.set('nameFieldLabel', obj.nameFieldLabel);            
        }).then(lst=>{
            this.showSpinnerBool = false;            
        })
    }

    getField(event){
        this.showSpinnerBool = true;
        var fieldApiName = event.target.dataset.id;
        this.selectedField = this.objectFields[this.objectFields.findIndex(item => item.name == fieldApiName)];
        
        var type = this.selectedField.type;
        if(type=='string' || type=='textarea'){
            this.LFL=true;
            this.LFLD = false;
        }else if(type=='number' || type=='percent' || type=='currency'){
            this.LFLD = true;
            this.LFL = false;
        }else {
            this.LF=true;
            this.LFL = this.LFLD = false;
        }

        this.showAddFields = true;
        if(this.displayAddFields.findIndex(item => item.id == 111) == -1){
            this.displayAddFields.push({
                isEditField : true,
                id : 111,
                fullName : this.selectedField.name,
                FieldType : this.selectedField.type,
                label : this.selectedField.label,
                length : this.selectedField.length,
                precision : this.selectedField.precision,
                DecimalPlaces : this.selectedField.scale
            });
        }
        this.showSpinnerBool = false;
    }

    addFields() {
        this.showAddFields = true;
        this.displayAddFields.push({
            Id: this.countId++
        });        
    }

    handleDelete(event) {
        var elId = event.target.dataset.id;
        this.displayAddFields.splice(this.displayAddFields.findIndex(item => item.Id == elId), 1);
        if(this.displayAddFields.length == 0){
            this.showAddFields = false;
        }
    }

    // Get Value method for object fields....
    getValue(event) {
        var fieldName = event.target.dataset.id;
        var value;
        if (fieldName == 'nameFieldType') {
            value = event.detail.checked;
            this.Type = (value == true) ? 'AutoNumber' : 'Text';
            value = this.Type;
        } else {
            value = event.target.value;
        }
        this.detailMap.set(fieldName, value);
    }

    // get value method for fields of object...
    getFieldsValue(event) {
        var fieldId = event.target.dataset.id;
        var fieldRec = event.target.dataset.name;
        var value = event.target.value;
        if (fieldRec == 'fullName') {
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fieldId)].fullName = value;
        } else if (fieldRec == 'FieldType') {
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fieldId)].FieldType = value;
        } else if (fieldRec == 'label') {
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fieldId)].label = value;
        } else if (fieldRec == 'length') {
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fieldId)].length = value;
        }else if(fieldRec == 'precision'){
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fieldId)].precision = value;
        }else if(fieldRec == 'DecimalPlaces'){
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fieldId)].DecimalPlaces = value;
        }
    }

    createObject1() {
        upsertObject({ dtMap: Object.fromEntries(this.detailMap), fieldsString : JSON.stringify(this.displayAddFields)})
            .then(result => {
                alert(result);
            })
    }

    getFieldType(event){
        var type = event.detail.value;
        var fId = event.target.dataset.id;
        // var obj = this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)];
        this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].dataTypeSelected = true;
        this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].FieldType = type;

        if(type=='Text' || type=='Textarea' || type == 'string'){
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].LFL = true;
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].LFLD = false;
        }else if(type=='Number' || type=='Percent' || type=='Currency'){
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].LFLD = true;
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].LFL = false;
        }else {
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].LF = true;
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].LFLD = false;
            this.displayAddFields[this.displayAddFields.findIndex(item => item.Id == fId)].LFL = false;
        }
    }

    handleIsCustom(){
        this.isCustom = false;
        this.hasField = false;
        this.basicObjectDetail = {isAutoNumber : false};
        this.detailMap.set('nameFieldType', 'Text');
        this.showObject = true;
    } 
    
    CancelUpsertion(){
        this.isCustom = true;
        this.showObject = false;
        this.showAddFields = false;
        this.detailMap = new Map();
        this.displayAddFields = [];
        // this.ShowToast('Get Help', 'Canceled.', 'Success');
    }

    // ShowToast(title, message, variant) {
    //     const evt = new ShowToastEvent({
    //         title: title,
    //         message: message,
    //         variant: variant,
    //     });
    //     this.dispatchEvent(evt);
    // }
}