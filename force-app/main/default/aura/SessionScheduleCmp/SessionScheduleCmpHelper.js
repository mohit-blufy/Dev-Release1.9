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
    
    checkAvailabilityHelper : function(component, event,sessionList,indx) {
        var roomName = '';
        var teacherName = '';
        if(!$A.util.isEmpty(sessionList[indx].roomName)){
            roomName = sessionList[indx].roomName;
        }
        if(!$A.util.isEmpty(sessionList[indx].tchrName)){
            teacherName = sessionList[indx].tchrName;
        }
        var action = component.get("c.checkTeacherOrRoomAvailability");
        if(!$A.util.isEmpty(sessionList[indx].roomName) && !$A.util.isEmpty(sessionList[indx].tchrName)){
            action.setParams({
                "session" : sessionList[indx],
                "type" : ""
            });
        }
        else if(!$A.util.isEmpty(sessionList[indx].roomName)){
            action.setParams({
                "session" : sessionList[indx],
                "type" : "Room"
            });
        }
            else if(!$A.util.isEmpty(sessionList[indx].tchrName)){
                action.setParams({
                    "session" : sessionList[indx],
                    "type" : "Teacher"
                });
            }	    
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue() != null){
                    var sessList = component.get("v.sessionList");
                    sessList[indx] = response.getReturnValue();
                    if(!$A.util.isEmpty(roomName)){
                        sessList[indx].roomName = roomName;
                    }
                    if(!$A.util.isEmpty(teacherName)){
                        sessList[indx].tchrName = teacherName;
                    }
                    component.set("v.sessionList",sessList);
                }
            }
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