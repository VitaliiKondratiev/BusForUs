public class BusDataBase {
    
    public static List< ModelBox.Bus > queryGetBuses(String busPartner, Boolean available) {
        
        List <Bus__c> neededBuses         = new List<Bus__c>();
        List<ModelBox.Bus> busesForReturn = new  List<ModelBox.Bus>();
        
        neededBuses = [SELECT id, name, available__c, account__c  
                       FROM Bus__c 
                       WHERE account__c = :busPartner
                       AND available__c = :available];
        
        for(Bus__c nededBus : neededBuses){            
            busesForReturn.add(new ModelBox.Bus(nededBus));            
        }        
        return  busesForReturn;
    }
    public static Integer queryGetCountOfBuses(String busPartner) {       
        return [SELECT count()  
                FROM Bus__c 
                WHERE account__c = :busPartner];
    }
    
    public static void queryUpsertBus (ModelBox.Bus newBus) {    
        Database.upsert(newBus.unMap());    
    } 
    
    
    public static void queryToDelete(ModelBox.Bus targetBus){
        Database.delete(targetBus.unMap());
    }  
}