({
    doInit : function(component, event, helper){
        component.set("v.showSpinner",true);
        var action = component.get("c.doInitApex");
        action.setParams({
            "recordId": component.get("v.recordId")  
        }); 
        
        action.setCallback(this,function(response){        
            if(response.getState() ==="SUCCESS" ){
                if(response.getReturnValue().message === "SUCCESS" && response.getReturnValue().status == 'Enrolled'){ 
                    component.set("v.showComponent",true);
                    component.set("v.wrpCls",response.getReturnValue());
                    component.set("v.canReaPicklist",response.getReturnValue().picklistCanReasValues);
                    //component.set("v.listCreditNote",response.getReturnValue().listCreditNote);
                    component.set("v.depositedAmount",response.getReturnValue().depositedAmount);
                    component.set("v.unBilledAmount",response.getReturnValue().unBilledAmount);
                    component.set("v.custEnrolCount",response.getReturnValue().custEnrolCount);
                }
                else if(!response.getReturnValue().message.includes('SUCCESS')){
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast(component,event,"ERROR!",response.getReturnValue().message,"error");
                }
                    else{
                        $A.get("e.force:closeQuickAction").fire();
                        helper.showToast(component,event,"ERROR!","Only Enrolments with enrolled status can be cancelled","error");
                    }
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    doProcessEnrolment : function(component, event, helper){
        var count = 0;
        if($A.util.isEmpty(component.get("v.wrpCls.enrolCancelResn"))){
            component.find('canResn').showHelpMessageIfInvalid();
            count = 1;
        }
        if($A.util.isEmpty(component.get("v.wrpCls.enrolCancelComm"))){
            component.find('cancelCom').showHelpMessageIfInvalid();
            count = 1;
        }
        
        if(count == 0){
            console.log(JSON.stringify(component.get("v.wrpCls")))
            component.set("v.showSpinner",true);
            var action = component.get("c.doProcessEnrolmentApex");
            action.setParams({
                "btnLabel" : event.getSource().get("v.label"),
                "wrpClsStr" : JSON.stringify(component.get("v.wrpCls"))
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    if(response.getReturnValue().includes('SUCCESS')){
                        if(response.getReturnValue().includes('#')){
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": response.getReturnValue().split('#')[1],
                                "slideDevName": "related"
                            });
                            navEvt.fire();
                            helper.showToast(component,event,"SUCCESS!","Invoice has been processed successfully","success");
                        }
                        else{
                            $A.get('e.force:refreshView').fire();
                            helper.showToast(component,event,"SUCCESS!","Enrollment has been cancelled successfully","success");
                        }
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else{
                        helper.showToast(component,event,"SUCCESS!",response.getReturnValue(),"success");
                    }
                }
                component.set("v.showSpinner",false);
            });
            $A.enqueueAction(action);
        }
    },
    
    doClose : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
})