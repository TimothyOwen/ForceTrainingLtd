trigger InvoiceTrigger on InvoiceC__C (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
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
            
        }
        if(Trigger.isUpdate){
            InvoiceTriggerHandler.invoiceEmail(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
           
        }
    }
}