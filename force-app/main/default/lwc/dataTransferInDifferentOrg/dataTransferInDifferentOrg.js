import { LightningElement, wire, track } from 'lwc';
import objectList from '@salesforce/apex/DataTransferInDifferentOrg.objectList';
import getRecords from '@salesforce/apex/DataTransferInDifferentOrg.getRecords';
import getRelatedObject from '@salesforce/apex/DataTransferInDifferentOrg.getRelatedObject';
import sendRecords from '@salesforce/apex/DataTransferInDifferentOrg.sendRecords';
import UserPreferencesHideLightningMigrationModal from '@salesforce/schema/User.UserPreferencesHideLightningMigrationModal';


export default class DataTransferInDifferentOrg extends LightningElement {
    columns = [{
        label: 'Name',
        fieldName: 'Name'
    }
    ];
    tempListForObTree = [];
    countId = 1;
    innerBool =true;
    @track selectedRecordId = [];
    @track objectList = [];
    @track selectedIds = ['0015i00000qGHqRAAW'];
    @track recordList = [];
    @track fieldList = [];
    @track gridData = [];
    recordBool = false;
    finalBool = false;
    @track reletedObjects = [];
    selectedChildObject = [];
    @track sendData = [];
    ParentrecordName = [];
    @track FinalList = [];
    @track showSpinnerBool = false;
    @track gridColumn = [{
        type: 'text',
        fieldName: 'Name',
        label: 'Records',
    }];
    Totalrecords = [];
    childColumn = [{
        type: 'text',
        fieldName: 'ChildSobjectId',
        label: 'Related Object Name',
    }];

    @track bool = true;
    @track objectName;

    connectedCallback() {
        objectList()
            .then(result => {
                this.objectList = result;
            })
    }

    handleSelect(event) {
        this.selectedChildObject = event.detail.selectedRows;
    }

    handleSectionToggle(event) {
        var section = event.detail.openSections;
        console.log(section);
        this.objectName = section[section.length - 1];
        getRelatedObject({ parentObject: this.objectName })
            .then(result => {
                this.reletedObjects = result

            })
            for(var x of this.selectedRecordId){
            }
    }

