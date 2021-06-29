import { LightningElement,api,track,wire } from 'lwc';
import getQueueData from '@salesforce/apex/QueueManagementScreen.getQueueData';
import saveQueueMember from '@salesforce/apex/QueueManagementScreen.saveQueueMembers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import fetchAllQueueMembers from '@salesforce/apex/QueueManagementScreen.fetchAllQueueMembers';
import getQueueObjects from '@salesforce/apex/QueueManagementScreen.getQueueObjects';
const membercolumns = [
    { label: 'Name', fieldName: 'Name' , type: 'text'},
    { label: 'Type', fieldName: 'Type' , type: 'text'}
];
export default class QueueDetailsScreen extends LightningElement {
    @api displayDetails;
    @api queueId;
    @api queueName
    @api userList;
    @api groupList;
    @api roleList;
    @api rolesIntSubList;
    @api rolesSubList;
    displayAll = false;
    queueDetails;
    displayspinner = true;
    error;
    memberdata = [];
    options = [];
    values = [];
    originalMember = [];
    objectsInQueue = [];
    membercolumns = membercolumns;
    selectedMemberType = 'users';
    queueNotUpdated = true;
    wiredQueueMemberReturn = {};
    get allTypesOfMember() {
        return [
            { label: 'Users', value: 'users' },
            { label: 'Public Groups', value: 'publicGroups' },
            { label: 'Roles', value: 'roles' },
            { label: 'Roles and Internal Subordinates', value: 'rolesIntSub' },
            { label: 'Roles, Internal and Portal Subordinates', value: 'rolesIntPorSub' },
        ];
    }
    get allowEdit() {
        return !this.queueNotUpdated;
    }
    @wire (getQueueObjects, {queueIdDetails: '$queueId'}) 
    queueObjects({data,error}) {
        if(data) {
            this.objectsInQueue = data;
        }
    }
    @wire (getQueueData , {queueIdDetails: '$queueId', memberType: '$selectedMemberType'})
    wiredQueueMembers(value) { 
        this.queueNotUpdated = true; 
        this.wiredQueueMemberReturn = value;
        const { data, error } = value;
        if(data){
            var tempValues = [];
            var items = [];
            this.queueDetails = data;
            this.error = undefined;
            var selectedvalues = [];
        console.log(this.selectedMemberType+'type');
            switch(this.selectedMemberType) {
                case 'users':
                    this.options = this.userList;    
                    if(this.queueDetails.queueUserMembers.length > 0) {
                        for (let i = 0; i < this.queueDetails.queueUserMembers.length; i++) {
                            selectedvalues.push(
                                this.queueDetails.queueUserMembers[i].memberId
                            );
                        }
                    } 
                    break ;
                case  'publicGroups':
                    this.options = this.groupList;
                    if(this.queueDetails.queueGroupMembers != undefined && this.queueDetails.queueGroupMembers.length > 0) {
                        for (let i = 0; i < this.queueDetails.queueGroupMembers.length; i++) {
                            selectedvalues.push(
                                this.queueDetails.queueGroupMembers[i].memberId
                            );
                        }
                    }
                    break ;
                case 'roles':
                    this.options = this.roleList;
                    if(this.queueDetails.queueRoleMembers != undefined && this.queueDetails.queueRoleMembers.length > 0) {
                        for (let i = 0; i < this.queueDetails.queueRoleMembers.length; i++) {
                            selectedvalues.push(
                                this.queueDetails.queueRoleMembers[i].memberId
                            );
                        }
                    }
                    break ;
                case 'rolesIntSub':
                    this.options = this.rolesIntSubList;
                    if(this.queueDetails.queueRoleIntSubMembers != undefined && this.queueDetails.queueRoleIntSubMembers.length > 0) {
                        for (let i = 0; i < this.queueDetails.queueRoleIntSubMembers.length; i++) {
                            selectedvalues.push(
                                this.queueDetails.queueRoleIntSubMembers[i].memberId
                            );
                        }
                    }
                    break ;
                case 'rolesIntPorSub':
                    this.options = this.rolesSubList;
                    if(this.queueDetails.queueRoleSubMembers != undefined && this.queueDetails.queueRoleSubMembers.length > 0) {
                        for (let i = 0; i < this.queueDetails.queueRoleSubMembers.length; i++) {
                            selectedvalues.push(
                                this.queueDetails.queueRoleSubMembers[i].memberId
                            );
                        }
                    }
                    break ;
			
            }
            this.values = selectedvalues;
            this.originalMember = selectedvalues;
            this.displayspinner = false;
        }
        else if (error) {
            this.error = error;
            this.options = undefined;
            this.displayspinner = false;
        }
    }
    moveBack(event){
        this.displayspinner = true;    
        const backEvent = new CustomEvent(
            'movetopreviousscreen' , {
                detail : {
                    displayqueuedetailscreen : false,
                    displayqueuelistscreen : true
                }
        });
        this.dispatchEvent(backEvent);
    }
    selectMemberType(event) {
        this.displayspinner = true;
        this.selectedMemberType = event.detail.value;
    }
    handleChange(event) {
        const selectedOptions = event.detail.value;
        var is_same = (selectedOptions.length == this.originalMember.length) && this.originalMember.every(function(element, index) {
            return selectedOptions.includes(element); 
        });
        this.values = selectedOptions;
        this.queueNotUpdated = is_same;
    }
    saveQueue(event) {
        this.displayspinner = true;
        saveQueueMember({selectedMembers: this.values,queueDetailsInst: JSON.stringify(this.queueDetails),memberType: this.selectedMemberType})
        .then((result) => {
            var status = result.status;
            var msgRes = result.message;                
            refreshApex(this.wiredQueueMemberReturn);
            this.displayspinner = false;
            this.queueNotUpdated = true; 
            const evt = new ShowToastEvent({
                title: status,
                message: msgRes,
                variant: status.toLowerCase(),
            });
            this.dispatchEvent(evt);
        })
        .catch((error) => {
            this.displayspinner = false;
            const evt = new ShowToastEvent({
                title: 'Error while saving!',
                message: 'Something went wrong. Please contact your System Administrator.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        })
    }
    viewAll(event){
        this.displayspinner = true;
        fetchAllQueueMembers({queueId: this.queueId})
        .then((result) => {
            this.displayAll = true;
            this.displayspinner = false;
            this.memberdata = result;
            this.error = undefined;
        })
        .catch((error)=>{
            this.error = error;
            this.memberdata = undefined;
            this.displayspinner = false;
        })

    }
    editQueue(event) {
        this.displayAll=false;
    }
    connectedCallback() {
        refreshApex(this.wiredQueueMemberReturn); 
    }
    renderedCallback() {
        /*if(this.displayDetails == true){
           getQueueData({queueIdDetails: this.queueId})
            .then((result) => {
                
                var items = [];
                items.push({label : '1st',value:'First'});
                items.push({label : '2nd',value:'Second'});
                console.log('in rendered callback'+JSON.stringify(result));
                this.queueDetails = result;
                console.log('in rendered callback'+JSON.stringify(this.userList));
                this.error = undefined;
                var items = [];
                console.log(this.userList.length+'userList'+JSON.stringify(this.userList));
                for (let i = 0; i < this.userList.length; i++) {
                    items.push({
                        label: this.userList[i].Name,
                        value: this.userList[i].Id,
                    });
                }
                console.log('items'+JSON.stringify(items));
                if(this.queueDetails.queueGroupMembers != undefined){
                    for (let i = 0; i < this.queueDetails.queueGroupMembers.length; i++) {
                        items.push({
                            label: this.queueDetails.queueGroupMembers[i].userGroupName,
                            value: this.queueDetails.queueGroupMembers[i].userGroupId,
                        });
                    }
                }
                console.log('items'+JSON.stringify(items));
                this.options.push(...items);
                console.log('options'+JSON.stringify(this.options));
                //this.values.push(this.queueDetails.queueGroupMembers);
                //this.values.push(this.queueDetails.queueUserMembers);
            })
            .catch((error) => {
                this.error = error;
                this.queueDetails = undefined;
            })
        }*/
    }
}