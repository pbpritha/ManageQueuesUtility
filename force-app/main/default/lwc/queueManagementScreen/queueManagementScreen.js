import { LightningElement,wire,track,api} from 'lwc';
import getQueues from '@salesforce/apex/QueueManagementScreen.getQueues';
import { NavigationMixin } from 'lightning/navigation';

const columns = [

    { label: 'Name', fieldName: 'Name', type: 'text' , sortable: true },
    { label: 'DeveloperName', fieldName: 'DeveloperName' },
    {
        label: 'Action',
        type: 'button',
        initialWidth: 65,
        typeAttributes: {
            label: 'Edit',
            variant: 'base',
        }

    }
];
export default class QueueManagementScreen extends NavigationMixin(LightningElement) {
    @api displayComponent;
    data = [];
    allqueue = [];
    columns = columns;
    searchQueue = '';
    displayspinner = true;
    sortBy = 'Name';
    sortDirection = 'asc';
    @wire (getQueues,{sortorder:'$sortDirection'}) 
    queues ({ error, data }) {
        if (data) {
            this.data = data;
            this.allqueue = data;
            this.displayspinner = false;
            this.error = null;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    filterRecords(event) {
        var searchQueue = event.detail.value.toLowerCase();
        const allQueue = this.allqueue;
        if(searchQueue == '') {
            this.data = allQueue;
        }
        else {
            let startsWith = allQueue.filter(function (queue) {
                return queue.Name.toLowerCase().startsWith(searchQueue);
                //use this statement if want to return all queue name containing the search keyword
                //return queue.Name.toLowerCase().includes(searchQueue);
            });
            this.data = startsWith;
        }
    }
    doSorting(event) {
        this.displayspinner = true;
        this.sortDirection = event.detail.sortDirection;
    }
    navigateToQueueDetailPage(event) {
        this.record = event.detail.row;
        const queueEvent = new CustomEvent(
            'queuedetails',{    
                detail: {
                    displayqueuedetails: true,
                    displayqueuelist: false,
                    queueId: this.record.Id,
                    queueName: this.record.Name
                }
            });
        this.dispatchEvent(queueEvent);
       
    }
    
}