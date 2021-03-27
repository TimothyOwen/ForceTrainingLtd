@isTest
public class PreviousExpenseInvoices_CC_Test {
    @TestSetup
    static void testData(){
        PageReference page = Page.success;
        Test.setCurrentPage(page);
        //
        InvoiceC__c testOldInvoice = new InvoiceC__c();
        insert testOldInvoice;
        Course__c testCourse = new Course__c();
        insert testCourse;
    }
    @isTest
    static void searchValidData(){   
        ApexPages.currentPage().getParameters().put('id',testCourse.Id);
        PreviousExpenseInvoices_CC controller = new PreviousExpenseInvoices_CC();
        PageReference recievedPageReference = controller.selectInvoice();
        InvoiceC__c testNewInvoice = [SELECT Id FROM InvoiceC__C WHERE Course__c = :testCourse.Id];
        String expectedURL = '/lightning/r/Opportunity/'+testNewInvoice.Id+'/view';
        PageReference expectedPageReference = new PageReference(expectedURL); 
        System.assertEquals(expectedPageReference, recievedPageReference);
    }
    //searchInvalidData
    //checkInvoiceCloned
}
