({
    fetchGender: function(component, ObjectApiName,  fieldName) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "ObjectApi_name": ObjectApiName,
            "Field_name": fieldName
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.genderList", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    fetchRelationsShip: function(component, ObjectApiName,  fieldName) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "ObjectApi_name": ObjectApiName,
            "Field_name": fieldName
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.relationShipList", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    /*  fetchCntry: function(component, ObjectApiName,  fieldName) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "ObjectApi_name": ObjectApiName,
            "Field_name": fieldName
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.cntryList", allValues);
            }
        });
        $A.enqueueAction(action);
    },*/
    fetchPayMode: function(component, ObjectApiName,  fieldName) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "ObjectApi_name": ObjectApiName,
            "Field_name": fieldName
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.payModeList", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    initilizeCstmrList: function(component, event) {
        var action = component.get("c.blankInitializeCstmrWrpr");
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            component.set("v.stuClsWrapper",res);
        });
        
        $A.enqueueAction(action);
    },
    fetchTermAndCon: function(component, event) {
        var action = component.get("c.fetchTermAndCondition");
        action.setCallback(this,function(result){            
            component.set('v.termsCondMap',result.getReturnValue());
            console.log(result.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    calculationOnFeeCheck: function(component, event, crsObj,srchRFee) {
      //  alert('check');
        var slcdTstionFeeAmt  = 0;
        
        //tution fee addition
        var feeList = crsObj.tutionFeeWrapperList; 
        for(var i = 0; i < feeList.length; i++){
            if(feeList[i].isSelected){
                slcdTstionFeeAmt += feeList[i].feeAmount;
            }
        }

        
        //Other fee addition 
        feeList = crsObj.feeWrapperList; 
        for(var i = 0; i < feeList.length; i++){
            if(feeList[i].isSelected)
                slcdTstionFeeAmt += feeList[i].feeAmount;
        }
        //Deposit fee addition 
        feeList = crsObj.depositWrapperList;
        for(var i = 0; i < feeList.length; i++){
            if(feeList[i].isSelected)
                slcdTstionFeeAmt += feeList[i].feeAmount;
        }
        
        //Other course discount deduction
        var disList = crsObj.disWrapperList;
        for(var i = 0; i < disList.length; i++){
            if(disList[i].isSelected)
                slcdTstionFeeAmt -= disList[i].amount;
        }
        
        //Early bird discount deduction
        disList = crsObj.earlybirdDisWrapperList;
        for(var i = 0; i < disList.length; i++){
            if(disList[i].isSelected)
                slcdTstionFeeAmt -= disList[i].amount;
        }
        console.log('@@@-->'+slcdTstionFeeAmt);
        crsObj.totFee = slcdTstionFeeAmt;
        component.set("v.slcdCrsObject", crsObj);
    },
    calculationOnDisCheck: function(component, event, isEarlybird) {
        var selectedCheckText = event.getSource().get("v.text");
        var indx = parseInt(selectedCheckText);
        
        var crsObj = component.get("v.slcdCrsObject");
        var slcdDisFeeAmt  = crsObj.disWrapperList[indx].amount;
        if(isEarlybird)
            slcdDisFeeAmt  = crsObj.earlybirdDisWrapperList[indx].amount;
        
        if(event.getSource().get("v.value"))
            crsObj.totFee = crsObj.totFee - slcdDisFeeAmt;
        else
            crsObj.totFee = crsObj.totFee + slcdDisFeeAmt;
        
        component.set("v.slcdCrsObject", crsObj);
    },
    totAmountcalculation: function(component, event, slctdCrsWithStuList) {
        //var slctdCrsWithStuList= component.get("v.stuClsWrapperList");
        var grandTot = 0;
        var totDepFee = 0;
        var gstAppFeeAmount = 0;
        for(var i = 0; i < slctdCrsWithStuList.length; i++){
            var slcdCrsList = slctdCrsWithStuList[i].slctdClsDetails
            for(var j = 0; j < slcdCrsList.length; j++){
                var slcdTstionFeeAmt  = 0;
                var tuitionfee = 0;
                //tution fee addition
                var feeList = slcdCrsList[j].tutionFeeWrapperList; 
                for(var k = 0; k < feeList.length; k++){
                    if(feeList[k].feeProratedAmount > 0)
                        slcdTstionFeeAmt += feeList[k].feeProratedAmount;
                    else
                        slcdTstionFeeAmt += feeList[k].feeAmount;
                    tuitionfee = slcdTstionFeeAmt;
                    if(feeList[k].isGSTApplicable && feeList[k].feeProratedAmount > 0)
                        gstAppFeeAmount += feeList[k].feeProratedAmount;
                    else if(feeList[k].isGSTApplicable)
                        gstAppFeeAmount += feeList[k].feeAmount;
                }
                
                //Other fee addition 
                feeList = slcdCrsList[j].feeWrapperList; 
                for(var k = 0; k < feeList.length; k++){
                    if(feeList[k].isSelected)
                        slcdTstionFeeAmt += feeList[k].feeAmount;
                    
                    if(feeList[k].isGSTApplicable)
                            gstAppFeeAmount += feeList[k].feeAmount;
                }
                //Deposit fee addition 
                feeList = slcdCrsList[j].depositWrapperList;
                for(var k = 0; k < feeList.length; k++){
                    if(feeList[k].isSelected){
                        slcdTstionFeeAmt += feeList[k].feeAmount;
                        //totDepFee += feeList[k].feeAmount;
                        
                        if(feeList[k].isGSTApplicable)
                            gstAppFeeAmount += feeList[k].feeAmount;
                    }
                }
                
                //Other course discount deduction
                var disList = slcdCrsList[j].disWrapperList;
                for(var k = 0; k < disList.length; k++){
                    if(disList[k].isSelected){
                        if(disList[k].format == 'Percent'){
                            slcdTstionFeeAmt -= (tuitionfee * disList[k].amount/100);
                        }
                        else{
                            slcdTstionFeeAmt -= disList[k].amount;
                        }
                    }
                        
                    
                }
                
                //Early bird discount deduction
                disList = slcdCrsList[j].earlybirdDisWrapperList;
                for(var k = 0; k < disList.length; k++){
                    if(disList[k].isSelected)
                        slcdTstionFeeAmt -= disList[k].amount;
                }
                slcdCrsList[j].totWithProratedFee = slcdTstionFeeAmt;
                grandTot += slcdTstionFeeAmt;
            }
        }
        
        var gstPrcnt = parseInt($A.get("{!$Label.c.GST_Rate}"));
        //var tempAmt = grandTot-totDepFee; 
        var tempAmt = (gstAppFeeAmount*gstPrcnt/100);                            
        component.set("v.gstAmount", tempAmt); 
        
        component.set("v.enrFeeTotAmt", grandTot); 
        component.set("v.grandTotAmt", grandTot + tempAmt); 
        component.set("v.stuClsWrapperList", slctdCrsWithStuList);
    },
    alertToast : function(component, event, type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type+"!",
            "type" : type,
            "message": msg
        });
        toastEvent.fire();
    },
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
})