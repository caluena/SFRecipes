trigger PL_ProcessLogRecordTrigger on ProcessLogRecords__e (after insert) {
	
	if (PL_ProcessLogRecordTriggerHandler.isTriggerEnabled()){
		PL_ProcessLogRecordTriggerHandler handler = new PL_ProcessLogRecordTriggerHandler(
			Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
		);

		switch on Trigger.operationType {
			when AFTER_INSERT{
				handler.afterInsert();
			}
		}
	}
}