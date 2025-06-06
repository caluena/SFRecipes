public with sharing class PL_ProcessLogBO {
    
    private static final PL_ProcessLogBO instance = new PL_ProcessLogBO();

    public static PL_ProcessLogBO getInstance() {
        return instance;
    }

    public void createProcessLogRecord(List<ProcessLogRecords__e> listLogs){

        List<ProcessLog__c> listProcessLog = new List<ProcessLog__c>();

        for (ProcessLogRecords__e logRecord : listLogs) {
            listProcessLog.add(this.parseProcessLogFromProcessLogRecord(logRecord));
        }

        if (!listProcessLog.isEmpty()) insert listProcessLog;
    }

    private ProcessLog__c parseProcessLogFromProcessLogRecord(ProcessLogRecords__e logRecord){
        return new ProcessLog__c(
            RequestDirection__c = logRecord.RequestDirection__c,
            Endpoint__c = logRecord.Endpoint__c,
            InternalError__c = logRecord.InternalError__c,
            Header__c = logRecord.Header__c,
            RecordId__c = logRecord.RecordId__c,
            Method__c = logRecord.Method__c,
            ProcessName__c = logRecord.ProcessName__c,
            Request__c = logRecord.Request__c,
            Response__c = logRecord.Response__c,
            StatusCode__c = logRecord.StatusCode__c,
            Type__c = logRecord.Type__c
        );
    }
}