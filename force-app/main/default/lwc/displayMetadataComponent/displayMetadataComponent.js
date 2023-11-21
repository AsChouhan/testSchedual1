import { LightningElement, track } from 'lwc';
import describeMetaData from '@salesforce/apex/metadata_Controller.describeMetaData';
import getBody from '@salesforce/apex/metadata_Controller.getBody';
import describeMetaDataList from '@salesforce/apex/metadata_Controller.describeMetaDataList';

export default class DisplayMetadataComponent extends LightningElement {
    @track metadata;
    @track body;
    @track showSpinnerBool = false;

    connectedCallback(){
        console.log('connected callback');
        this.showSpinnerBool = true;
        console.log('here');
        describeMetaData({version: 58.0})
        .then(result=>{
            console.log('described');
           this.metadata = result;
           console.log(result);
        })
        .then(error=>{
            console.log(error);
        })
        this.showSpinnerBool = false;
    }

  
    handleSelect(event) {  
        var id = event.detail.name;
        this.showSpinnerBool = true; 


        if(id.includes(" ")){
            this.showSpinnerBool = true; 

            console.log('inside true');
            console.log(id);
            var arr = id.split(' ');
            console.log(arr[0]);   
            getBody({fileId : arr[0], metadataName : arr[1]})
            .then(result=>{
                console.log(result);
                this.body = result;
            })
            this.showSpinnerBool = false; 
            
        }else{
            this.showSpinnerBool = true; 

            console.log('inside false');  
            console.log(id);
            describeMetaDataList({metadataName : id})
            .then(result=>{
                var tempStore = this.metadata;
                this.metadata = [];
                var index = tempStore.findIndex(item => item.name == id);
                console.log(JSON.stringify(result));
                tempStore[index] = result;
                //  {
                //     label : result.label,
                //     name : result.name,
                //     expanded : true,
                //     items : result.items
                // };

                var str = JSON.stringify(tempStore);


                this.metadata = JSON.parse(str);
                console.log(JSON.stringify(tempStore));
                this.showSpinnerBool = false; 
                               
            })
        }
  
        
    }
}