({
    renderBusList : function(component) {
        component.set("v.newName","");
        var action = component.get("c.getBuses");
        action.setParams({
            "busPartner": component.get("v.recordId"),
            "available" : component.get("v.availableSearch")
            
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {              
                component.set("v.totalBuses", response.getReturnValue()["total"]);
                component.set("v.buses", response.getReturnValue()["buses"]);
            }
            else {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title'  : 'Error!',
                    'type'   : 'Error',
                    'message': response.getError()[0].message    

                });
                showToast.fire(); 
            }
        });
        $A.enqueueAction(action);
    }
})