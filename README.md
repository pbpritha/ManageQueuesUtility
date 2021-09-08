# A Utility to Manage Queues, Add, Delete Users, Public Groups, Roles, Roles and Subordinates etc.
## Problem Statement
As Salesforce doesnt provide an out of the box feature to be able Manage Queues without the Customize Application permission. As a business users often the requirement is to modify the members in a queue. With the Customize Application permission, there are added permissions like modifying field-level security. This is a custom utlity to be able to manage queue members without the customize application permission.
## Setting up the component
1. This component can be added to Home page, Record page, App Page or on Utility Bar. Here is an example showing how to include the LWC component in the Utility bar.
![image](https://user-images.githubusercontent.com/54357119/132451080-305ea2af-b785-44ff-b208-fcefe3a88a86.png)

![image](https://user-images.githubusercontent.com/54357119/132451162-57e28654-484e-4af2-8ff6-2718eba6f234.png)

2. Assign the Permission set ManageQueueMembers to the user who require the functionality.
![image](https://user-images.githubusercontent.com/54357119/132451258-8fa84a49-7bf0-44cb-a3ca-094df5de292d.png)

For users without the permission set the utility displays the message 'You dont have permission to view this tab.

![image](https://user-images.githubusercontent.com/54357119/132451456-72a45d3b-6ef2-4ffa-a65b-fa2bacf326dc.png)

Once the Permission set is assigned, users would get the following view.

![image](https://user-images.githubusercontent.com/54357119/132451799-bb10f4ed-8f87-484d-91e3-2d2f4325f95c.png)







