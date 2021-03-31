@isTest
public class InvoiveTriggerHandler_Test {
    @TestSetup
    static void testData(){
        User testUser = new User(FirstName='Mary',LastName='Stevens',Email='test@forcetraining.com',Alias='test',
                                    Username='mstevtest@forcetraining.com',TimeZoneSidKey='Europe/London',LocaleSidKey='en_GB',
                                    EmailEncodingKey='UTF-8',ProfileId='00e4L000000pA9LQAU',LanguageLocaleKey='en_US');
        insert testUser;

        Opportunity testCourse = new Opportunity(Name='Test',Type='ADX201',StageName='Scheduled',Instructor__c=testUser.Id,
                                                        Start_Date__c=Date.today(), CloseDate=Date.today().addDays(5));
        insert testCourse;
        
    }

    @isTest
    static void positiveCaseUpdate(){
        Id serviceRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Opportunity testCourse = [SELECT Id FROM Opportunity LIMIT 1];
        List<InvoiceC__c> invoicesToInsert = new List<InvoiceC__c>();
        
        for(Integer i=0; i<201; i++){
            InvoiceC__c invoice = new InvoiceC__c(RecordTypeId=serviceRecordTypeId, Course__c=testCourse.Id, Status__c='Draft');
            invoicesToInsert.add(invoice);     
        }
        insert invoicesToInsert;
        
        InvoiceC__c invoice = [SELECT Name, Invoice_ID__c FROM InvoiceC__C WHERE RecordTypeId=:serviceRecordTypeId LIMIT 1];
        invoice.Status__c = 'Submitted';
        Invoice.IsPDFGenerated__c = true;
        Invoice.Submitted_Date__c = Date.today();
        
        Blob body = Blob.valueOf('Test: '+invoice.Invoice_ID__C);
        Attachment attachment = new Attachment();
        attachment.Body = body;
        attachment.Name = 'Invoice: '+invoice.Invoice_ID__C;
        attachment.isPrivate = false;
        attachment.ParentId = testCourse.Id;
        insert attachment;
        
        Email_Log__c emailLog = new Email_Log__c();
        emailLog.Body__c = 'Test: '+invoice.Invoice_ID__c;
        emailLog.Subject__c = 'Invoice Submitted';
        
        Test.startTest();
        update invoice;
        Test.stopTest();
        
        Email_Log__c recievedEmailLog = [SELECT Body__c, Subject__c FROM Email_Log__c
                                            WHERE Subject__c = 'Invoice Submitted'];

        System.assertEquals(emailLog.Subject__c, recievedEmailLog.Subject__C);
        //System.assertEquals(emailLog.Body__c, recievedEmailLog.Body__c);

    }
}
