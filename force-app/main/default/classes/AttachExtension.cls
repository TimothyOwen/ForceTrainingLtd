public class AttachExtension {
    private final InvoiceC__c invoiceRecord;
    public AttachExtension(ApexPages.StandardController standardController) {
        this.invoiceRecord = (InvoiceC__c) standardController.getRecord();
    }
    public PageReference attachPDF(){
        InvoiceC__c invoice = [Select RecordType.Name, Invoice_ID__c, Course__r.Id, IsPDFGenerated__c from InvoiceC__c WHERE Id = :invoiceRecord.Id LIMIT 1];
        String partialURL = '/apex/'+invoice.RecordType.Name+'InvoicePDF?id='+invoice.Id;  
        PageReference pdf = new PageReference(partialURL);
        Attachment attachment = new Attachment();
        Blob body;
        try{
            body = pdf.getContent();
        }catch(Exception e){
            body = Blob.valueOf('Exception occurred'); 
            System.debug('GetContent: '+e);
        }
        attachment.Body = body;
        attachment.Name = 'Invoice: '+invoice.Invoice_ID__c;
        attachment.isPrivate = false;
        attachment.ParentId = invoice.Course__r.Id;
        List<Attachment> oldAttachments = new List<Attachment>();
        oldAttachments = [SELECT Name FROM Attachment WHERE Name = :attachment.Name];
        if(oldAttachments.size() == 0){
            insert attachment;
        }else{
            delete oldAttachments;
            insert attachment;
        }
        invoice.IsPDFGenerated__c = true;
        update invoice;
        return pdf;
    }
}
