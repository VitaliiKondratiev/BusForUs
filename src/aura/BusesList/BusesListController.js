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
            "busOwner": component.get("v.recordId")

        });
        actionNewBus.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                helper.showingToasts('Success!','Success','New bus successfully added');

                var appEvent = $A.get("e.c:editInfo");
                appEvent.setParams({
                    "message": "FromBusesListToManagment"
                });
                console.log(appEvent.getParam('message'));
                appEvent.fire();
                helper.renderBusList(component);
            }
            else { 
                helper.showingToasts('Error!','Error',response.getError()[0].message ); 
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

                    helper.showingToasts('Success!','Success','Selected bus was removed'); 
                    var appEvent = $A.get("e.c:editInfo");
                    appEvent.setParams({
                        "message": "FromBusesListToManagment"
                    });
                    appEvent.fire();

                    component.set("v.totalBuses", (component.get("v.totalBuses") - 1)); // delete 1 bus from totalNumber
                    component.set("v.buses", buses);

                }
                else {               
                helper.showingToasts('Error!','Error', response.getError()[0].message ); 
                }
            });
            $A.enqueueAction(actionBusRemove);
        }
        else {  
            helper.showingToasts('Warning!','Warning', 'Removing canceled!' ); 
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
                helper.showingToasts('Success!','Success', 'Bus info successfully changed' );
                var appEvent = $A.get("e.c:editInfo");
                appEvent.setParams({
                    "message": "FromBusesListToManagment"
                });
                console.log(appEvent.getParam('message'));
                appEvent.fire();
                helper.renderBusList(component);
            }
            else {
                helper.showingToasts('Error!','Error', response.getError()[0].message );
            }
        });
        $A.enqueueAction(actionNewBus);
    },


})