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
                this.showingToasts('Error!','Error', response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    showingToasts : function(title, type, message) {
		var showToast = $A.get("e.force:showToast");
		if(showToast != undefined){
			showToast.setParams({
				'title'   : title,
				'type'   : type,
				'message': message
			});
			showToast.fire();
		}
	}
})