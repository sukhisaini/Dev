public virtual class TriggerHandler {

	protected List<SObject> oldRecords;
	protected List<SObject> newRecords;
	protected Map<Id, SObject> oldRecordsMap;

	public TriggerHandler(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
		this.oldRecords = Trigger.old;
		this.newRecords = newRecords;
		this.oldRecordsMap = oldRecordsMap;

		if (Trigger.isBefore) {
			if (Trigger.isInsert) {
				beforeInsert();
			} else if (Trigger.isUpdate) {
				beforeUpdate();
			} else if (Trigger.isDelete) {
				beforeDelete();
			}
		} else {
			if (Trigger.isInsert) {
				afterInsert();
			} else if (Trigger.isUpdate) {
				afterUpdate();
			} else if (Trigger.isDelete) {
				afterDelete();
			} else if (Trigger.isUndelete) {
				afterUndelete();
			}
		}
	}

	protected virtual void beforeInsert() {
	}
	protected virtual void beforeUpdate() {
	}
	protected virtual void beforeDelete() {
	}

	protected virtual void afterInsert() {
	}
	protected virtual void afterUpdate() {
	}
	protected virtual void afterDelete() {
	}
	protected virtual void afterUndelete() {
	}
}
