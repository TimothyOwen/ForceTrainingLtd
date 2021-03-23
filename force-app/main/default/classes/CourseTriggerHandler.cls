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
        for(Opportunity o : newCourses){
            Event calendarEvent = new Event();
            calendarEvent.Subject = 'Course';
            calendarEvent.StartDateTime = o.Start_Date__c;
            calendarEvent.EndDateTime = o.CloseDate;
            calendarEvent.OwnerId = o.Instructor__c;
            calendarEvent.Location = o.Location__c;
            calendarEvent.Type = o.Type;
            calendarEvent.WhatId = o.Id;
            if(isUpdate){
                calendarEventsToDelete.add(o.Id);
            }
            if(o.StageName != 'Cancelled'){
                calendarEventsToInsert.add(CalendarEvent);
            }
        }
        delete [SELECT WhoId FROM Event WHERE WhatId = :calendarEventsToDelete];
        insert calendarEventsToInsert;
    }

    public static void CourseEmail(List<Opportunity> courses, Map<Id, Opportunity> oldMap, Boolean isUpdate, Boolean isDelete){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Id> InstructorIds = new List<Id>();
        for(Opportunity course : courses){
            if(course.Instructor__c!=Null){
                InstructorIds.add(course.Instructor__c);
            }
        }
        List<User> InstructorNames = [SELECT Name FROM USER WHERE Id IN :InstructorIds];
        List<String> toAddresses = new List<String>();
        toAddresses.add('t32.owen@gmail.com');    
        for(Integer i=0; i<courses.size(); i++ ){
            String subject = 'Course Scheduled';
            String body = 'Dear: '+InstructorNames[i].Name+',<br> You have a course of type: '+courses[i].Type+'<br> Scheduled on: '+courses[i].Start_Date__c;
            if(isUpdate){
                subject = 'Course Updated';
                body = 'Dear: '+InstructorNames[i].Name+',<br> You have a course of type: '+courses[i].Type+'<br> This course has been rescheduled to: '+courses[i].Start_Date__c;
                if(courses[i].StageName != oldMap.get(courses[i].Id).StageName && courses[i].StageName == 'Cancelled'){
                    subject = 'Course Cancelled';
                    body = 'Dear: '+InstructorNames[i].Name+',<br> You had a course of type: '+courses[i].Type+'<br> on: '+courses[i].Start_Date__c+'<br> This course was cancelled.';
                }
            }
            if(isDelete){
                subject = 'Course Deleted';
                body = 'Dear: '+InstructorNames[i].Name+',<br> You had a course of type: '+courses[i].Type+'<br> on: '+courses[i].Start_Date__c+'<br> This course was deleted.';
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.toaddresses = toAddresses;
            email.setSubject(subject);
            email.setHtmlBody(body);
            emails.add(email);
            System.debug(subject + body + InstructorNames[i].Name);
        }    
        Messaging.sendEmail(emails, false);
    }
}