({
    doInit : function(component, event, helper) {
        helper.getRecords(component, event);
    },
    closeModal : function(component, event, helper) {
        component.set("v.isModalOpen",false);
    },
    searchRecords : function(component, event, helper){
        helper.getRecords(component, event);
    },
    getValue : function(component, event, helper){        
        console.log('call');  
        alert('please wait our robots are bulding further logic');
        var index = event.currentTarget.dataset.rowIndex;
        console.log(index); 
        let name = event.currentTarget.dataset.name;
        console.log(name);
    }
})
