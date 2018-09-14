({
    toggleViewEditFields: function (component, event, helper) {

        var bus       = component.get('v.currentBus');
        bus.isEditing = !bus.isEditing;
        component.set('v.currentBus', bus);

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
        var actionSetRoute = component.get("c.insertRoute");
        var newId          = component.find("chosenLine").get("v.value");

        var newName        = component.get("v.listLines").filter(item => {
            return item.lineId === newId;
        })[0].lineName;

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

                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title'   : 'Success!',
                    'type'   : 'Success',
                    'message': 'New route successfully added'
                });
                showToast.fire();
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

                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title'  : 'Success!',
                        'type'   : 'Success',
                        'message': 'Route successfully delited'
                    });
                    showToast.fire();

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
            $A.enqueueAction(actionDelRoute);

        }
        else {
            var showToast = $A.get("e.force:showToast");
            showToast.setParams({
                'title'  : 'Warning!',
                'type'   : 'Warning',
                'message': "Removing canceled!"
            });
            showToast.fire();
        }
    }

})