public class SearchPreviousExpenseInvoices_CC {
    private Opportunity course;
    /*public void SearchPreviousExpenseInvoices_CC(){
        course = [SELECT Id, Name, Amount FROM Opportunity WHERE Id = '0064L000002Qb5DQAS'];
    }*/

    public List<InvoiceWrapper> invoiceList{
        get{
            Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
            Opportunity course = [SELECT Id, Name, Amount, Instructor__c FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
            if(invoiceList == null){
                invoiceList = new List<InvoiceWrapper>();
                for(InvoiceC__c invoice : [SELECT Invoice_ID__C, Course__r.Name, Submitted_Date__c, Sub_Total__c, VAT__c 
                                        FROM InvoiceC__c WHERE Course__r.Instructor__c = :course.Instructor__c AND RecordTypeId = :expenseRecordTypeId]){
                    invoiceList.add(new InvoiceWrapper(invoice));
                    System.debug(invoice);
                }
            }
            System.debug('List: '+course);
            return invoiceList;
        }
        set;
    }

    public void selectInvoice() {
        Id expenseRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        InvoiceC__c invoice = new InvoiceC__c();
        List<InvoiceLine__c> invoiceLinesToInsert = new List<InvoiceLine__c>();
        invoice.RecordTypeId = expenseRecordTypeId;
        Integer checkedCounter = 0;
        for (InvoiceWrapper iw : invoiceList) {
            if (iw.checked) {
                checkedCounter += 1;
                if(checkedCounter<2){
                    //NEED TO PASS COURSE invoice.Course__c = course.Id;
                    invoice.Status__c = 'Draft';
                    System.debug('Invoice: '+invoice);
                    for(InvoiceLine__c invoiceLine: [SELECT Date__c, Invoice__c, Miles_Travelled__c, Expense_Amount__c FROM InvoiceLine__c WHERE Invoice__c = :iw.Invoice.Id]){
                        System.debug('InvoiceLine: '+invoiceLine);
                        InvoiceLine__c newInvoiceLine = new InvoiceLine__c();
                        newInvoiceLine.RecordTypeId = invoiceLine.RecordTypeId;
                        Integer dateDifference = Date.today() - course.Start_Date__c;
                        newInvoiceLine.Date__c = invoiceLine.Date__c.addDays(dateDifference);
                        newInvoiceLine.Miles_Travelled__c = invoiceLine.Miles_Travelled__c;
                        newInvoiceLine.Expense_Amount__c = invoiceLine.Expense_Amount__c;
                    }
                }
            }
        }
        System.debug('Checked Counter:'+checkedCounter);
        if(checkedCounter == 1){
            try{
                System.debug('Success');
                //insert invoice;
                //return ApexPages.invoiceId
            }catch(DmlException e){
                system.debug(e);
            }
        }else{
            String detail = ('Please select one invoice.');
            ApexPages.Message message = new ApexPages.Message(ApexPages.severity.INFO, detail);
            ApexPages.addMessage(message);
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
