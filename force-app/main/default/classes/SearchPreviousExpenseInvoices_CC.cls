public class SearchPreviousExpenseInvoices_CC {
    private Opportunity course;
    public SearchPreviousExpenseInvoices_CC(){
        course = [SELECT Id, Name, Instructor__c, Start_Date__c FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }

    public Opportunity getCourse(){
        return course;
    }

    public List<InvoiceWrapper> invoiceList{
        get{
            Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
            if(invoiceList == null){
                invoiceList = new List<InvoiceWrapper>();
                for(InvoiceC__c invoice : [SELECT Invoice_ID__C, Submitted_Date__c, Sub_Total__c, VAT__c 
                                        FROM InvoiceC__c WHERE RecordTypeId = :expenseRecordTypeId AND Course__c = : course.Id]){
                    invoiceList.add(new InvoiceWrapper(invoice));
                }
            }
            return invoiceList;
        }
        set;
    }

    public void selectInvoice() {
        Id expenseRecTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        InvoiceC__c invoice = new InvoiceC__c();
        List<InvoiceLine__c> invoiceLinesToInsert = new List<InvoiceLine__c>();
        Integer checkedCounter = 0;
        System.debug('Course: '+course);
        for (InvoiceWrapper iw : invoiceList) {
            if (iw.checked && checkedCounter<2) {
                checkedCounter += 1;
                invoice.RecordTypeId = expenseRecTypeId;
                invoice.Course__c = course.Id;
                invoice.Status__c = 'Draft';
                Integer difference = course.Start_Date__c.daysBetween(Date.today());
                for(InvoiceLine__c invoiceLine: [SELECT RecordTypeId, Date__c, Invoice__c, Miles_Travelled__c, Expense_Amount__c FROM InvoiceLine__c WHERE Invoice__c = :iw.Invoice.Id]){
                    invoiceLine__c newInvoiceLine = new InvoiceLine__c();
                    newInvoiceLine.RecordTypeId = invoiceLine.RecordTypeId;
                    newInvoiceLine.Date__c = invoiceLine.Date__c.addDays(difference);
                    newInvoiceLine.Miles_Travelled__c = invoiceLine.Miles_Travelled__c;
                    newInvoiceLine.Expense_Amount__c = invoiceLine.Expense_Amount__c;
                    invoiceLinesToInsert.add(newInvoiceLine);
                }
            }
        }
        if(checkedCounter == 1){
            try{
                insert invoice;
            }catch(DmlException e){
                System.debug(e);
            }
            /*if(invoiceLinesToInsert.size()>0){
                try{
                    insert invoiceLinesToInsert;
                }catch(DmlException e){
                    System.debug(e);
                }
            }  */
        }else{
            String detail = 'Please select one invoice to clone.';
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, detail);
            ApexPages.addMessage(errorMessage);
        }
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
