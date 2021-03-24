public with sharing class CourseTriggerHandler {
    public static void CourseShare(List<Opportunity> courses){
        List<OpportunityShare> coursesToShare = new List<OpportunityShare>();
        for( Opportunity course : courses) {
            OpportunityShare courseToShare = new OpportunityShare();
            courseToShare.OpportunityID =  course.Id;
            courseToShare.OpportunityAccessLevel = 'Edit';
            courseToShare.UserOrGroupId = course.Instructor__c;
            coursesToShare.add(courseToShare);
        }
        insert coursesToShare;
    }      
    public static void CourseEvent(List<Opportunity> newCourses, Boolean isUpdate){
        List<Event> calendarEventsToInsert = new List<Event>();
        Set<Id> calendarEventsToDelete = new Set<Id>();
        for(Opportunity course : newCourses){
            Event calendarEvent = new Event();
            calendarEvent.Subject = 'Course';
            calendarEvent.StartDateTime = course.Start_Date__c;
            calendarEvent.EndDateTime = course.CloseDate;
            calendarEvent.OwnerId = course.Instructor__c;
            calendarEvent.Location = course.Location__c;
            calendarEvent.Type = course.Type;
            calendarEvent.WhatId = course.Id;
            if(isUpdate){
                calendarEventsToDelete.add(course.Id);
            }
            if(course.StageName != 'Cancelled'){
                calendarEventsToInsert.add(CalendarEvent);
            }
        }
        if(calendarEventsToDelete.size()>0){
            delete [SELECT WhoId FROM Event WHERE WhatId = :calendarEventsToDelete];
        }
        if(calendarEventsToInsert.size()>0){
            insert calendarEventsToInsert;
        }
    }

    public static void CourseEmail(List<Opportunity> courses, Map<Id, Opportunity> oldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> instructors = [SELECT Id, Name, Start_Date__c, StageName, Type, Instructor__r.Email, Instructor__r.Name FROM Opportunity WHERE Id IN :courses];
        System.debug(instructors.size());
        List<String> toAddresses = new List<String>();   
        for(Opportunity course: instructors){
            System.debug(course);
            String subject = 'Course Scheduled';
            String body = 'Dear: '+course.Instructor__r.Name+',<br> You have a course of type: '+course.Type+'<br> Scheduled on: '+course.Start_Date__c;
            Boolean cancelledCheck = course.StageName != oldMap.get(course.Id).StageName && course.StageName == 'Cancelled'; 
            if(isInsert){
                toAddresses.add(course.Instructor__r.Email); 
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.toAddresses = toAddresses;
                email.setSubject(subject);
                email.setHtmlBody(body);
                emails.add(email);
                System.debug(email);
            }
            if(isUpdate && cancelledCheck){
                subject = 'Course Cancelled';
                body = 'Dear: '+course.Instructor__r.Name+',<br> You had a course of type: '+course.Type+'<br> on: '+course.Start_Date__c+'<br> This course was cancelled.';
                toAddresses.add(course.Instructor__r.Email); 
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.toAddresses = toAddresses;
                email.setSubject(subject);
                email.setHtmlBody(body);
                emails.add(email);
                System.debug(email);
            }
            if(isDelete){
                subject = 'Course Deleted';
                body = 'Dear: '+course.Instructor__r.Name+',<br> You had a course of type: '+course.Type+'<br> on: '+course.Start_Date__c+'<br> This course was deleted.';
                toAddresses.add(course.Instructor__r.Email); 
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.toAddresses = toAddresses;
                email.setSubject(subject);
                email.setHtmlBody(body);
                emails.add(email);
                System.debug(email);
            }
        }    
        Messaging.sendEmail(emails, false);
    }
}