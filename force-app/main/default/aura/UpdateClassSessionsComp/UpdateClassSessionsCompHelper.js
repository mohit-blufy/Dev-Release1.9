({
    
    checkAvailabilityHelper : function(component, event,sessionList,indx) {
        var roomName = '';
        var teacherName = '';
        if(!$A.util.isEmpty(sessionList[indx].roomName)){
            roomName = sessionList[indx].roomName;
        }
        if(!$A.util.isEmpty(sessionList[indx].tchrName)){
            teacherName = sessionList[indx].tchrName;
        }
        
        var action = component.get("c.checkTeacherRoomAvailability");
        if(!$A.util.isEmpty(sessionList[indx].roomName) && !$A.util.isEmpty(sessionList[indx].tchrName)){
            action.setParams({
                "session" : JSON.stringify(sessionList[indx]),
                "type" : ""
            });
        }
        else if(!$A.util.isEmpty(sessionList[indx].roomName)){
            action.setParams({
                "session" : JSON.stringify(sessionList[indx]),
                "type" : "Room"
            });
        }
            else if(!$A.util.isEmpty(sessionList[indx].tchrName)){
                action.setParams({
                    "session" : JSON.stringify(sessionList[indx]),
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
    
    showToast : function(component, event, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    }
})