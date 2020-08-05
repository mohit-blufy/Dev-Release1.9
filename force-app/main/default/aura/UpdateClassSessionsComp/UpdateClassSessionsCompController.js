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
                    if(response.getReturnValue().length > 0){
                        component.set("v.sessionList",response.getReturnValue());
                    }
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
        helper.checkAvailabilityHelper(component,event,sessionList,indx);
    },
    
    doCancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doSave : function(component,event,helper){
        var count = 0;
        for(var i=0; i< component.get("v.sessionList").length ; i++){
            if($A.util.isEmpty(component.get("v.sessionList")[i].sessSequence)){
                document.getElementById([i]+'_sSeq').classList.add('slds-has-error');
                document.getElementById('sSeqErr_'+[i]).style.display = 'block';
                count=1;
            }
            if($A.util.isEmpty(component.get("v.sessionList")[i].stDate)){
                document.getElementById([i]+'_sDate').classList.add('slds-has-error');
                document.getElementById('sDateErr_'+[i]).style.display = 'block';
                count=1;
            }
            if($A.util.isEmpty(component.get("v.sessionList")[i].stTime)){
                document.getElementById([i]+'_sTime').classList.add('slds-has-error');
                document.getElementById('sTimeErr_'+[i]).style.display = 'block';
                count=1;
            }
            if($A.util.isEmpty(component.get("v.sessionList")[i].tchrId)){
                document.getElementById([i]+'_sTchr').classList.add('slds-has-error');
                document.getElementById('sTchrErr_'+[i]).style.display = 'block';
                count=1;
            }
        }
        
        //alert(JSON.stringify(component.get("v.sessionList")))
        if(count == 0){
            component.set("v.showSpinner",true);
            var action = component.get("c.doSaveApex");
            action.setParams({
                "listSessionString" : JSON.stringify(component.get("v.sessionList")) 
            });
            
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    if(response.getReturnValue().includes("SUCCESS")){
                        helper.showToast(component,event,'SUCCESS!','Sessions have been updated successfully','success')
                    }
                    else{
                        helper.showToast(component,event,'ERROR!',response.getReturnValue(),'error');
                    }
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.showSpinner",false);
                } 
            });
            $A.enqueueAction(action);   
        }
        else{
            helper.showToast(component,event,'ERROR!','Please Fill Session Details Properly','error');
        }
    },
    
    checkAvailablity : function(component,event,helper){
        var key = event.target.id.split('_');
        var index = key[0];
        var sessionList= component.get("v.sessionList");
        helper.checkAvailabilityHelper(component,event,sessionList,index);
    }
})