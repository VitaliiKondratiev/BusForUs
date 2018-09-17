trigger check_available on Bus_Line__c (after insert, before delete, after update)  {
    // toUpd list of old Data
    List<Bus__c> toUpd = new List<Bus__c>();
    // newDat list of actual Data
    List<Bus__c> newDat = new List<Bus__c>(); 

    if(!trigger.isInsert){
      Database.update(BusLineService.beforeDelBusLine(Trigger.old)); // Автобусы, упоминание которых в Bus_Line менее 2 записей, доступные
    }    
    //New property always get available=false
    if(!trigger.isDelete){    
        Database.update(BusLineService.afterInsBusLine(Trigger.new));
    }       
}