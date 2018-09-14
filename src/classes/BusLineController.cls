public class BusLineController {
    
    @AuraEnabled
    public static Map< String, Object> getBusLines(Id busOwner) {
        Map<String, Object> result = new Map< String, Object>();
         try {
            result.put('buses', BusLineService.getBusLines(busOwner));
            result.put('lines', BusLineService.getAllLines());
             return result;
        }
        catch (CustomException e) {
        throw new AuraHandledException(e.message);
        }
           
       
    } 


     @AuraEnabled
    public static void insertRoute(Id busHalf, Id lineHalf) {
        ModelBox.Bus_Line newBusRoute = new ModelBox.Bus_Line(busHalf, lineHalf);
        try {
            BusLineService.addNewBusRoute(newBusRoute);
        }
        catch (CustomException e) {
        throw new AuraHandledException(e.message);
        }
    }

    @AuraEnabled
    public static void deleteBusRoute(Id busForRem, Id lineForRem) {
       try {
            BusLineService.removeBusRoute(busForRem, lineForRem);
        }
        catch (CustomException e) {
        throw new AuraHandledException(e.message);
        }
    }
}