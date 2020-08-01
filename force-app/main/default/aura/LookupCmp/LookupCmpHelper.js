({
    getRecords : function(component, event, helper) {
        let action = component.get("c.getRecords");
        let searchKey = event.getSource().get("v.value") != undefined ? event.getSource().get("v.value") : '';
        console.log('searchKey',searchKey);
        action.setParams({ 'objectApiName': component.get("v.objectName"),'searchKey' : searchKey });
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();
            console.log(res);
            if(res){
                component.set("v.records",res);
            }
        });        
        $A.enqueueAction(action);
    }
})
