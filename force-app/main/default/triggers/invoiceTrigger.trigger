trigger invoiceTrigger on InvoiceC__C (before insert, after insert, before update, after update, before delete, after delete) {
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
            //InvoiceTriggerHandler.sendEmailWithInvoice(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
           
        }
    }
}