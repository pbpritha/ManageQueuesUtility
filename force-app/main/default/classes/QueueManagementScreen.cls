/*
* File Name   : QueueManagementScreen
* Description  : Controller class for Manage Queue Utility
* @author     : pbpritha@gmail.com
*------------------------------------------------------------------------------------
* Modification Log:
* Name              Date            Description             
*/
public without sharing class QueueManagementScreen {
    public QueueManagementScreen() {

    }
    /*
    Description : Wrapper class to contain all types of member in a single instance
    Author : pbpritha@gmail.com
    */
    public class QueueDetails {
        @AuraEnabled
        public String queueId;        
        @AuraEnabled
        public List<UserGroupDetails> queueUserMembers;
        @AuraEnabled
        public List<UserGroupDetails> queueGroupMembers;
        @AuraEnabled
        public List<UserGroupDetails> queueRoleMembers;
        @AuraEnabled
        public List<UserGroupDetails> queueRoleIntSubMembers;
        @AuraEnabled
        public List<UserGroupDetails> queueRoleSubMembers;
        public QueueDetails(String queueId, List<UserGroupDetails> queueUserMembers, List<UserGroupDetails> queueGroupMembers, List<UserGroupDetails> queueRoleMembers, List<UserGroupDetails> queueRoleIntSubMembers, List<UserGroupDetails> queueRoleSubMembers){
            this.queueId = queueId;
            this.queueUserMembers = queueUserMembers;
            this.queueGroupMembers = queueGroupMembers;
            this.queueRoleMembers = queueRoleMembers;
            this.queueRoleIntSubMembers = queueRoleIntSubMembers;
            this.queueRoleSubMembers = queueRoleSubMembers;
        }
        public QueueDetails(){}
    }
    public class UserGroupDetails {
        @AuraEnabled
        public String memberName ;
        @AuraEnabled
        public Id memberId;
        public UserGroupDetails(String memberName, Id memberId) {
            this.memberName = memberName;
            this.memberId = memberId;
        }
    }
    public class MemberOptions {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        public MemberOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
        public MemberOptions() {}
    }
    
    /*
    Description : Wired method to return sorted(asc,desc) list of all queues
    Author : pbpritha@gmail.com
    Method Name : getQueues
    Input Params : Sort order for Queue listview
    Output : sorted List of queue
    */
    @AuraEnabled(cacheable = true)
    public static List<Group> getQueues(String sortorder){
        String type = 'Queue';
        String fieldName = 'Name';
        String queryString = 'Select Id, Name , DeveloperName, Email from Group where type = \'';
        queryString += String.escapeSingleQuotes(type) + '\'';
        queryString +='ORDER BY '+fieldName+' '+sortorder;
        return Database.query(queryString);
    }
    /*
    Description : Wired method to return list of all active and non-system users
    Author : pbpritha@gmail.com
    Method Name : getUsers
    Input Params : no params
    Output : All list of active, non-system users formatted as the wrapper class MemberOptions
    */
    @AuraEnabled(cacheable = true)
    public static List<MemberOptions> getUsers(){
        List<MemberOptions> userWrapper = new List<MemberOptions>();
        for(User usr : [SELECT Id, Name from User WHERE IsActive=true AND Name NOT IN ('Automated Process', 'Chatter Expert','System', 'Platform Integration User') ORDER BY Name]) {
            userWrapper.add(new MemberOptions(usr.Name, usr.Id));
        }
        return userWrapper;
    }
    /*
    Description : Wired method to return list of all public groups
    Author : pbpritha@gmail.com
    Method Name : getGroups
    Input Params : no params
    Output : All list of public groups formatted as the wrapper class MemberOptions
    */
    @AuraEnabled(cacheable = true)
    public static List<MemberOptions> getGroups(){
        return getAllGroups(new List<String>{'Regular','AllCustomerPortal','Organization'});
    }

    /*
    Description : Wired method to return list of all roles
    Author : pbpritha@gmail.com
    Method Name : getRoles
    Input Params : no params
    Output : All list of roles formatted as the wrapper class MemberOptions
    */
    @AuraEnabled(cacheable = true)
    public static List<MemberOptions> getRoles(){
        return getAllGroups(new List<String>{'Role'});
    }
    /*
    Description : Wired method to return list of all roles and internal subordinated
    Author : pbpritha@gmail.com
    Method Name : getRolesIntSub
    Input Params : no params
    Output : All list of roles and internal subordinated formatted as the wrapper class MemberOptions
    */
    @AuraEnabled(cacheable = true)
    public static List<MemberOptions> getRolesIntSub(){
        return getAllGroups(new List<String>{'RoleAndSubordinatesInternal'});
    }
    /*
    Description : Wired method to return list of all roles, internal and portal subordinated
    Author : pbpritha@gmail.com
    Method Name : getRolesSub
    Input Params : no params
    Output : All list of roles, internal and portal subordinated formatted as the wrapper class MemberOptions
    */
    @AuraEnabled(cacheable = true)
    public static List<MemberOptions> getRolesSub(){
        return getAllGroups(new List<String>{'RoleAndSubordinates'});
    }
    /*
    Description : common code made into a medhod for modular code
    Author : pbpritha@gmail.com
    Method Name : getMembers
    Input Params : Set of queue Group Member Ids, Type of Member
    Output : List of Wrapper class: UserGroupDetails
    */
    public static List<MemberOptions> getAllGroups(List<String> type) {
        List<MemberOptions> roleWrapper = new List<MemberOptions>();
        for(Group grp : [SELECT Id, Related.Name, Name, Type from Group WHERE Type IN: type ORDER BY Name]) {
            String name =  grp.Type=='Organization'?'All Internal Users' :(grp.Type=='AllCustomerPortal'? 'All Customer Portal Users':(grp.Type=='Regular'?grp.Name:grp.Related.Name ));
            roleWrapper.add(new MemberOptions(name, grp.Id));
        }
        return roleWrapper;
    }
    /*
    Description : Wired method to return Objects supported by a queue
    Author : pbpritha@gmail.com
    Method Name : getQueueObjects
    Input Params : Id of the queue
    Output : List of Object Labels supported by the Queue
    */
    @AuraEnabled(cacheable = true)
    public static List<String> getQueueObjects (String queueIdDetails) {
        List<String> queueObjects = new List<String>();
        List<String> objAPIList = new List<String>();
        for(QueueSobject obj : [SELECT Id, SobjectType, QueueId FROM QueueSobject WHERE QueueId =: queueIdDetails]) {
            String objAPI = obj.SobjectType == null?'':obj.SobjectType;
            objAPIList.add(objAPI);
        }
        if(!objAPIList.isEmpty()) {
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(objAPIList); 
            for(Schema.DescribeSObjectResult res : describeSobjectsResult) {
                queueObjects.add(res.getLabel());
            }
        }
        return queueObjects;
    }
    /*
    Description : Wired method to return different type of member list
    Author : pbpritha@gmail.com
    Method Name : getQueueData
    Input Params : Id of the queue, tyme of member selected
    Output : All the members of the type already in the queue in the wrapper class format: QueueDetails
    */
    @AuraEnabled(cacheable = true)
    public static QueueDetails getQueueData (String queueIdDetails, String memberType) {
        List<GroupMember> groupMemList = new List<GroupMember>();
        Set<Id> queueUserIdSet = new Set<Id>();
        Set<Id> queueGroupIdSet = new Set<Id>();
        List<UserGroupDetails> queueUserList = new List<UserGroupDetails>();
        List<UserGroupDetails> queueGroupList = new List<UserGroupDetails>();        
        List<UserGroupDetails> queueRoleList = new List<UserGroupDetails>();        
        List<UserGroupDetails> queueRoleIntSubList = new List<UserGroupDetails>();
        List<UserGroupDetails> queueRoleSubList = new List<UserGroupDetails>();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        //create seperate list for each type of members
        groupMemList = [Select UserOrGroupId From GroupMember where GroupId =:queueIdDetails];
        if(!groupMemList.isEmpty()){
            for(GroupMember member: groupMemList){
                if(String.valueOf(member.UserOrGroupId).startsWith('00G')){
                    queueGroupIdSet.add(member.UserOrGroupId);
                }
                if(String.valueOf(member.UserOrGroupId).startsWith('005')){
                    queueUserIdSet.add(member.UserOrGroupId);
                }
            }
            switch on memberType {
                when 'users' {
                    userList = [SELECT Id, Name from User WHERE Id IN: queueUserIdSet AND isActive = true];
                    for(User usr : userList) {
                        UserGroupDetails details = new UserGroupDetails(usr.Name,usr.Id);
                        queueUserList.add(details);
                    }
                }
                when 'publicGroups' {
                    queueGroupList = getMembers(queueGroupIdSet, new List<String>{'Regular','AllCustomerPortal','Organization'});
                }
                when 'roles' {
                    queueRoleList = getMembers(queueGroupIdSet,new List<String>{'Role'});
                }
                when 'rolesIntSub' {
                    queueRoleIntSubList = getMembers(queueGroupIdSet,new List<String>{'RoleAndSubordinatesInternal'});
                }
                when 'rolesIntPorSub' {
                    queueRoleSubList = getMembers(queueGroupIdSet,new List<String>{'RoleAndSubordinates'});
                }
            }
        }
        
        QueueDetails queueDetailsInst = new QueueDetails(queueIdDetails,queueUserList,queueGroupList,queueRoleList,queueRoleIntSubList,queueRoleSubList);
        return queueDetailsInst;
    } 
    /*
    Description : common code made into a medhod for modular code
    Author : pbpritha@gmail.com
    Method Name : getMembers
    Input Params : Set of queue Group Member Ids, Type of Member
    Output : List of Wrapper class: UserGroupDetails
    */
    public static List<UserGroupDetails> getMembers(Set<Id> queueGroupIdSet, List<String> typeValue) {
        List<UserGroupDetails> queueMem = new  List<UserGroupDetails>();
        List<Group> groupList = [SELECT Id, Name, DeveloperName, Related.Name,Type from Group WHERE Id IN: queueGroupIdSet AND Type IN: typeValue];
        for(Group grp : groupList) {
            String name =  grp.Type=='Organization'?'All Internal Users' :(grp.Type=='AllCustomerPortal'? 'All Customer Portal Users':(grp.Type=='Regular'?grp.Name:grp.Related.Name ));
            UserGroupDetails details = new UserGroupDetails(name,grp.Id);
            queueMem.add(details);
        }
        return queueMem;
    }
    /*
    Description : common code made into a medhod for modular code
    Author : pbpritha@gmail.com
    Method Name : createAddedAndDeletedMemberList
    Input Params : existing Queue Member details , all selected members, queue id, new members to be added, existing members to be deleted
    Output : void
    */
    public static void createAddedAndDeletedMemberList(List<UserGroupDetails> queueMemberDetails, List<String> selectedMembers, String queueId, List<GroupMember> newMemberList, List<GroupMember> deleteMemberList) {
        List<Id> deleteMember = new List<Id>();
        Set<String> existingMemberID = new Set<String>();
        //Creating set of all existing member Ids
        for(UserGroupDetails details : queueMemberDetails) {
            existingMemberID.add(details.memberId);
        }
        //retrieving the list of new members to be added to queue
        for(String memberId: selectedMembers ) {
            if(!existingMemberID.contains(memberId)) {
                newMemberList.add(new GroupMember(UserOrGroupId = memberId, GroupId = queueId));
            }
        }
        //retrieving the list of members to be deleted from queue
        for(String memberId: existingMemberID ) {
            if(!selectedMembers.contains(memberId)) {
                deleteMember.add(memberId);
            }
        }
        if(!deleteMember.isEmpty()) {
            deleteMemberList.addAll([Select Id FROM GroupMember WHERE GroupId =: queueId AND UserOrGroupId IN: deleteMember]);
        }
    }    
    /*
    Description : Imperetive method to save updated list of members
    Author : pbpritha@gmail.com
    Method Name : saveQueueMembers
    Input Params : all selected members, existing Queue Member details , type of member being updated
    Output : Map of update status and message
    */
    @AuraEnabled
    public static Map<String,String> saveQueueMembers (List<String> selectedMembers, String queueDetailsInst, String memberType) {
        Map<String,String> returnmessage = new Map<String,String>();
        Set<String> existingMemberID = new Set<String>();
        List<Id> deleteMember = new List<Id>();
        List<GroupMember> newMemberList = new List<GroupMember>();
        List<GroupMember> deleteMemberList = new List<GroupMember>();
        QueueDetails queueMembers = new QueueDetails();
        if(String.isNotBlank(queueDetailsInst)) {
            queueMembers = (QueueDetails)JSON.deserialize(queueDetailsInst, QueueDetails.class);
            if(!queueMembers.queueUserMembers.isEmpty() && memberType == 'users') {
                //retrieve the new user list and deleted user list
                createAddedAndDeletedMemberList(queueMembers.queueUserMembers,selectedMembers,queueMembers.queueId,newMemberList,deleteMemberList);
            }
            else if(!queueMembers.queueGroupMembers.isEmpty() && memberType == 'publicGroups') {
                createAddedAndDeletedMemberList(queueMembers.queueGroupMembers,selectedMembers,queueMembers.queueId,newMemberList,deleteMemberList);
            }
            else if(!queueMembers.queueRoleMembers.isEmpty() && memberType == 'roles') {
                createAddedAndDeletedMemberList(queueMembers.queueRoleMembers,selectedMembers,queueMembers.queueId,newMemberList,deleteMemberList);
            }
            else if(!queueMembers.queueRoleIntSubMembers.isEmpty() && memberType == 'rolesIntSub') {
                createAddedAndDeletedMemberList(queueMembers.queueRoleIntSubMembers,selectedMembers,queueMembers.queueId,newMemberList,deleteMemberList);
            }
            else if(!queueMembers.queueRoleSubMembers.isEmpty() && memberType == 'rolesIntPorSub') {
                createAddedAndDeletedMemberList(queueMembers.queueRoleSubMembers,selectedMembers,queueMembers.queueId,newMemberList,deleteMemberList);
            }
            else {
                for(String userId: selectedMembers ) {
                    newMemberList.add(new GroupMember(UserOrGroupId = userId, GroupId = queueMembers.queueId));
                }
            }
            try {
                insert newMemberList;
                delete deleteMemberList;
                returnmessage.put('status','Success');
                returnmessage.put('message','Queue updated successfully.');
            }
            catch(Exception e) {
                returnmessage.put('status','Error');
                returnmessage.put('message','Failed to add Member to Queue. Please contact Administrator');
            }

        }
        else {
            returnmessage.put('status','Error');
            returnmessage.put('message','Something went wrong. Please contact Administrator');
        }
        return returnmessage;
    }
    /*
    Description : wired method to fetch all types of members for a queue for View All screen
    Author : pbpritha@gmail.com
    Method Name : fetchAllQueueMembers
    Input Params : Queue Id
    Output : List of Map of member details
    */
    @AuraEnabled
    public static List<Map<String,String>> fetchAllQueueMembers(String queueId) {
        Set<Id> userIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        List<Map<String,String>> allmembers = new List<Map<String,String>>();
        for(GroupMember member : [SELECT UserorGroupId FROM GroupMember WHERE GroupId =: queueId]) {
            if(String.valueOf(member.UserOrGroupId).startsWith('00G')){
                groupIds.add(member.UserOrGroupId);
            }
            if(String.valueOf(member.UserOrGroupId).startsWith('005')){
                userIds.add(member.UserOrGroupId);
            }
        }
        if(!userIds.isEmpty()){
            for(User usr: [SELECT Name FROM User WHERE Id IN: userIds]) {
                Map<String,String> details = new Map<String,String>();
                details.put('Id',usr.Id);
                details.put('Name',usr.Name);
                details.put('Type','User');
                allmembers.add(details);
            }
        }
        if(!groupIds.isEmpty()){
            for(Group grp: [SELECT Name,Related.Name,DeveloperName, Type FROM Group WHERE Id IN: groupIds]) {
                Map<String,String> details = new Map<String,String>();
                details.put('Id',grp.Id);
                if(grp.Type == 'RoleAndSubordinatesInternal') {
                    details.put('Name',grp.Related.Name);
                    details.put('Type','Role and Internal Subordinates');
                }
                else if(grp.Type == 'RoleAndSubordinates') {
                    details.put('Name',grp.Related.Name);
                    details.put('Type','Role, Internal and Portal Subordinates');
                }
                else if(grp.Type == 'Regular' || grp.Type == 'AllCustomerPortal' || grp.Type == 'Organization') {
                    String devName = grp.DeveloperName=='AllInternalUsers'?'All Internal Users' :(grp.DeveloperName=='AllCustomerPortalUsers'? 'All Customer Portal Users':'');
                    grp.Name = grp.Name == null? devName : grp.Name;
                    details.put('Name',grp.Name);
                    details.put('Type','Public Group');
                }
                else {
                    details.put('Name',grp.Related.Name);
                    details.put('Type',grp.Type);
                }
                allmembers.add(details);
            }
        }
        return allmembers;
    }
    
}