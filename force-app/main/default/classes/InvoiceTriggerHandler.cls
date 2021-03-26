public with sharing class InvoiceTriggerHandler {
    public static void invoiceEmail(List<InvoiceC__c> newInvoices, Map<Id, InvoiceC__c> oldMap){
        for(InvoiceC__c invoice : newInvoices){
            if(invoice.Status__c == 'Submitted' && invoice.Status__c != oldMap.get(invoice.Id).Status__c){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                List<String> toAddresses = new List<String>();
                toAddresses.add('t32.owen@gmail.com');
                PageReference vfPage = Page.ExpenseInvoicePDF;
                if(invoice.RecordType.Name == 'Service'){
                    vfPage = Page.ServiceInvoicePDF;
                }
                vfPage.getParameters().put('id',invoice.Id);
                vfPage.setRedirect(true);
                //Blob body = vfPage.getContentAsPDF();
                attachment.setFileName('Invoice.pdf');
                //attachment.setBody('There is');
                email.setSubject('Invoice Submitted');
                email.setToAddresses(toAddresses);
                email.setPlainTextBody('Please find the attached invoice.');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                System.debug('Success');
                System.debug(invoice);
            }
        }
    }
}
