public with sharing class CourseTriggerHandler {
    public static void courseShare(List<Opportunity> courses){
        List<OpportunityShare> coursesToShare = new List<OpportunityShare>();
        for( Opportunity course : courses) {
            OpportunityShare courseToShare = new OpportunityShare();
            courseToShare.OpportunityID =  course.Id;
            courseToShare.OpportunityAccessLevel = 'Edit';
            courseToShare.UserOrGroupId = course.Instructor__c;
            coursesToShare.add(courseToShare);
        }
        if(coursesToShare.size()>0){
            try{
                insert coursesToShare;
            }catch(DmlException e){
                System.debug(e);
            }
        }
    }      
    public static void courseEvent(List<Opportunity> courses, Boolean isUpdate){
        List<Event> calendarEventsToInsert = new List<Event>();
        Set<Id> calendarEventIdsToDelete = new Set<Id>();
        for(Opportunity course : courses){
            Event calendarEvent = new Event();
            calendarEvent.Subject = course.Name;
            calendarEvent.StartDateTime = course.Start_Date__c;
            calendarEvent.EndDateTime = course.CloseDate;
            calendarEvent.OwnerId = course.Instructor__c;
            calendarEvent.Location = course.Location__c;
            calendarEvent.Type = course.Type;
            calendarEvent.WhatId = course.Id;
            if(isUpdate){
                calendarEventIdsToDelete.add(course.Id);
            }
            if(course.StageName != 'Cancelled'){
                calendarEventsToInsert.add(CalendarEvent);
            }
        }
        if(calendarEventIdsToDelete.size()>0){
            try{
                delete [SELECT WhoId FROM Event WHERE WhatId IN :calendarEventIdsToDelete];
            }catch(DmlException e){
                System.debug(e);
            }         
        }
        if(calendarEventsToInsert.size()>0){
            try{
                insert calendarEventsToInsert;
            }catch(DmlException e){
                System.debug(e);
            }
        }
    }
/*
    public static void courseServiceInvoice(List<Opportunity> courses, Map<Id, Opportunity> oldMap){
        Id serviceRecordTypeId = Schema.SObjectType.InvoiceC__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        List<InvoiceC__c> invoicesToInsert = new List<InvoiceC__C>();
        for(Opportunity course : courses){
            Boolean completedCheck = (course.StageName == 'Completed') && (course.StageName != oldMap.get(course.Id).StageName);
            if(completedCheck){           
                InvoiceC__c invoice = new InvoiceC__c();
                invoice.RecordTypeId = serviceRecordTypeId;
                invoice.Course__c = course.Id;
                invoice.Status__c = 'Draft';
                invoicesToInsert.add(invoice);
            }
        }
        if(invoicesToInsert.size()>0){
            try{
                insert invoicesToInsert;
            }catch(DmlException e){
                System.debug(e);
            }
        }        
    }
*/
    public static void courseEmail(List<Opportunity> courses, Map<Id, Opportunity> oldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>(); 
        toAddresses.add('t32.owen@gmail.com');
        List<Opportunity> instructors = new List<Opportunity>();
        try{
            instructors = [SELECT Id, Name, Start_Date__c, StageName, Type, Instructor__r.Email, Instructor__r.Name FROM Opportunity WHERE Id IN :courses];
        }catch(DmlException e){
            System.debug(e);
        }
        for(Opportunity course: instructors){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String subject = 'Course Scheduled';
            String body = 'Dear: '+course.Instructor__r.Name+',<br> You have a course of type: '+course.Type+'<br> Scheduled on: '+course.Start_Date__c;
            if(isInsert){
                toAddresses.add(course.Instructor__r.Email); 
                email.setSubject(subject);
                email.setHtmlBody(body);
                emails.add(email);
            }
            if(isUpdate){
                Boolean cancelledCheck = (course.StageName != oldMap.get(course.Id).StageName) && (course.StageName == 'Cancelled');
                if(cancelledCheck){
                    subject = 'Course Cancelled';
                    body = 'Dear: '+course.Instructor__r.Name+',<br> You had a course of type: '+course.Type+'<br> On: '+course.Start_Date__c+'<br> This course was cancelled.';
                    toAddresses.add(course.Instructor__r.Email); 
                    email.toAddresses = toAddresses; 
                    email.setSubject(subject);
                    email.setHtmlBody(body);
                    emails.add(email);
                }
            }
            if(isDelete){
                subject = 'Course Deleted';
                body = 'Dear: '+course.Instructor__r.Name+',<br> You had a course of type: '+course.Type+'<br> On: '+course.Start_Date__c+'<br> This course was deleted.';
                toAddresses.add(course.Instructor__r.Email); 
                email.toAddresses = toAddresses; 
                email.setSubject(subject);
                email.setHtmlBody(body);
                emails.add(email);
            }
        }   
        if(emails.size()>0){
            try{
                System.debug(emails);
                //Messaging.sendEmail(emails, false);
            }catch(Exception e){
                System.debug(e);
            }
        }
    }
}