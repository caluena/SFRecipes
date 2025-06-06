@isTest
public class PL_ProcessLogTest {

    @isTest
    static void testAfterInsertTrigger() {
        ProcessLogRecords__e logEvent = new ProcessLogRecords__e(
            RequestDirection__c = 'OUT',
            Endpoint__c = 'https://api.example.com/test',
            InternalError__c = 'Example error message',
            Header__c = '{"Authorization":"Bearer token"}',
            RecordId__c = '001000000000001AAA',
            Method__c = 'POST',
            ProcessName__c = 'TestProcess',
            Request__c = '{"test":"request"}',
            Response__c = '{"test":"response"}',
            StatusCode__c = 200,
            Type__c = 'Integration'
        );

        Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(new List<ProcessLogRecords__e>{ logEvent });
        Test.stopTest();

        for(Database.SaveResult saveResult : results){
            System.assertEquals(true, saveResult.isSuccess());
        }

        List<ProcessLog__c> logs = [SELECT Id, ProcessName__c, Endpoint__c FROM ProcessLog__c WHERE ProcessName__c = 'TestProcess'];
        Assert.areEqual(1, logs.size(), 'Deve ter criado um registro de log de processo');
        Assert.areEqual('https://api.example.com/test', logs[0].Endpoint__c);
    }

    @isTest
    static void testEnableDisableTriggerMethods() {
        Boolean disabled = PL_ProcessLogRecordTriggerHandler.disableTrigger();
        System.assertEquals(false, disabled, 'Trigger should be disabled');

        Boolean enabled = PL_ProcessLogRecordTriggerHandler.enableTrigger();
        System.assertEquals(true, enabled, 'Trigger should be enabled again');
    }
}
