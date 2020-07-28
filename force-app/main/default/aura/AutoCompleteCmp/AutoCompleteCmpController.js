({
    doInit : function (component, event, helper) {
       // alert(component.get("v.inputValue") +'<---->'+component.get("v.selectedOption"));
      /*  if(component.get("v.inputValue")){
            component.set("v.inputValue", component.get("v.selectedOption"));
            component.set("v.openDropDown", false);
            component.set("v.selectedOption", component.get("v.inputValue"));
        }*/
    },    
    searchHandler : function (component, event, helper) {
        const searchString = event.target.value;
        
        if (searchString.length >= 3) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchFunction")) {
                clearTimeout(component.get("v.inputSearchFunction"));
            }

            var inputTimer = setTimeout($A.getCallback(function () {
                var objName = component.get("v.objectApiName");
                helper.searchRecords(component, searchString);
            }), 1000);
            component.set("v.inputSearchFunction", inputTimer);
        } else{
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
    },

    optionClickHandler : function (component, event, helper) {
        var selectedId = event.target.closest('li').dataset.id;
        var selectedValue = event.target.closest('li').dataset.value;
        //alert(component.get("v.objectApiName") == "Account");
        if(component.get("v.objectApiName") == "Account"){
            /*var nameList = selectedValue.split(" ");
            selectedValue = nameList[0];
            
            if(component.get("v.type") == 'Teacher')
                selectedValue = nameList;*/
           // alert(selectedValue);
            if(component.get("v.type") != 'Teacher' && component.get("v.type") != 'Corporate'){
                var nameList = selectedValue.split(" ");
            	selectedValue = nameList[0]
            }
        }
        
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
        
        var myEvent =  component.getEvent("myApplicationEvent");
        myEvent.setParams({"inputValue": selectedValue});
        myEvent.setParams({"selectedOption": selectedId});
        myEvent.setParams({"slctIndex": component.get("v.slcdIndex")});
        myEvent.setParams({"type": component.get("v.type")});
        myEvent.fire();
    },
	checkOnFocusOut : function (component, event, helper) {
        console.log(' sdf--->'+component.get("v.openDropDown"));
        //if(component.get("v.openDropDown"))
   		//	component.set("v.openDropDown", false);
   		const blurTimeout = window.setTimeout(
            $A.getCallback(() => {
                console.log('sdf-->'+component.get("v.openDropDown"));
                component.set("v.openDropDown", false);
            }),
            300
        );	
    },
    clearOption : function (component, event, helper) {
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
    },
   
})