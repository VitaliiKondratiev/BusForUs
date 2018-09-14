public class  BusService {
    
    public static List< ModelBox.Bus > getBuses(String busPartner, Boolean available) { 
        if(CheckPermissions.checkAccessFLS('Bus__c',new List<String>{'id', 'name', 'available__c', 'account__c'})){
            return BusDataBase.queryGetBuses(busPartner, available);
        }
        else{
            throw new CustomException('InvalidAccess','Sorry but You do not have permission to view the list of buses',1);
        }        
    }
        
    public static Integer getTotalBusesNumber(String busPartner) {       
            return BusDataBase.queryGetCountOfBuses(busPartner);
    } 
    
    public static void upsertBus(ModelBox.Bus bus,Boolean isItNew) {
      
        if(CheckPermissions.checkUpdateRights('Bus__c')&& isItNew || !isItNew && CheckPermissions.checkInsertRights('Bus__c')){
            BusDataBase.queryUpsertBus(bus);
        }        
        else{
            throw new CustomException('InvalidUpsert','Sorry but You do not have permission to change the list of buses',1);
        }  
    }
    
    public static void deleteBus(ModelBox.Bus targetBus){
      
        if(CheckPermissions.checkDeleteRights('Bus__c')){
            BusDataBase.queryToDelete(targetBus);
        }        
        else{
            throw new CustomException('InvalidDelete','Sorry but You do not have permission to delete buses',1);
        }
    }    
}