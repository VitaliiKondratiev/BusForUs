public class BusController {    
    @AuraEnabled
    public static Map< String, Object> getBuses(String busPartner,Boolean available) {
        Map<String, Object> result = new Map< String, Object>();
        try {        
            result.put('buses', BusService.getBuses(busPartner, available));
            result.put('total', BusService.getTotalBusesNumber(busPartner));  
            return result;
        }
        catch (CustomException e) {
            throw new AuraHandledException(e.message);
        } 
    }   
    
    @AuraEnabled
    public static void insertBus(String busOwner, String name) {        	
        ModelBox.Bus newBus = new ModelBox.Bus(busOwner, name);
        try {        
            BusService.upsertBus(newBus,true);     
        }
            catch (CustomException e) {
            throw new AuraHandledException(e.message);
        }
    }
    
    @AuraEnabled 
    public static void updateBus(String busForUpdJSON) {  
        ModelBox.Bus newBus = (ModelBox.Bus) JSON.deserialize(busForUpdJSON, ModelBox.Bus.class);        	
        try {        
            BusService.upsertBus(newBus,false);         
        }
        catch (CustomException e) {
            throw new AuraHandledException(e.message);
        }
       
    }
    
    @AuraEnabled
    public static void removeBus(String busForDelJSON) {
        ModelBox.Bus targetBus = (ModelBox.Bus) JSON.deserialize(busForDelJSON, ModelBox.Bus.class);        	
        try {        
             BusService.deleteBus(targetBus);    
        }
        catch (CustomException e) {
             throw new AuraHandledException(e.message);
        }
    }
    
}