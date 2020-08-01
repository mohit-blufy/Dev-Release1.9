({
    handleDateChange : function(component, event, helper) {
        var dateVal = event.getSource().get("v.value");
        console.log(dateVal);
        var filterCriteria = component.getEvent("handleDateEvent");
        filterCriteria.setParams({"index" : component.get("v.index")});
        filterCriteria.setParams({"selectedDate" : dateVal});
        filterCriteria.fire();
    },
    showLookupModal : function(component, event, helper) {
        console.log(event.getSource().get("v.name"));
        var modalEvent = component.getEvent("showModal");
        modalEvent.setParams({"objectName" :  event.getSource().get("v.name")});
        modalEvent.setParams({"fieldName" : 'Name'});
        modalEvent.fire();
    }
})
