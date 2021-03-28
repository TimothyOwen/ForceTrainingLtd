@isTest
public class PreviousExpenseInvoices_CC_Test {
    @TestSetup
    static void testData(){
        Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        Id taxiRecordTypeId = Schema.SObjectType.InvoiceLine__c.getRecordTypeInfosByName().get('Taxi').getRecordTypeId();
        User testUser = new User(FirstName='Mary',LastName='Stevens',Email='test@forcetraining.com',Alias='test',Username='mstevtest@forcetraining.com',TimeZoneSidKey='Europe/London',LocaleSidKey='en_GB',EmailEncodingKey='UTF-8',ProfileId='00e4L000000pA9LQAU',LanguageLocaleKey='en_US');
        insert testUser;
        Opportunity testCourse = new Opportunity(Name='Test',Instructor__c=testUser.Id,StageName='Scheduled',Start_Date__c=Date.today(),CloseDate=Date.today().addDays(10));
        insert testCourse;
        InvoiceC__c testOldInvoice = new InvoiceC__c(RecordTypeId=expenseRecordTypeId,Course__c=testCourse.Id,Status__c='Draft');
        insert testOldInvoice;
        InvoiceLine__c testOldInvoiceLine = new InvoiceLine__c(RecordTypeId=taxiRecordTypeId,Date__c=Date.today().addDays(-2),Invoice__c=testOldInvoice.Id,Expense_Amount__c=50);
        insert testOldInvoiceLine;
    }
    @isTest
    static void positiveCase(){  
        Opportunity testCourse = [SELECT Id,Name,Instructor__c,Start_Date__c FROM Opportunity];
        InvoiceC__c testOldInvoice = [SELECT Id FROM InvoiceC__c LIMIT 1];
        Test.setCurrentPage(Page.PreviousExpenseInvoices);
        ApexPages.currentPage().getParameters().put('id',testCourse.Id); 
        PreviousExpenseInvoices_CC controller = new PreviousExpenseInvoices_CC();
        //
        System.assertEquals(testCourse.Id, controller.getCourse().Id);
        //
        controller.invoiceList[0].checked = true;
        PageReference recievedPageReference = controller.selectInvoice();
        InvoiceC__c testNewInvoice = [SELECT Id FROM InvoiceC__C WHERE Id <> :testOldInvoice.Id AND Course__c = :testCourse.Id];
        String expectedURL = '/lightning/r/Opportunity/'+testNewInvoice.Id+'/view';
        PageReference expectedPageReference = new PageReference(expectedURL); 
        //
        System.assertEquals(expectedPageReference.getURL(), recievedPageReference.getURL());
    }

    @isTest
    static void negativeCaseNoChecked(){
        Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        Opportunity testCourse = [SELECT Id,Name,Instructor__c,Start_Date__c FROM Opportunity];
        Test.setCurrentPage(Page.PreviousExpenseInvoices);
        ApexPages.currentPage().getParameters().put('id',testCourse.Id); 
        PreviousExpenseInvoices_CC controller = new PreviousExpenseInvoices_CC();
        //
        System.assertEquals(testCourse.Id, controller.getCourse().Id);
        //
        PageReference recievedPageReference = controller.selectInvoice();
        String expectedURL = '/apex/previousexpenseinvoices?id='+testCourse.Id;
        PageReference expectedPageReference = new PageReference(expectedURL);
        //
        System.assertEquals(expectedPageReference.getURL(), recievedPageReference.getURL());
    }

    @isTest
    static void negativeCaseTwoChecked(){
        Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        Opportunity testCourse = [SELECT Id,Name,Instructor__c,Start_Date__c FROM Opportunity];
        InvoiceC__c testOldInvoice = new InvoiceC__c(RecordTypeId=expenseRecordTypeId,Course__c=testCourse.Id,Status__c='Draft');
        insert testOldInvoice;
        //
        Test.setCurrentPage(Page.PreviousExpenseInvoices);
        ApexPages.currentPage().getParameters().put('id',testCourse.Id); 
        PreviousExpenseInvoices_CC controller = new PreviousExpenseInvoices_CC();
        //
        System.assertEquals(testCourse.Id, controller.getCourse().Id);
        //
        PageReference recievedPageReference = controller.selectInvoice();
        String expectedURL = '/apex/previousexpenseinvoices?id='+testCourse.Id;
        PageReference expectedPageReference = new PageReference(expectedURL);
        //
        System.assertEquals(expectedPageReference.getURL(), recievedPageReference.getURL());
    }
    
}