    AfterRelatedObjectSelected() {

        console.log('sendToAPex');
        console.log('selectedIds => ', this.selectedIds);
        console.log('Chota bheem');
        // for (let index = 0; index < this.selectedIds.length; index++) {
        //     this.selectedIds[index] = JSON.stringify(this.selectedIds[index]);
            
        // }
        // this.selectedIds=JSON.parse(JSON.stringify(this.selectedIds));
        console.log('selectedIds => ', JSON.stringify(this.selectedIds));
        console.log(this.selectedIds.length);

        let tempSelectedList = this.selectedIds;
        console.log('tempSelectedList >> '+tempSelectedList);
        this.selectedIds=[];
        this.selectedIds=tempSelectedList;
        console.log('selectedIdsList >> '+ this.selectedIds);

        var objectApiName = [];
        console.log(JSON.stringify(this.selectedChildObject),'12312313');
        for (var x of this.selectedChildObject) {
            objectApiName.push(x.RelationshipName);
        }
        var temp = [];
        console.log(JSON.stringify(objectApiName), 'Hello Rahul Bhai');
        getRecords({ parentObject: this.objectName, childObjects: JSON.stringify(objectApiName)})
            .then(result => {
                for (var x of result) {
                    var obj = {
                        Id : x.Id,
                        Name: x.Name
                    }
                    obj._children = [];
                    for (var y of this.selectedChildObject) {
                        var tempOBJ = {};
                        tempOBJ.Name = y.ChildSobjectId;
                        
                        if (x[y.RelationshipName] != null) {
                            tempOBJ._children = [];

                             var teee = JSON.parse(JSON.stringify(x[y.RelationshipName]));
                            for (var z of teee.records) {
                                tempOBJ._children.push({
                                    Id : z.Id,
                                    Name: z.Name
                                });
                            }
                        }
                        obj._children.push(tempOBJ);
                    }
                    temp.push(obj);
                }
                this.gridData = temp;
                // console.log(JSON.stringify(temp));
                this.recordBool = true;
            })
    }
    selectedParentRecord(event) {
        console.log('selectedIds => ', this.selectedIds);
        console.log('selectedRows => ', event.detail.selectedRows);
        console.log('this.selectedParentRecord');
        this.ParentrecordName = event.detail.selectedRows;
        
        // var temp = this.selectedRecordId;
        // this.tempListForObTree = [];
        var temp = [];
        var anTemp =new Array();
        // this.selectedIds.add(x.Id);
        for(var x of this.ParentrecordName){
            console.log(this.selectedIds.findIndex(item => item == x.Id));
            // if(this.selectedIds.findIndex(item => item == x.Id) == -1){
                console.log('inside true');
                anTemp.push(x.Id);
            // }else{
                // this.selectedIds.splice[this.selectedIds.findIndex(item => item == x.Id), 1];
            // }

            var obj = {};
            obj.attributes = {
                type : this.objectName,
                referenceId : 'ref'+this.countId++
            }
            obj.Name = x.Name;
            for(var y of this.selectedChildObject){
                obj[y.RelationshipName] = {
                    records : []
                }                
            }
            temp.push(obj);     
        }
        console.log('selectedIds => ', JSON.stringify(this.selectedIds));

        this.tempListForObTree = temp;
        console.log(JSON.stringify(this.tempListForObTree));

        if(anTemp.length !=  0){

        this.selectedIds = anTemp;// [] ['abcde']
        }
        console.log('AAAAAAAAAA');
        console.log(JSON.stringify(this.selectedIds));
        console.log('BBBBBBB');
        console.log('selectedIds size => ', this.selectedIds.length);
        this.selectedRecordId = temp;
    }


    handleSelectOne(event) {
        console.log('this.handleSelectOne');
        this.sendData = event.detail.selectedRows;
    }

    selectChildRecord() {
        console.log('this.selectChildRecord');
        this.finalBool = true;
        let accountList = [];
        for (let i = 0; i < this.ParentrecordName.length; i++) {
            let account = {
                Name: this.ParentrecordName[i].Name,
                child: JSON.parse(JSON.stringify(this.ParentrecordName[i]._children))
            };
            accountList.push(account);
        }
        this.Totalrecords = accountList;
        console.log(JSON.stringify(this.Totalrecords));
        // if (this.Totalrecords.length > 0) {
        //     this.innerBool = false;
        // }
    }

    sendThisData(event) {
        console.log('SendThisData');
        var records = event.detail.selectedRows;
        var selectedObjectName = event.target.dataset.name;
        console.log(records);
        console.log(1);
        console.log(2);
        var paretRecord = event.target.dataset.id;
        
        console.log(paretRecord);
        var accordianObject = this.selectedChildObject[this.selectedChildObject.findIndex(item => item.ChildSobjectId == selectedObjectName)].RelationshipName;
        console.log(accordianObject);
        var tempData = this.tempListForObTree;

        for(var x of records){
            x.attributes = {
                type : selectedObjectName,
                referenceId : 'ref'+this.countId++
            }
        }
        this.tempListForObTree[this.tempListForObTree.findIndex(item => item.Name == paretRecord)][accordianObject].records = records;
        console.log(JSON.stringify(this.tempListForObTree));
    }

    TransferData() {
        console.log(JSON.stringify(this.tempListForObTree));
        sendRecords({Data : JSON.stringify(this.tempListForObTree)})
            .then(result => {
            })
            .catch(error => {
               
            });

            console.log('End ');
    }

    handleChildTogle(event){
        console.log('CheckBox');
        var section = event.detail.openSections.Name;
        console.log(section);
    }

}