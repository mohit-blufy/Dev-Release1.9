({
	doInit : function(component, event, helper) {
		if(component.get("v.simpleRecord.Status__c") == 'Open'){
            component.set("v.showSpinner",true);
            var action = component.get("c.doInitApex");
            action.setParams({
                "recordId" : component.get("v.recordId") 
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    if(response.getReturnValue().length > 0)
                        component.set("v.sessionList",response.getReturnValue());
                    else{
                        helper.showToast(component,event,"ERROR!","No sessions found.","error");
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    component.set("v.showSpinner",false);
                    
                } 
            });
            $A.enqueueAction(action);
        }
        else {
            helper.showToast(component,event,"ERROR!","Sessions can only be updated for Open Class","error");
            $A.get("e.force:closeQuickAction").fire();
        }
	},
    
    handleMyApplicationEvent : function(component, event, helper) {
        var valueId = event.getParam("selectedOption");  
        var value = event.getParam("inputValue");
        var indx = event.getParam("slctIndex");
        var type = event.getParam("type")
        
        var sessionList= component.get("v.sessionList");
        if(type == 'Room'){
            sessionList[indx].roomId = valueId;
            sessionList[indx].roomName = value;        
        }
        else if(type == 'Teacher'){
            sessionList[indx].tchrId = valueId;
            sessionList[indx].tchrName = value;
        }	    
        component.set("v.sessionList",sessionList);
    },
    
    doCancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doSave : function(component,event,helper){
        //alert(JSON.stringify(component.get("v.sessionList")))
    } 
})