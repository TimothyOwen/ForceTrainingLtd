@isTest
private class CourseTriggerHandler_Test{
    @TestSetup
    static void testData(){
        
    }
    
    @isTest
    static void insertCourse(){
        User testUser = [SELECT Name FROM User WHERE Name = 'Mary Stevens'];
        List<Opportunity> insertCourses = new List<Opportunity>();
        Opportunity insertCourse = new Opportunity(Name='Test',Type='ADX201',StageName='Scheduled',
                                                Instructor__c=testUser.Id,Start_Date__c=Date.today(),
                                                CloseDate=Date.today().addDays(5));
        insertCourses.add(insertCourse);
        //System.Test.startTest();
        List<Database.SaveResult> results = Database.insert(insertCourses);
        //System.Test.stopTest();
        for(Database.SaveResult result : results){
            System.assert(result.isSuccess());
            System.assert(result.getErrors().size() == 0);
        }
    }

    @isTest
    static void updateCourse(){
        List<Opportunity> updateCourses = [SELECT Name, CloseDate FROM Opportunity WHERE StageName = 'Scheduled'];
        for(Opportunity course : updateCourses){
            course.CloseDate.addDays(2);
            System.debug(updateCourses);
        }
        //System.Test.startTest();
        List<Database.SaveResult> results2 = Database.update(updateCourses, true);
        update updateCourses;
        //System.Test.stopTest();
        for(Database.SaveResult result : results2){
            System.assert(result.isSuccess());
            System.assert(result.getErrors().size() == 0);
        }
    }

    @isTest
    static void deleteCourse(){
        List<Opportunity> deleteCourses = [SELECT Name FROM Opportunity LIMIT 1];
        //System.Test.startTest();
        List<Database.DeleteResult> results3 = Database.delete(deleteCourses, true);
        //System.Test.stopTest();
        for(Database.DeleteResult result : results3){
            System.assert(result.isSuccess());
            System.assert(result.getErrors().size() == 0);
        }
    }
    
}