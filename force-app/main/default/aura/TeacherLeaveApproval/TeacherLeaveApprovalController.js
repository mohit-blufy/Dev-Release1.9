({
    doInit : function(component, event, helper) {
        if(component.get("v.simpleRecord.Status__c") == 'Requested'){
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
        else if(component.get("v.shwError")){
            helper.showToast(component,event,"ERROR!","The leave is already "+component.get("v.simpleRecord.Status__c"),"error");
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    
    handleMyApplicationEvent : function(component, event, helper) {
        var valueId = event.getParam("selectedOption");  
        var value = event.getParam("inputValue");
        var indx = event.getParam("slctIndex");
        
        var sessionList= component.get("v.sessionList");
        sessionList[indx].tchrId = valueId;
        sessionList[indx].tchrName = value;
        component.set("v.sessionList",sessionList);
    },
    
    doSave : function(component, event, helper){
        component.set("v.showSpinner",true);
        var action = component.get("c.doSaveApex");
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "listSession" : (component.get("v.sessionList"))
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue().includes("SUCCESS")){
                    helper.showToast(component,event,"SUCCESS!","Teacher leave has been approved successfully","success");
                    component.set("v.shwError",false);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    helper.showToast(component,event,"ERROR!",response.getReturnValue(),"error");
                }       
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    doCancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    }, 
})