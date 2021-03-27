@isTest
private class CourseTriggerHandler_Test{
    @TestSetup
    static void testData(){
        User testUser = new User(FirstName='Mary',LastName='Stevens',Email='test@forcetraining.com',Alias='test',Username='mstevtest@forcetraining.com',TimeZoneSidKey='Europe/London',LocaleSidKey='en_GB',EmailEncodingKey='UTF-8',ProfileId='00e4L000000pA9LQAU',LanguageLocaleKey='en_US');
        insert testUser;
    }
    
    @isTest
    static void positiveInsertCourse(){
        User testUser = [SELECT FirstName FROM User WHERE Username = 'mstev@forcetraining.com'];
        //
        List<Opportunity> coursesToInsert = new List<Opportunity>();
        List<OpportunityShare> coursesToShare = new List<OpportunityShare>();
        List<Event> calendarEventsToInsert = new List<Event>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //
        for(Integer i = 0; i<201; i++){
            Opportunity insertCourse = new Opportunity(Name='Test: '+i,Type='ADX201',StageName='Scheduled',Instructor__c=testUser.Id,
                                                        Start_Date__c=Date.today(), CloseDate=Date.today().addDays(5));
            coursesToInsert.add(insertCourse);
            //
            OpportunityShare courseToShare = new OpportunityShare();
            coursesToShare.add(courseToShare);
            OpportunityShare courseToShareOwner = new OpportunityShare();
            coursesToShare.add(courseToShareOwner);
            //
            Event calendarEvent = new Event();
            calendarEventsToInsert.add(calendarEvent);
            //
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Course Scheduled');
            emails.add(email);
        }
        System.Test.startTest();
        List<Database.SaveResult> results = Database.insert(coursesToInsert);
        System.Test.stopTest();

        //Course Share
        System.assertEquals(coursesToShare.size(), [SELECT OpportunityId FROM OpportunityShare WHERE
                                                        OpportunityId IN :coursesToInsert].size());


        //Course Event
        List<Event> calendarEventsInserted =  [SELECT OwnerId FROM Event];
        System.assertEquals(calendarEventsToInsert.size(),calendarEventsInserted.size());
        for(Event calendarEventInserted : calendarEventsInserted){
            System.assertEquals(testUser.Id, calendarEventInserted.OwnerId);
        }
        //Course Email
        System.assertEquals(emails.size(), [SELECT Subject__c, Body__c FROM Email_Log__c].size());

        //
        for(Database.SaveResult result : results){
            System.assert(result.isSuccess());
            System.assert(result.getErrors().size() == 0);
        }
    }



    @isTest
    static void positiveUpdateCourse(){
        User testUser = [SELECT FirstName FROM User WHERE Username = 'mstev@forcetraining.com'];
        //
        List<Opportunity> coursesToInsert = new List<Opportunity>();
        List<Event> calendarEventsToInsert = new List<Event>();
        List<InvoiceC__c> invoicesToInsert = new List<InvoiceC__C>();
        List<Email_Log__c> emailLogs = new List<Email_Log__c>();
        //
        for(Integer i = 0; i<201; i++){
            Opportunity insertCourse = new Opportunity(Name='Test: '+i,Type='ADX201',StageName='Scheduled',Instructor__c=testUser.Id,
                                                        Start_Date__c=Date.today(), CloseDate=Date.today().addDays(5));
            coursesToInsert.add(insertCourse);
            //Email
            Email_Log__c emailLog = new Email_Log__c();
            emailLogs.add(emailLog);
        }
        try{
            insert coursesToInsert;
        }catch(DmlException e){
            System.debug(e);
        }
        //
        List<Opportunity> coursesToUpdate = [SELECT Name, CloseDate FROM Opportunity WHERE StageName = 'Scheduled'];
        //
        for(Opportunity course : coursesToUpdate){
            course.CloseDate.addDays(2);
            //Event
            Event calendarEvent = new Event();
            calendarEventsToInsert.add(calendarEvent);
        }
        //ServiceInvoices
        coursesToUpdate[0].StageName = 'Completed';
        InvoiceC__c invoice = new InvoiceC__c();
        invoicesToInsert.add(invoice);
        //Email
        coursesToUpdate[1].StageName = 'Cancelled';
        Email_Log__c emailLog = new Email_Log__c();
        emailLogs.add(emailLog);
        //
        System.Test.startTest();
        List<Database.SaveResult> results2 = Database.update(coursesToUpdate, true);
        System.Test.stopTest();
        //
        for(Database.SaveResult result : results2){
            System.assert(result.isSuccess());
            System.assert(result.getErrors().size() == 0);
        }
        //
        //Course Event: One Event Cancelled
        System.assertEquals(calendarEventsToInsert.size()-1, [SELECT WhatId FROM Event].size());
        //Course Service Invoice
        System.assertEquals(invoicesToInsert.size(), [SELECT Id FROM InvoiceC__c WHERE
                                                        Course__c IN :coursesToUpdate].size());
        //Course Email
        System.assertEquals(emailLogs.size(), [SELECT Subject__c, Body__c FROM Email_Log__c].size());                                                
    }


    @isTest
    static void positiveDeleteCourse(){
        User testUser = [SELECT FirstName FROM User WHERE Username = 'mstev@forcetraining.com'];
        //
        List<Opportunity> coursesToInsert = new List<Opportunity>();
        List<Email_Log__c> emailLogs = new List<Email_Log__c>();
        //
        for(Integer i = 0; i<10; i++){
            Opportunity courseToInsert = new Opportunity(Name='Test: '+i,Type='ADX201',StageName='Scheduled',Instructor__c=testUser.Id,
                                                        Start_Date__c=Date.today(),CloseDate=Date.today().addDays(5));
            coursesToInsert.add(courseToInsert);
            //Email
            Email_Log__c emailLogForInsert = new Email_Log__c();
            Email_Log__c emailLogForDelete = new Email_Log__c();
            emailLogs.add(emailLogForInsert);
            emailLogs.add(emailLogForDelete);
        }
        try{
            insert coursesToInsert;
        }catch(DmlException e){
            System.debug(e);
        }
        //
        List<Opportunity> coursesToDelete = [SELECT Id FROM Opportunity WHERE StageName = 'Scheduled'];
        System.Test.startTest();
        List<Database.DeleteResult> results3 = Database.delete(coursesToDelete, true);
        System.Test.stopTest();
        //
        for(Database.DeleteResult result : results3){
            System.assert(result.isSuccess());
            System.assert(result.getErrors().size() == 0);
        }
        //Course Email
        System.assertEquals(emailLogs.size(), [SELECT Subject__c, Body__c FROM Email_Log__c].size());  
    }





    /*
    @isTest
    static void negativeInsertCourse(){

    }
    @isTest
    static void negativeUpdateCourse(){

    }
    @isTest
    static void negativeDeleteCourse(){

    }
    */
}