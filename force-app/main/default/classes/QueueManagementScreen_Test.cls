/*
* File Name   : QueueManagementScreen_Test
* Description  : Test class for QueueManagementScreen.cls
* @author     : pbpritha@gmail.com
*------------------------------------------------------------------------------------
* Modification Log:
* Name              Date            Description             
*/
@isTest
private class QueueManagementScreen_Test {
    @testSetup static void setupQueueData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg123.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserqueuemanage@testorg.com',isActive=true);
        insert u;
        
    }
    @isTest static void getDataMethod(){
        List<Group> grpList = QueueManagementScreen.getQueues('asc');
        List<GroupMember> memList = new List<GroupMember>();
        List<Group> pgList = [SELECT Id, Related.Name, Name, Type from Group WHERE Type = 'Regular'];
        List<Group> roleList = [SELECT Id, Related.Name, Name, Type from Group WHERE Type = 'Role'];
        List<Group> roleSubList = [SELECT Id, Related.Name, Name, Type from Group WHERE Type = 'RoleAndSubordinatesInternal'];
        List<Group> roleIntSubList = [SELECT Id, Related.Name, Name, Type from Group WHERE Type = 'RoleAndSubordinates'];
        User usr = [Select Id from User where Email='standarduser@testorg123.com' Limit 1];
        GroupMember mem =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=usr.Id);
        memList.add(mem);
        GroupMember mem1 =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=roleList[0].Id);
        memList.add(mem1);
        GroupMember mem2 =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=roleSubList[0].Id);
        memList.add(mem2);
        GroupMember mem3 =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=roleIntSubList[0].Id);
        memList.add(mem3);
        GroupMember mem4 =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=pgList[0].Id);
        memList.add(mem4);
        insert(memList);
        Test.startTest();
        QueueManagementScreen.getGroups();
        QueueManagementScreen.getRoles();
        QueueManagementScreen.getRolesIntSub();
        QueueManagementScreen.getRolesSub();
        QueueManagementScreen.getUsers();
        QueueManagementScreen.fetchAllQueueMembers(grpList[0].Id);
        QueueManagementScreen.getQueueObjects(grpList[0].Id);
        
    }
    @isTest static void getQueueDataMethod(){
        List<Group> grpList = QueueManagementScreen.getQueues('asc');
        List<GroupMember> memList = new List<GroupMember>();
        List<Group> pgList = [SELECT Id, Related.Name, Name, Type from Group WHERE Type = 'Regular'];
        List<Group> roleList = [SELECT Id, Related.Name, Name, Type from Group WHERE Type = 'Role'];
        List<Group> roleSubList = [SELECT Id, Related.Name, Name, Type from Group WHERE Type = 'RoleAndSubordinatesInternal'];
        List<Group> roleIntSubList = [SELECT Id, Related.Name, Name, Type from Group WHERE Type = 'RoleAndSubordinates'];
        User usr = [Select Id from User where Email='standarduser@testorg123.com' Limit 1];
        GroupMember mem =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=usr.Id);
        memList.add(mem);
        GroupMember mem1 =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=roleList[0].Id);
        memList.add(mem1);
        GroupMember mem2 =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=roleSubList[0].Id);
        memList.add(mem2);
        GroupMember mem3 =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=roleIntSubList[0].Id);
        memList.add(mem3);
        GroupMember mem4 =  new GroupMember(GroupId=grpList[0].id,UserOrGroupId=pgList[0].Id);
        memList.add(mem4);
        insert(memList);
        Test.startTest();
        QueueManagementScreen.QueueDetails details = QueueManagementScreen.getQueueData(grpList[0].Id,'users');
        QueueManagementScreen.getQueueData(grpList[0].Id,'publicGroups');
        QueueManagementScreen.getQueueData(grpList[0].Id,'roles');
        QueueManagementScreen.getQueueData(grpList[0].Id,'rolesIntSub');
        QueueManagementScreen.getQueueData(grpList[0].Id,'rolesIntPorSub');
        System.debug(JSON.serialize(details));
        QueueManagementScreen.saveQueueMembers(new List<String>{usr.Id},JSON.serialize(details),'users');
        QueueManagementScreen.saveQueueMembers(new List<String>{pgList[0].Id},JSON.serialize(details),'publicGroups');
        QueueManagementScreen.saveQueueMembers(new List<String>{roleList[0].Id},JSON.serialize(details),'roles');
        QueueManagementScreen.saveQueueMembers(new List<String>{roleSubList[0].Id},JSON.serialize(details),'rolesIntSub');
        QueueManagementScreen.saveQueueMembers(new List<String>{roleIntSubList[0].Id},JSON.serialize(details),'rolesIntPorSub');
        Test.stopTest();
    }
}