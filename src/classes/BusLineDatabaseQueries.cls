public class BusLineDatabaseQueries {
    
    public static List<Bus__c> getBusLinesQuery (Id busOwner){ // Select all buslines which have relation with busOwner
        return [ SELECT Id , Name, Available__c, Account__c, (Select Line__r.Name, Line__r.Id 
                                                             FROM Bus_Line_relations__r) 
                FROM Bus__c
                WHERE Account__c = :busOwner];
    }
    
    public static List<Line__c> getAllLinesQuery (){ // Select all lines
        return [ SELECT Id , Name  FROM Line__c ORDER BY name];       
    }

    public static void insertBusLine(Bus_Line__c busLineForInsert){
        Database.insert(busLineForInsert);
    }

    public static void deleteBusLine(Id busForRem, Id lineForRem){
       delete [SELECT ID FROM Bus_Line__c WHERE Bus__c =: busForRem AND Line__c =:lineForRem ];
    }
}