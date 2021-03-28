@isTest
public with sharing class AttachExtension_Test {
    @TestSetup
    static void testData(){
        Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        User testUser = new User(FirstName='Mary',LastName='Stevens',Email='test@forcetraining.com',Alias='test',Username='mstevtest@forcetraining.com',TimeZoneSidKey='Europe/London',LocaleSidKey='en_GB',EmailEncodingKey='UTF-8',ProfileId='00e4L000000pA9LQAU',LanguageLocaleKey='en_US');
        insert testUser;
        Opportunity testCourse = new Opportunity(Name='Test',Instructor__c=testUser.Id,StageName='Scheduled',Start_Date__c=Date.today(),CloseDate=Date.today().addDays(10));
        insert testCourse;
        InvoiceC__c testInvoice = new InvoiceC__c(RecordTypeId=expenseRecordTypeId,Course__c=testCourse.Id,Status__c='Draft');
        insert testInvoice;
    }
    @isTest
    static void positiveCaseEmpty() {
        Test.setCurrentPage(Page.AttachInvoicePDF);
        InvoiceC__c testInvoice = [SELECT Id, Invoice_ID__c FROM InvoiceC__c LIMIT 1];
        ApexPages.StandardController standardController = new ApexPages.StandardController(testInvoice);
        ApexPages.currentPage().getParameters().put('id',testInvoice.Id);
        AttachExtension attachExtension = new AttachExtension(standardController);
        PageReference recieved = attachExtension.attachPDF();
        List<Attachment> attachments = [SELECT Name FROM Attachment];
        //
        System.assertEquals(1, attachments.size());
        for(Attachment attachment : attachments){
            System.assertEquals('Invoice: '+testInvoice.Invoice_ID__c, attachment.Name);
        }
    }

    @isTest
    static void positiveCaseOccupied() {
        Test.setCurrentPage(Page.AttachInvoicePDF);
        InvoiceC__c testInvoice = [SELECT Id, Invoice_ID__c, Course__r.Id FROM InvoiceC__c LIMIT 1];
        ApexPages.StandardController standardController = new ApexPages.StandardController(testInvoice);
        ApexPages.currentPage().getParameters().put('id',testInvoice.Id);
        //
        Attachment oldAttachment = new Attachment();
        Blob body = Blob.valueOf('Test');
        oldAttachment.Body = body;
        oldAttachment.Name = 'Invoice: '+testInvoice.Invoice_ID__c;
        oldAttachment.isPrivate = false;
        oldAttachment.ParentId = testInvoice.Course__r.Id;
        insert oldAttachment;
        //
        AttachExtension attachExtension = new AttachExtension(standardController);
        PageReference recieved = attachExtension.attachPDF();
        List<Attachment> attachments = [SELECT Name FROM Attachment];
        //
        System.assertEquals(1, attachments.size());
        for(Attachment attachment : attachments){
            System.assertEquals('Invoice: '+testInvoice.Invoice_ID__c, attachment.Name);
        }
    }
}
