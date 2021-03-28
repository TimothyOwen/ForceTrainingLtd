trigger CourseTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){

        }
        if(Trigger.isUpdate){

        }
        if(Trigger.isDelete){
            CourseTriggerHandler.courseEmail(Trigger.old, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CourseTriggerHandler.courseShare(Trigger.new);
            CourseTriggerHandler.courseEvent(Trigger.new, Trigger.isUpdate);
            CourseTriggerHandler.courseEmail(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }
        if(Trigger.isUpdate){
            CourseTriggerHandler.courseServiceInvoice(Trigger.new, Trigger.oldMap);
            CourseTriggerHandler.courseEvent(Trigger.new, Trigger.isUpdate);
            CourseTriggerHandler.courseEmail(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }
        if(Trigger.isDelete){
            
        }
    }
}