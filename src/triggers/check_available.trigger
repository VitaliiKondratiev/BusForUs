trigger check_available on Bus_Line__c (after insert, before delete, after update)  {
    // toUpd list of old Data
    List<Bus__c> toUpd = new List<Bus__c>();
    // newDat list of actual Data
    List<Bus__c> newDat = new List<Bus__c>(); 

    if(!trigger.isInsert){
        for(Bus_Line__c item : Trigger.old){            
            integer count = [Select count() from Bus_Line__c where Bus__c = :item.Bus__c];            
            if(count == 1){
                toUpd.add([Select id From Bus__c Where id = :item.Bus__c]); 
            }  
        }  
        for(Bus__c item : toUpd){
            item.Available__c = true;
            update item;
        }
    }    
    //New property always get available=false
    if(!trigger.isDelete){
        for(Bus_Line__c item : Trigger.new){
            newDat.add([Select id From Bus__c Where id = :item.Bus__c]); 
        }  
        for(Bus__c item : newDat){
            item.Available__c = false;
            update item;            
        }   
    }     
    
}