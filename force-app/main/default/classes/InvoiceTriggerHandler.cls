public with sharing class InvoiceTriggerHandler {
    public static void invoiceEmail(List<InvoiceC__c> newInvoices, Map<Id, InvoiceC__c> oldMap){
        for(InvoiceC__c invoice : newInvoices){
            if(invoice.Status__c == 'Submitted' && invoice.Status__c != oldMap.get(invoice.Id).Status__c){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                Email_Log__c emailLog = new Email_Log__c();
                List<String> toAddresses = new List<String>();
                toAddresses.add('t32.owen@gmail.com');
                PageReference vfPage = Page.ExpenseInvoicePDF;
                if(invoice.RecordType.Name == 'Service'){
                    vfPage = Page.ServiceInvoicePDF;
                }
                vfPage.getParameters().put('id',invoice.Id);
                vfPage.setRedirect(true);
                String name = 'Invoice: '+invoice.Invoice_ID__c;
                Attachment attachment = [SELECT Name, Body FROM Attachment WHERE Name = :name LIMIT 1]; 
                //TRIGGER CANNOT GET CONTENT
                //Blob body = vfPage.getContentAsPDF();
                Blob body = attachment.Body;
                emailAttachment.setFileName('Invoice.pdf');
                emailAttachment.setBody(body);
                email.setSubject('Invoice Submitted');
                emailLog.Subject__c = email.getSubject();
                email.setToAddresses(toAddresses);
                email.setPlainTextBody('Dear Jason Peters,<br></br>Please find the submitted invoice for Invoice: '+invoice.Invoice_ID__c+' attached');
                emailLog.Body__c = email.getHtmlBody();
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{emailAttachment});
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                insert emailLog;
            }
        }
    }
}
