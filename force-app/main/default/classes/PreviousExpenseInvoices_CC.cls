public class PreviousExpenseInvoices_CC {
    private Opportunity course;

    public PreviousExpenseInvoices_CC(){
        course = [SELECT Id, Name, Instructor__c, Instructor__r.Name, Start_Date__c FROM Opportunity
                    WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }

    public Opportunity getCourse(){
        return course;
    }

    public List<InvoiceWrapper> invoiceList{
        get{
            Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
            if(invoiceList == null){
                invoiceList = new List<InvoiceWrapper>();
                if(course.Instructor__c != null){
                    for(InvoiceC__c invoice : [SELECT Invoice_ID__C, Submitted_Date__c, Sub_Total__c, VAT__c, Course__r.Start_Date__c 
                                            FROM InvoiceC__c WHERE RecordTypeId = :expenseRecordTypeId AND Course__r.Instructor__c = :course.Instructor__c]){
                        invoiceList.add(new InvoiceWrapper(invoice));
                    }
                }
            }
            return invoiceList;
        }
        set;
    }

    public PageReference selectInvoice() {
        PageReference page = ApexPages.currentPage();
        Id expenseRecTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        InvoiceC__c invoice = new InvoiceC__c();
        List<InvoiceLine__c> invoiceLinesToInsert = new List<InvoiceLine__c>();
        Integer counter = 0;
        for (InvoiceWrapper iw : invoiceList) {
            if(iw.checked){
                counter += 1;
                if (counter == 1) {
                    invoice.RecordTypeId = expenseRecTypeId;
                    invoice.Course__c = course.Id;
                    invoice.Status__c = 'Draft';
                    Integer difference = iw.Invoice.Course__r.Start_Date__c.daysBetween(course.Start_Date__c);
                    for(InvoiceLine__c invoiceLine: [SELECT RecordTypeId, Date__c, Invoice__c, Miles_Travelled__c, Expense_Amount__c 
                                                        FROM InvoiceLine__c WHERE Invoice__c = :iw.Invoice.Id]){
                        invoiceLine__c newInvoiceLine = new InvoiceLine__c();
                        newInvoiceLine.RecordTypeId = invoiceLine.RecordTypeId;
                        newInvoiceLine.Date__c = invoiceLine.Date__c.addDays(difference);
                        newInvoiceLine.Miles_Travelled__c = invoiceLine.Miles_Travelled__c;
                        newInvoiceLine.Expense_Amount__c = invoiceLine.Expense_Amount__c;
                        invoiceLinesToInsert.add(newInvoiceLine);
                    }
                }
            }
        }
        if(counter != 1){
            String detail = counter == 0 ? 'Please select an invoice to clone.' : 'Multiple invoices selected.';
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, detail);
            ApexPages.addMessage(errorMessage);
        }else{
            insert invoice;
            String url = '/lightning/r/Opportunity/'+invoice.Id+'/view';
            page = new PageReference(url);
            for(InvoiceLine__c invoiceLine : invoiceLinesToInsert){invoiceLine.Invoice__c = invoice.Id;}
            if(invoiceLinesToInsert.size()>0){
                insert invoiceLinesToInsert;
            } 
        }
        return page;
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
