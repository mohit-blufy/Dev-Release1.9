({
    searchRecords : function(component, searchString) {
        var checkStuType = component.get("v.type");
        
        if(checkStuType != 'Student' || (checkStuType == 'Student' && component.get("v.extendedWhereClause").length > 0)){
            this.showSpinner(component);
            var action = component.get("c.getRecords");
            action.setParams({
                "searchString" : searchString,
                "objectApiName" : component.get("v.objectApiName"),
                "idFieldApiName" : component.get("v.idFieldApiName"),
                "valueFieldApiName" : component.get("v.valueFieldApiName"),
                "extendedWhereClause" : component.get("v.extendedWhereClause"),
                "maxRecords" : component.get("v.maxRecords")
            });
            action.setCallback(this,function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    const serverResult = response.getReturnValue();
                    const results = [];
                    if(component.get("v.objectApiName") != 'Account'){
                        serverResult.forEach(element => {
                            const result = {id : element[component.get("v.idFieldApiName")], value : element[component.get("v.valueFieldApiName")]};
                            results.push(result);
                       		// alert(JSON.stringify(results));
                        });
                     }else{
                         serverResult.forEach(element => {
                            var perEmail = element['PersonEmail'];
                            if(!perEmail)
                                perEmail = '';
                            var showTitle = element['FirstName'] +' '+perEmail;
                            
                            if(!element['FirstName'])
                               showTitle = element['Name'] +' '+perEmail;
                             
                            var type = component.get("v.type"); 
                            if(type == 'Teacher')
                                showTitle = element['Name'];
                            const result  = {id : element[component.get("v.idFieldApiName")], value : showTitle};
                            results.push(result);
                        });
                     }
                    
                    component.set("v.results", results);
                    if(serverResult.length>0){
                        component.set("v.openDropDown", true);
                    }
                } else{
                    var toastEvent = $A.get("e.force:showToast");
                    if(toastEvent){
                        toastEvent.setParams({
                            "title": "ERROR",
                            "type": "error",
                            "message": "Something went wrong!! Check server logs!!"
                        });
                        toastEvent.fire();
                    }
                }
        		this.hideSpinner(component);
            });
            $A.enqueueAction(action);
		}
    },  
    showSpinner : function(component){
        component.set("v.isShowSpinner", true);  
    },
    hideSpinner : function(component){
        component.set("v.isShowSpinner", false);
    },   
});