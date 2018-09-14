({
	renderBusMangment : function(component) {
        
		var action = component.get("c.getBusLines");
        action.setParams({
            "busOwner": component.get("v.recordId"),
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                component.set("v.busesForMan", response.getReturnValue()["buses"]);
                component.set("v.allLines", response.getReturnValue()["lines"]);
            }
            else {
               
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title'  : 'Error!',
                    'type'   : 'Error',
                    'message':  response.getError()[0].message    

                });
                showToast.fire();               
            }
        });
        $A.enqueueAction(action);		
	}
})