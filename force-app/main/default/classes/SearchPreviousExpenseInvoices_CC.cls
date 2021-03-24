public class SearchPreviousExpenseInvoices_CC {
    private Opportunity course;
    /*public void SearchPreviousExpenseInvoices_CC(){
        course = [SELECT Id, Name, Amount FROM Opportunity WHERE Id = '0064L000002Qb5DQAS'];
    }*/

    public List<InvoiceWrapper> invoiceList{
        get{
            Id expenseRecTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
            //UNSUREcourse = [SELECT Id, Name, Amount FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
            if(invoiceList == null){
                invoiceList = new List<InvoiceWrapper>();
                for(InvoiceC__c invoice : [SELECT Invoice_ID__C, Submitted_Date__c, Sub_Total__c, VAT__c 
                                        FROM InvoiceC__c WHERE RecordTypeId = :expenseRecTypeId]){
                    invoiceList.add(new InvoiceWrapper(invoice));
                }
            }
            return invoiceList;
        }
        set;
    }

    public void selectInvoice() {
        Id expenseRecTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        //InvoiceC__c newInvoice = new InvoiceC__c();
        for (InvoiceWrapper iw : invoiceList) {
            if (iw.checked) {
                System.debug('Course Selected: ' + iw.Invoice.Invoice_ID__C);
                //newInvoice.RecordTypeId = expenseRecTypeId;
                //newInvoice.Course__c = ApexPages.currentPage().getParameters().get('id');
                //newInvoice.Status = 'Scheduled';
                //for(InvoiceLine__c invoiceLine: iw.Invoice.Invo)
            }
        }
        System.debug('Success');
    }


    public class InvoiceWrapper {
        public InvoiceC__c Invoice {get; set;}
        public Boolean checked {get; set;}

        public InvoiceWrapper(InvoiceC__c i){
            Invoice = i;
            checked = false;
        }
    }
}
