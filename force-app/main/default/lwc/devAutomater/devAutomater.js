import { LightningElement, track } from 'lwc';
import updateApex from '@salesforce/apex/DevAutomaterController.updateApex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DevAutomater extends LightningElement {
    body = '' ;
    type = '';
    name = '';
    value = '';
    @track variablesArr = []; 

    get options() {
        return [
            { label: 'Integer', value: 'Integer' },
            { label: 'String', value: 'String' },
            { label: 'Map', value: 'Map' },
            { label: 'List', value: 'List' },
            { label: 'Custom', value: 'Custom' },
        ];
    }

    handleChange(event) {
        console.log(event.target.dataset.key);
        let key = event.target.dataset.key;
        let index = event.target.dataset.index;
        if( key == 'type') this.variablesArr[index].type = event.detail.value;
        if( key == 'label') this.variablesArr[index].label = event.detail.value;
        if( key == 'value') this.variablesArr[index].value = event.detail.value;
    }

    onAddVariable() {
        this.variablesArr.push({
            type : '',
            label : '',
            value : ''
        })
    }

    onGenerate(){
        this.body = '';
        this.variablesArr.forEach(variableProp => {
            this.body += `${variableProp.type} ${variableProp.label} = ${variableProp.value};`
            this.body += '\n';
        });

        updateApex({
            body : this.body
        })
        .then(res =>{
            console.log(res);
            this.showToast(false, res);
        }).catch(err => {
            console.error(err);
            this.showToast(true, err);
        })
    }

    showToast(isError, message){
        // let _title = 'Sample Title';
        // let message = 'Sample Message';
        // let variant = 'error';
        let variantOptions = [
            { label: 'error', value: 'error' },
            { label: 'warning', value: 'warning' },
            { label: 'success', value: 'success' },
            { label: 'info', value: 'info' },
        ];

        const evt = new ShowToastEvent({
            title: isError ? 'Error' : 'Class Updated Successfully',
            message: message,
            variant: isError ? 'error' : 'success',
        });
        this.dispatchEvent(evt);
    }

    
}