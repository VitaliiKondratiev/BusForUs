({
    doInitBuses : function(component, event, helper) {
        helper.renderBusMangment(component);
    },

    handleEditInfoEvent : function (component, event, helper){
        debugger
        if(event.getParam('message') == 'FromBusesListToManagment'){
            event.stopPropagation();
            helper.renderBusMangment(component);
        }
       
    }
})