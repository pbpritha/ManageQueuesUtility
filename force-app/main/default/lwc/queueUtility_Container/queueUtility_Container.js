import { LightningElement,track,wire } from 'lwc';
import getUsers from '@salesforce/apex/QueueManagementScreen.getUsers';
import getGroups from '@salesforce/apex/QueueManagementScreen.getGroups';
import getRoles from '@salesforce/apex/QueueManagementScreen.getRoles';
import getRolesIntSub from '@salesforce/apex/QueueManagementScreen.getRolesIntSub';
import getRolesSub from '@salesforce/apex/QueueManagementScreen.getRolesSub';
import hasPermissionTemp from '@salesforce/customPermission/Custom_Manage_Queues';

export default class QueueUtility_Container extends LightningElement {
    displayDetails = false;
    displayList = true;
    queueDetailsId;
    queueDetailsName;
    users = [];
    groups = [];
    roles = [];
    rolesIntSubs = [];
    rolesSubs = [];
    get hasManageQueuePermission() {
        return hasPermissionTemp;
    }
    @wire (getUsers) 
    usersdata ({ error, data }) {
        if (data) {
            this.users = data;
            this.error = null;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    @wire (getGroups) 
    groupsdata ({ error, data }) {
        if (data) {
            this.groups = data;
            this.error = null;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    @wire (getRoles) 
    rolesdata ({ error, data }) {
        if (data) {
            this.roles = data;
            this.error = null;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    @wire (getRolesIntSub) 
    rolesIntSubsdata ({ error, data }) {
        if (data) {
            this.rolesIntSubs = data;
            this.error = null;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    @wire (getRolesSub) 
    rolesSubdata ({ error, data }) {
        if (data) {
            this.rolesSubs = data;
            this.error = null;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    handleEvent(event){
        this.displayDetails = event.detail.displayqueuedetails;
        this.displayList = event.detail.displayqueuelist;
        this.queueDetailsId = event.detail.queueId;
        this.queueDetailsName = event.detail.queueName;
    }
    handleBackEvent(event){
        this.displayDetails = event.detail.displayqueuedetailscreen;
        this.displayList = event.detail.displayqueuelistscreen;
    }
}