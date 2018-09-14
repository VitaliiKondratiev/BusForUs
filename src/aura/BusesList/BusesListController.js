({
    doInit: function (component, event, helper) { //////////////////////////////////doInit///////////////////////////////////////////////////////////
        helper.renderBusList(component);
    },
    handleEditInfoEvent: function (component, event, helper) { //////////////////////////////////doInit///////////////////////////////////////////////////////////
        debugger
        if (event.getParam('message') == 'FromBusInfoToList') {
            event.stopPropagation();
            helper.renderBusList(component);
        }

    },


    openModel: function (component, event, helper) { ///////////////////////////////openModel///////////////////////////////////////////////////////////
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },

    closeModel: function (component, event, helper) { ///////////////////////////////closeModel////////////////////////////////////////////////////////////////
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },

    createNewBus: function (component, event, helper) { //////////////////////////////createNewBus//////////////////////////////////////////////////////////////
        var actionNewBus = component.get("c.insertBus");
        actionNewBus.setParams({
            "name"    : component.get("v.newName"),
            "accOwner": component.get("v.recordId")

        });
        actionNewBus.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title'  : 'Success!',
                    'type'   : 'Success',
                    'message': 'New bus successfully added'
                });
                showToast.fire();
                var appEvent = $A.get("e.c:editInfo");
                appEvent.setParams({
                    "message": "FromBusesListToManagment"
                });
                console.log(appEvent.getParam('message'));
                appEvent.fire();
                helper.renderBusList(component);
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
        component.set("v.isOpen", false);
        $A.enqueueAction(actionNewBus);

    },

    busDelete: function (component, event, helper) { //////////////////////////////////busDelete///////////////////////////////////////////////////////////////
        if (confirm("Are you sure that you want to delete the bus?")) {
            var busId = event.getSource().get("v.value");
            var buses = component.get("v.buses").filter(bus => {
                return bus != component.get("v.buses")[event.getSource().get("v.value")];
            });
            var actionBusRemove = component.get("c.removeBus");

            actionBusRemove.setParams({
                "busForDelJSON": JSON.stringify(component.get("v.buses")[event.getSource().get("v.value")])
            });
            actionBusRemove.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        'title'  : 'Success!',
                        'type'   : 'Success',
                        'message': 'Selected bus was removed'
                    });
                    showToast.fire();

                    var appEvent = $A.get("e.c:editInfo");
                    appEvent.setParams({
                        "message": "FromBusesListToManagment"
                    });
                    appEvent.fire();

                    component.set("v.totalBuses", (component.get("v.totalBuses") - 1)); // delete 1 bus from totalNumber
                    component.set("v.buses", buses);

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
            $A.enqueueAction(actionBusRemove);
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
    },


    toggleShow: function (component, event, helper) {///////////toggleShow///////////////////////////////////////////////////////////////////////////

        var indexBus              = event.getSource().get('v.value');
        var buses                 = component.get('v.buses');
        buses[indexBus].isEditing = !buses[indexBus].isEditing;
        component.set('v.buses', buses);

    },
    confirmUpdate: function (component, event, helper) {///////////confirmUpdate///////////////////////////////////////////////////////  

        var actionNewBus = component.get("c.updateBus");
        actionNewBus.setParams({
            "busForUpdJSON": JSON.stringify(component.get("v.buses")[event.getSource().get("v.value")])
        });
        actionNewBus.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title'  : 'Success!',
                    'type'   : 'Success',
                    'message': 'Bus info successfully changed'
                });
                showToast.fire();
                var appEvent = $A.get("e.c:editInfo");
                appEvent.setParams({
                    "message": "FromBusesListToManagment"
                });
                console.log(appEvent.getParam('message'));
                appEvent.fire();
                helper.renderBusList(component);
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
        component.set("v.isOpen", false);
        $A.enqueueAction(actionNewBus);
    },


})