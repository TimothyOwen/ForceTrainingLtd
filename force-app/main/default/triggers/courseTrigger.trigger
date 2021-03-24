trigger courseTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){

        }
        if(Trigger.isUpdate){

        }
        if(Trigger.isDelete){
            
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CourseTriggerHandler.CourseShare(Trigger.new);
            CourseTriggerHandler.CourseEvent(Trigger.new, Trigger.isUpdate);
            CourseTriggerHandler.CourseEmail(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }
        if(Trigger.isUpdate){
            CourseTriggerHandler.CourseEvent(Trigger.new, Trigger.isUpdate);
            CourseTriggerHandler.CourseEmail(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }
        if(Trigger.isDelete){
            CourseTriggerHandler.CourseEmail(Trigger.old, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        }
    }
}