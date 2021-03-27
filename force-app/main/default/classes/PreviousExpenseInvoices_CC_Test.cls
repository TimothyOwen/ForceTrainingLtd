@isTest
public class PreviousExpenseInvoices_CC_Test {
    @TestSetup
    static void testData(){
        Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        User testUser = new User(FirstName='Mary',LastName='Stevens',Email='test@forcetraining.com',Alias='test',Username='mstevtest@forcetraining.com',TimeZoneSidKey='Europe/London',LocaleSidKey='en_GB',EmailEncodingKey='UTF-8',ProfileId='00e4L000000pA9LQAU',LanguageLocaleKey='en_US');
        insert testUser;
        Opportunity testCourse = new Opportunity(Name='Test',Instructor__c=testUser.Id,StageName='Scheduled',Start_Date__c=Date.today(),CloseDate=Date.today().addDays(10));
        insert testCourse;
        InvoiceC__c testOldInvoice = new InvoiceC__c(RecordTypeId=expenseRecordTypeId,Course__c=testCourse.Id,Status__c='Draft');
        insert testOldInvoice;
    }
    @isTest
    static void searchValidData(){   
        PreviousExpenseInvoices_CC controller = new PreviousExpenseInvoices_CC();
        //Opportunity testCourse = [SELECT Id FROM Opportunity];
        //InvoiceC__c testInvoice = [SELECT Id FROM InvoiceC__c];
        Test.setCurrentPage(Page.PreviousExpenseInvoices);
        ApexPages.currentPage().getParameters().put('id',testCourse.Id);
        PageReference recievedPageReference = controller.selectInvoice();
        System.debug(controller.invoiceList);
        InvoiceC__c testNewInvoice = [SELECT Id FROM InvoiceC__C WHERE Course__c = :testCourse.Id];
        String expectedURL = '/lightning/r/Opportunity/'+testNewInvoice.Id+'/view';
        PageReference expectedPageReference = new PageReference(expectedURL); 
        System.assertEquals(expectedPageReference, recievedPageReference);
    }
    //searchInvalidData
    //checkInvoiceCloned
}
