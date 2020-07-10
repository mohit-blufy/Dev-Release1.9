({
	fetchGender: function(component, ObjectApiName,  fieldName) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "ObjectApi_name": ObjectApiName,
            "Field_name": fieldName
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.genderList", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    fetchRelationsShip: function(component, ObjectApiName,  fieldName) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "ObjectApi_name": ObjectApiName,
            "Field_name": fieldName
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.relationShipList", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    fetchCntry: function(component, ObjectApiName,  fieldName) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "ObjectApi_name": ObjectApiName,
            "Field_name": fieldName
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.cntryList", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    initilizeCstmrList: function(component, event) {
        var action = component.get("c.blankInitializeCstmrWrpr");
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            component.set("v.stuClsWrapper",res);
        });
        
        $A.enqueueAction(action);
    },
    showToast : function(component, event, type, msg) {
      
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: msg,
            type : type
        });
        toastEvent.fire();
    }
})