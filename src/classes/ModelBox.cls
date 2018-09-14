public class ModelBox {
    
    public class Bus{
        
        @AuraEnabled public String name            {get; set;}
        @AuraEnabled private Boolean available     {get; set;}
        @AuraEnabled private Id accountOwner       {get; set;}
        @AuraEnabled private Id busId              {get; set;}
        @AuraEnabled private Boolean isEditing     {get; set;}
        @AuraEnabled private List <Line> workLines {get; set;}
        
        
        public Bus(Bus__c bus){ // show bus to "Bus Depot" tab
            this.name         = bus.Name;
            this.available    = bus.Available__c;
            this.accountOwner = bus.Account__c;
            this.busId        = bus.Id;
            this.isEditing    = false;
        }
        public Bus (String accOwner, String name){ // Adding new bus
            this.name         = name;
            this.available    = true;
            this.accountOwner = accOwner;
            this.isEditing    = false;
        }
        
        public Bus(Bus__c bus, List<ModelBox.Line> lines){ // show bus to "Bus Managment" tab
            this.name         = bus.Name;
            this.available    = bus.Available__c;
            this.accountOwner = bus.Account__c;
            this.busId        = bus.Id;
            this.isEditing    = false;
            this.workLines    = lines;
        }
        
        public Bus__c unMap(){
            Bus__c forReturn       = new Bus__c();
            forReturn.Name         = this.name;
            forReturn.Available__c = this.available;
            forReturn.Account__c   = this.accountOwner;
            forReturn.Id           = this.busId;
            return forReturn;
        }
    }    
    public class Line{   
        
        @AuraEnabled  private Id lineId {get; set;}        ///////// LineId.LineName
        @AuraEnabled  private String lineName {get; set;}
        
        
        public Line(Id busOnLineId, String busOnLineName){ 
            this.lineId   =  busOnLineId;
            this.lineName = busOnLineName;
        }        
        
        public Line(Line__c custLine){ 
            this.LineId   =  custLine.Id;
            this.LineName = custLine.Name;
        }        
    }

        public class Bus_Line{   
        
        @AuraEnabled  private Id lineId {get; set;}
        @AuraEnabled  private Id busId  {get; set;}
        
        
        public Bus_Line(Id busId_inp, Id lineId_inp){ 
            this.busId  =  busId_inp;
            this.lineId = lineId_inp;
        }


        public Bus_Line__c convertToCustObj (){

            Bus_Line__c convertedObj = new Bus_Line__c();
            convertedObj.Bus__c  = this.busId;
            convertedObj.Line__c = this.lineId;
            return convertedObj;

        }
    }
    
}