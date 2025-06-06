public with sharing class PL_ProcessLogRecordTriggerHandler{

    private static Boolean runTrigger;
    static{
    	  runTrigger = true;
    }

    public List<ProcessLogRecords__e> oldRecords {get; set;}
    public List<ProcessLogRecords__e> newRecords {get; set;}
    public Map<Id, ProcessLogRecords__e> oldMap {get; set;}
    public Map<Id, ProcessLogRecords__e> newMap {get; set;}

    public PL_ProcessLogRecordTriggerHandler (List<ProcessLogRecords__e> oldRecords, List<ProcessLogRecords__e> newRecords, Map<Id, ProcessLogRecords__e> oldMap, Map<Id, ProcessLogRecords__e> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords ;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public static Boolean isTriggerEnabled(){ return runTrigger; }
    public static Boolean enableTrigger(){ return runTrigger = true; }
    public static Boolean disableTrigger(){ return runTrigger = false; }

    public void afterInsert() {
        PL_ProcessLogBO.getInstance().createProcessLogRecord(Trigger.new);
    }
}