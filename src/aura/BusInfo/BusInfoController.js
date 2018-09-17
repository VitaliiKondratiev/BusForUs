({
    toggleViewEditFields: function (component, event, helper) {

        component.set('v.currentBus.isEditing', !component.get('v.currentBus.isEditing'));

        if (event.getSource().getLocalId() == "renderAvailLines") {
            var notAvLines = component.get("v.currentBus.workLines");
            var allLines   = component.get("v.listLines");

            allLines       = allLines.filter(line => {
                return !notAvLines.some(item => item.lineId === line.lineId);
            });
            component.set("v.listAvail", allLines);
        }
    },

    addNewRoute: function (component, event, helper) {
       debugger
        var actionSetRoute = component.get("c.insertRoute");
        var newId;
        if(Array.isArray(component.find("chosenLine"))){
            newId = component.find("chosenLine")[0].get("v.value");
        }
        else{
            newId = component.find("chosenLine").get("v.value");
        }
        var newName        = component.get("v.listLines").find(item => {
            return item.lineId === newId;
        }).lineName;

        actionSetRoute.setParams({
            "busHalf" : component.get("v.currentBus.busId"),
            "lineHalf": newId
        });

        actionSetRoute.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var listLines = component.get("v.currentBus.workLines");
                var newRoute  = {
                    lineId: newId,
                    lineName: newName
                }

                listLines.push(newRoute);
                component.set("v.currentBus.available", false);
                component.set("v.currentBus.workLines", listLines);

                var appEvent = $A.get("e.c:editInfo");
                appEvent.setParams({
                    "message": "FromBusInfoToList"
                });                
                appEvent.fire();
                helper.showingToasts('Success!','Success','New route successfully added');
            }
            else {
                helper.showingToasts('Error!','Error', response.getError()[0].message);
            }
        });
        var bus       = component.get('v.currentBus');
        bus.isEditing = !bus.isEditing;
        component.set('v.currentBus', bus);

        $A.enqueueAction(actionSetRoute);
    },

    removeBusRoute: function (component, event, helper) {

        if (confirm("Are you sure you want to delete the route?")) {
            var lineList       = component.get("v.currentBus.workLines");
            var lineToDelId    = lineList[event.getSource().get("v.value")].lineId;
            var actionDelRoute = component.get("c.deleteBusRoute");

            actionDelRoute.setParams({
                "busForRem": component.get("v.currentBus.busId"),
                "lineForRem": lineToDelId

            });

            actionDelRoute.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    lineList = lineList.filter(
                        lineItem => {
                            return lineItem.lineId != lineToDelId
                        }
                    );
                    component.set("v.currentBus.workLines", lineList);
                    if (lineList.length == 0) {
                        component.set("v.currentBus.available", true);
                    }

                    var appEvent = $A.get("e.c:editInfo");
                    appEvent.setParams({
                        "message": "FromBusInfoToList"
                    });
                    appEvent.fire();
                    helper.showingToasts('Success!','Success','Route successfully delited');

                }
                else {
                    helper.showingToasts('Error!','Error', response.getError()[0].message);
                }
            });
            $A.enqueueAction(actionDelRoute);

        }
        else {
            helper.showingToasts('Warning!','Warning', 'Removing canceled!');
        }
    }

})