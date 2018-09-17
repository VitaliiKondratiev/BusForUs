public  class BusLineService {
        
    public static List< ModelBox.Line > getAllLines(){
       
       if(CheckPermissions.checkAccessFLS('Line__c',new List<String> { 'Name','Id' })){
            List<ModelBox.Line> returnLines = new List<ModelBox.Line>();
            for(Line__c line : BusLineDatabaseQueries.getAllLinesQuery()){
                returnLines.add(new ModelBox.Line(line));
            }            
            return returnLines;
        }
       else{           
           throw new CustomException('InvalidAccess','You do not have rights for access this object',  1);
        }
    }
    
    public static List< ModelBox.Bus > getBusLines(Id busOwner){ 
        
        List< ModelBox.Bus > busWithLines = new List< ModelBox.Bus >();

        if(CheckPermissions.checkAccessFLS('Bus__c',      new List<String>{'Id' , 'Name', 'Available__c', 'Account__c'})&&
           CheckPermissions.checkAccessFLS('Bus_Line__c', new List<String>{'Bus__c','Line__c'})&&
           CheckPermissions.checkAccessFLS('Line__c',     new List<String>{'Name','Id'})){        
            
            for(Bus__c bus : BusLineDatabaseQueries.getBusLinesQuery(busOwner)){     
            busWithLines.add(new ModelBox.Bus(bus,retLinesOfBus(bus)));
            }
        }
        else{
            throw new CustomException('InvalidAccess','You do not have rights for access this object',  1);
        }
        return busWithLines;
    }

    public static void addNewBusRoute(ModelBox.Bus_Line newRoute){
            if(CheckPermissions.checkInsertRights('Bus_Line__c')){
                BusLineDatabaseQueries.insertBusLine(newRoute.convertToCustObj());
            }
            else{
                throw new CustomException('InvalidInsert','Sorry but You do not have rights to add a new route for the bus ',1);
            } 
    }    
    
    public static void removeBusRoute(Id busForRem, Id lineForRem){      
            if(CheckPermissions.checkDeleteRights('Bus_Line__c')){
                BusLineDatabaseQueries.deleteBusLine(busForRem, lineForRem);
            }
            else{
                throw new CustomException('InvalidDelete','Sorry but You do not have the right to remove the bus from the route ',1);
            }
    }  

    public static List <ModelBox.Line> retLinesOfBus(Bus__c currentBus){ // helper for create List of bus lines

    List<ModelBox.Line> busLines = new List<ModelBox.Line>();
    for (sObject busLine : currentBus.getSObjects('Bus_Line_relations__r')) {

        sObject line             = busLine.getsObject('Line__r');
        Id lineId                = (Id) line.get('Id');
        String lineName          = (String) line.get('Name');  
        ModelBox.Line lineForAdd = new ModelBox.Line(lineId,lineName);

        busLines.add(lineForAdd);
        }        
    return busLines;
    }

    public static List<Bus__c> afterInsBusLine (List<Bus_Line__c> newBusLines){
            System.debug(LoggingLevel.INFO, newBusLines);
            String inCondition = '( ';
            for (Bus_Line__c newBusLine : newBusLines) {
               inCondition += '\'' + newBusLine.Bus__c+ '\' , '; 
            }
            inCondition = inCondition.substring(0,inCondition.length()-2) + ' )';         

            List<Bus__c> buses = Database.query('SELECT Id, Available__c FROM Bus__c WHERE Id IN ' + inCondition);
            for (Bus__c bus : buses) {
               bus.Available__c = false;
            }
            System.debug(LoggingLevel.INFO, buses);
            return buses;
    }

        public static List<Bus__c> beforeDelBusLine (List<Bus_Line__c> oldBusLines){   

            System.debug(LoggingLevel.INFO, oldBusLines);
            String inCondition = '( ';
            for (Bus_Line__c oldBusLine : oldBusLines) {
               inCondition += '\'' + oldBusLine.Bus__c+ '\' , '; 
            }
            inCondition = inCondition.substring(0,inCondition.length()-2) + ' )';         

            List<Bus__c> busesForCheck = Database.query('SELECT Id, Available__c FROM Bus__c WHERE Id IN ' + inCondition + 'ORDER BY Id');

            List<Bus_Line__c> allBusLines = [SELECT Bus__c FROM Bus_Line__c ORDER BY Bus__c];
            
            List<Bus__c> busesAvailable = new List<Bus__c> ();

            integer count = 0;
            integer getBus = 0;
            for (Bus_Line__c busLine : allBusLines) {
                if(getBus < busesForCheck.size()){
                    if(busLine.Bus__c == busesForCheck.get(getBus).Id){
                        count++;
                    }
                    else if( busLine.Bus__c != busesForCheck.get(getBus).Id && count !=0 ) {
                        if(count < 2){
                            busesForCheck.get(getBus).Available__c = true;
                            busesAvailable.add(busesForCheck.get(getBus));
                        }
                        count=0;
                        getBus++;                        
                    } 
                }
                else{
                    break;
                }
            }
            return busesAvailable; 
    }
}