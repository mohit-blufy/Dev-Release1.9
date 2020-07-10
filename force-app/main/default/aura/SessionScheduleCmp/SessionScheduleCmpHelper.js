({
    doInitHelper : function(component, event, type, msg) {
        component.set("v.showSpinner",true);
        var recordId = component.get("v.recordId");
        // alert(recordId);
        var action = component.get("c.generateSession");
        action.setParams({
            "clsTermId": recordId,
            "classId" : component.get("v.termRecord.Class__c")
        });
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            if(res.sessList.length > 0){
                component.set("v.sessionList",res.sessList);
            }else if(res.message.includes('No Class Session')){
                this.showToast(component,event,"Error","Please specify Class Sessions in related list");
                $A.get("e.force:closeQuickAction").fire();
            }
            else{                
                this.showToast(component,event,"Error","Only draft class term can be schedule.");
                $A.get("e.force:closeQuickAction").fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type+"!",
            "type" : type,
            "message": msg
        });
        toastEvent.fire();
    }
})