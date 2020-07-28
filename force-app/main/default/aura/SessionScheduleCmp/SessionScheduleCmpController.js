({
    doInit : function(component,event,helper){
        helper.doInitHelper(component,event,helper);
    },
    
    handleMyApplicationEvent : function(component, event, helper) {
        var valueId = event.getParam("selectedOption");  
        var value = event.getParam("inputValue");
        var indx = event.getParam("slctIndex");
        
        var sessionList= component.get("v.sessionList");
        if(type == 'Room'){
            sessionList[indx].roomId = valueId;
            sessionList[indx].roomName = value;        
        }
        else if(type == 'Teacher'){
            sessionList[indx].tchrId = valueId;
            sessionList[indx].tchrName = value;
        }
        console.log(JSON.stringify(sessionList));
        component.set("v.sessionList",sessionList);
    },
    
    closeQuickActionModel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    saveQuickActionModel : function(component,event,helper){
        component.set("v.showSpinner",true);
        var res=component.get("v.sessionList");
        console.log('res-->'+res);
        var artId = component.get("v.recordId");
        
        var action =component.get("c.insertSessions");
        action.setParams({
            "sessList": res,
            "recordId": artId
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state=='SUCCESS'){
                helper.showToast(component,event,"Success","Class term have been successfully scheduled.");
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
})