({
    doInit : function(component,event,helper){
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.maxBirthDate",today);
        component.set("v.toggleSpinner", true);
        
        var action = component.get("c.fetchCourses");
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            component.set("v.crsList",res);
            
            // helper.fetchCntry(component, 'Account', 'BillingCountryCode');
            helper.fetchGender(component, 'Account', 'Gender__c');
            helper.fetchRelationsShip(component, 'Account', 'Relationship_with_contact__c');
            helper.fetchPayMode(component, 'Payment__c', 'Cash_Mode__c');
            helper.initilizeCstmrList(component, event);
            helper.fetchTermAndCon(component, event);            
            component.set("v.toggleSpinner", false);
        });        
        $A.enqueueAction(action);
        
        /* helper.fetchCntry(component, 'Account', 'BillingCountryCode');
        helper.fetchGender(component, 'Account', 'Gender__c');
        helper.fetchRelationsShip(component, 'Account', 'Relationship_with_contact__c');
        helper.initilizeCstmrList(component, event, 'Relationship_with_contact__c');
        */
        //component.set("v.toggleSpinner", false);  
    },  
    
    addStudent : function(component, event, helper) {
        //Parent first name
        var firstdName = document.getElementById("contactId").value;
        var allValid  = true;
        if(!component.get("v.isCorporateAccount")){
            allValid = component.find('conDetReqId').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        }
        
        var parFirstName = document.getElementById("contactId").value;
        var noFirstCsmtIssue = true;
        if($A.util.isEmpty(parFirstName)){
            document.getElementById("requiredContactErrorMsg").style.display = 'block';
            noFirstCsmtIssue = false;
        }else{
            document.getElementById("requiredContactErrorMsg").style.display = 'none';
        }
        
        if(allValid && noFirstCsmtIssue){
            component.set("v.toggleSpinner", true);
            var slctdCrsList= component.get("v.stuClsWrapperList");       
            if(slctdCrsList == null)
                slctdCrsList = [];
            
            var action = component.get("c.blankInitializeCstmrWrpr");
            action.setCallback(this,function(result){
                var res = result.getReturnValue();
                // console.log('@@@@@ add student res   '+JSON.stringify(res));
                if(component.get("v.isSameAsParent")){
                    res.studentDetails.FirstName = parFirstName;
                    res.studentDetails.LastName  = component.get("v.contactDetail.LastName"); 
                    res.studentDetails.Relationship_with_contact__c = 'Self'
                }
                slctdCrsList.push(res);
                component.set("v.stuClsWrapperList",slctdCrsList);
                // console.log('@@@@@  add student stuClsWrapperList   '+ JSON.stringify(component.get("v.stuClsWrapperList")));
                
                component.set("v.toggleSpinner", false);
            });
            
            $A.enqueueAction(action);
        }else{
            helper.alertToast(component, event, "error", "Please fill all required contact detail.");
        }
    },
    deleteStudent : function(component, event, helper) {
        var slctdCrsList= component.get("v.stuClsWrapperList");
        // console.log('@@@@@ slctdCrsList '+JSON.stringify(slctdCrsList));
        var indx = parseInt(event.target.id);
        slctdCrsList.splice(indx,1);
        component.set("v.stuClsWrapperList",slctdCrsList);      
        helper.alertToast(component, event, "Success", "Student successfully removed.");
    },
    selectClass : function(component, event, helper) {
        var selectedCheckText = event.getSource().get("v.text");
        var getAllId = component.find("clsSlcd");
        for (var i = 0; i < getAllId.length; i++) {
            var checkBoxObj = component.find("clsSlcd")[i];
            if(selectedCheckText != checkBoxObj.get("v.text")){
                checkBoxObj.set("v.value", false);
            }
        }
        
        var indx = parseInt(selectedCheckText);
        var crsObj = component.get("v.slcdCrsObject");
        var feeToRemove = [];
        for(var j = 0; j < crsObj.feeWrapperList.length; j++){
            if(!$A.util.isEmpty(crsObj.feeWrapperList[j].feeParent)){
                feeToRemove.push(crsObj.feeWrapperList[j]);
            }   
        }
        crsObj.feeWrapperList = crsObj.feeWrapperList.filter(value => !feeToRemove.includes(value))
        
        var slcdCls = crsObj.classWrapperList[indx];
        crsObj.slcdClsWrapObj = slcdCls;
        crsObj.enrolEndDate = crsObj.slcdClsWrapObj.clsEndDate;
        if(event.getSource().get("v.value")){
            //Early bird discount
            var action = component.get("c.checkEarlyBirdDiscount");
            action.setParams({
                "clsWrapStr" : JSON.stringify(slcdCls)
            });
            action.setCallback(this,function(result){
                console.log(result.getState());
                if(result.getState() == "SUCCESS") {
                    var res = result.getReturnValue();
                    crsObj.earlybirdDisWrapperList = res;
                    // console.log(res);
                    var slcdDisFeeAmt  = 0;
                    for (var i = 0; i < res.length; i++) {
                        if(res[i].isSelected)
                            slcdDisFeeAmt += res[i].amount;
                    }
                    crsObj.totFee = crsObj.totFee - slcdDisFeeAmt;
                    component.set("v.slcdCrsObject", crsObj);
                }else{
                    let errors = result.getError();
                    let message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    //alert(message);    
                    console.log(message);
                }
            });
            
            $A.enqueueAction(action);
            
            //Check tution fee term amount bases of the session in active current sessino class term
            //if( res.typeAddEdit != "Edit"){
            var action1 = component.get("c.fetchClsTermSessionAmount");
            action1.setParams({
                "clsStr" : JSON.stringify(slcdCls),
                "tutionFeeWrapperListStr": JSON.stringify(crsObj.tutionFeeWrapperList)
            });
            action1.setCallback(this,function(result){
                var res = result.getReturnValue();
                crsObj.tutionFeeWrapperList = res;
                
                var slcdTstionFeeAmt  = 0;
                for (var i = 0; i < res.length; i++) {
                    if(res[i].isSelected)
                        slcdTstionFeeAmt = res[i].feeAmount;
                }
                crsObj.slcdClsWrapObj.fees = slcdTstionFeeAmt;
                helper.calculationOnFeeCheck(component, event, crsObj,true);
                //component.set("v.slcdCrsObject", crsObj);
            });
            
            $A.enqueueAction(action1);
        }else{
            crsObj.earlybirdDisWrapperList = [];
        }
        component.set("v.slcdCrsObject", crsObj);
    },
    tutionFeeOnCheck : function(component, event, helper) {
        var selectedCheckText = event.getSource().get("v.text");
        var getAllId = component.find("tutionFeeChk");
        if(getAllId){
            for (var i = 0; i < getAllId.length; i++) {
                var checkBoxObj = component.find("tutionFeeChk")[i];
                if(selectedCheckText != checkBoxObj.get("v.text")){
                    checkBoxObj.set("v.value", false);
                }
            }
        }
        
        //Calcuting total fee amount for the class, When tution fee selected
        //Tution fee addition 
        var indx = parseInt(selectedCheckText);
        var crsObj = component.get("v.slcdCrsObject");
        var rfeeAmt = 0;
        var slcdTstionFeeAmt  = 0;
        var slcdFeeId = '';
        if( event.getSource().get("v.value")){
            slcdFeeId = crsObj.tutionFeeWrapperList[indx].feeId;
            slcdTstionFeeAmt = crsObj.tutionFeeWrapperList[indx].feeAmount;
        }
        
        if(!$A.util.isEmpty(slcdFeeId)){
            var action = component.get("c.getRelatedFeeApex");
            action.setParams({
                "feeId" : slcdFeeId
            });
            
            action.setCallback(this,function(response){   
                var updatedList = [];
                if(response.getReturnValue().length > 0){
                    var feeList = response.getReturnValue();
                    var feeWrapId = [];
                    for( var j = 0 ; j < crsObj.feeWrapperList.length; j++){
                        feeWrapId.push(crsObj.feeWrapperList[j].feeId);
                    }
                    rfeeAmt = 0;
                    
                    for(var i = 0; i < feeList.length ; i++){
                        if(!feeWrapId.includes(feeList[i].feeId)){
                            //crsObj.feeWrapperList.push(feeList[i]);
                            updatedList.push(feeList[i]);
                            if(feeList[i].isSelected)
                                rfeeAmt += feeList[i].feeAmount;
                        }   
                    }
                }
                for(var j = 0; j < crsObj.feeWrapperList.length; j++){
                    updatedList.push(crsObj.feeWrapperList[j]);
                }
                
                crsObj.feeWrapperList = updatedList;
                var feeToRemove = [];
                for(var j = 0; j < crsObj.feeWrapperList.length; j++){
                    if(!$A.util.isEmpty(crsObj.feeWrapperList[j].feeParent) && crsObj.feeWrapperList[j].feeParent != slcdFeeId){
                        feeToRemove.push(crsObj.feeWrapperList[j]);
                        if(crsObj.feeWrapperList[j].isSelected)
                            rfeeAmt -= crsObj.feeWrapperList[j].feeAmount;
                    }   
                }
                crsObj.feeWrapperList = crsObj.feeWrapperList.filter(value => !feeToRemove.includes(value))
                crsObj.totFee += rfeeAmt;
                component.set("v.slcdCrsObject", crsObj);
            });            
            $A.enqueueAction(action);
        }
        else{
            var feeToRemove = [];
            for(var j = 0; j < crsObj.feeWrapperList.length; j++){
                if(!$A.util.isEmpty(crsObj.feeWrapperList[j].feeParent)){
                    feeToRemove.push(crsObj.feeWrapperList[j]);
                }   
            }
            crsObj.feeWrapperList = crsObj.feeWrapperList.filter(value => !feeToRemove.includes(value))
            component.set("v.slcdCrsObject", crsObj);
        }
        
        crsObj.slcdClsWrapObj.fees = slcdTstionFeeAmt;
        helper.calculationOnFeeCheck(component, event, crsObj,true);
        //Other fee addition 
        /*  var feeList = crsObj.feeWrapperList; 
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

        //Early bird discount deduction
        var disist = crsObj.earlybirdDisWrapperList;
        for(var i = 0; i < disist.length; i++){
            if(disist[i].isSelected)
                slcdTstionFeeAmt -= feeList[i].feeAmount;
        }

        crsObj.totFee = slcdTstionFeeAmt;
        component.set("v.slcdCrsObject", crsObj);*/
    },
    feeOnCheck : function(component, event, helper) {
        var crsObj = component.get("v.slcdCrsObject");
        helper.calculationOnFeeCheck(component, event, crsObj,false);
    },
    crsDiscountOnCheck : function(component, event, helper) {
        var isEarlyBirdDis = false;
        helper.calculationOnDisCheck(component, event, isEarlyBirdDis);
    },
    discountOnCheck : function(component, event, helper) {
        /* var selectedCheckText = event.getSource().get("v.text");
        var indx = parseInt(selectedCheckText);
        
        var crsObj = component.get("{!v.slcdCrsObject}");
        var slcdDisFeeAmt  = crsObj.earlybirdDisWrapperList[indx].amount;
        
        if(event.getSource().get("v.value"))
            crsObj.totFee = crsObj.totFee - slcdDisFeeAmt;
        else
            crsObj.totFee = crsObj.totFee + slcdDisFeeAmt;
        
        component.set("v.slcdCrsObject", crsObj);*/
        var isEarlyBirdDis = true;
        helper.calculationOnDisCheck(component, event, isEarlyBirdDis);
    },
    
    mydiscount:function(component, event) {
        var action = component.get("c.fetchOtherDiscount");
        action.setParams({
            "totalFee" : component.get("v.enrFeeTotAmt")
        });
        
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            component.set("v.globalDisList", res);
        });
        $A.enqueueAction(action);
        
        component.set("v.discountModal", true);
    },
    closeDiscountModel:function(component, event) {
        var glbDisLst = [];
        component.set("v.globalDisList", glbDisLst);
        component.set("v.discountModal", false);
    },
    globalDiscountOnCheck : function(component, event, helper) {
        var selectedCheckText = event.getSource().get("v.text");
        var indx = parseInt(selectedCheckText);
        
        var glbDisLst = component.get("v.globalDisList");
        var slcdDis  = glbDisLst[indx];
        if(event.getSource().get("v.value")){
            if(slcdDis.type == 'Promo' && slcdDis.promoCode != slcdDis.enterCode){
                helper.alertToast(component, event, "error", "Invalid code.");
            }
        }else{
            
        }
    },
    saveGlobalDiscount : function(component, event, helper) {
        var glbDisLst = component.get("v.globalDisList");
        
        var tempGlbDisLst = [];
        var totDisAmt = 0;
        for(var i = 0; i < glbDisLst.length; i++){
            if(glbDisLst[i].isSelected){
                tempGlbDisLst.push(glbDisLst[i]);
                totDisAmt += glbDisLst[i].amount;
            }
        }
        //calcuting total deposit fee for exclude 
        var slctdCrsWithStuList= component.get("v.stuClsWrapperList");
        var totDepFee = 0;
        for(var i = 0; i < slctdCrsWithStuList.length; i++){
            var slcdCrsList = slctdCrsWithStuList[i].slctdClsDetails;
            for(var j = 0; j < slcdCrsList.length; j++){
                var feeList = slcdCrsList[j].depositWrapperList;
                for(var k = 0; k < feeList.length; k++){
                    if(feeList[k].isSelected)
                        totDepFee += feeList[k].feeAmount;
                }
            }
        }
        var enrFeeTotAmt = component.get("v.enrFeeTotAmt"); 
        var grandTotAmt  = enrFeeTotAmt - (totDepFee+totDisAmt);
        var gstPrcnt 	 = parseInt($A.get("{!$Label.c.GST_Rate}"));
        var tempGstAmt	 = (grandTotAmt*gstPrcnt/100);                            
        
        
        var grandTotAmt  = enrFeeTotAmt - totDisAmt + tempGstAmt;
        
        component.set("v.gstAmount", tempGstAmt);
        /* var gstAmt       = component.get("v.gstAmount");
        var enrFeeTotAmt = component.get("v.enrFeeTotAmt"); 
        var grandTotAmt  = enrFeeTotAmt - totDisAmt + gstAmt;*/
        component.set("v.grandTotAmt", grandTotAmt);
        
        component.set("v.globalDisList", tempGlbDisLst);
        component.set("v.discountModal", false);
    },
    mymodal : function(component, event, helper) {
        var indx = parseInt(event.target.id);
        var slctdCrsList= component.get("v.stuClsWrapperList");
        var slctdStuWrap =slctdCrsList[indx];
        // alert(component.find('relationShip'+indx))
        
        
        var allValid1 = true;
        var relationValid = true;
        if(!component.get("v.isCorporateAccount") && slctdCrsList.length > 1){
            allValid1 = component.find('relationShipReq').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        }
        
        if(!component.get("v.isCorporateAccount") && slctdCrsList.length == 1 
           && $A.util.isEmpty(slctdStuWrap.studentDetails.Relationship_with_contact__c)){
            component.find('relationShipReq').showHelpMessageIfInvalid();
            relationValid = false;
        }
        
        var allValid = component.find('StuDetReqId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
        var elements = document.getElementsByClassName("stuRequired");
        var noFirstCsmtIssue = true;
        for (var i=0; i<elements.length; i++) {
            var stuFirstName = elements[i].value;
            if($A.util.isEmpty(stuFirstName)){
                document.getElementById("requiredStuErrorMsg"+i).style.display = 'block';
                noFirstCsmtIssue = false;
            }else{
                document.getElementById("requiredStuErrorMsg"+i).style.display = 'none';
            }
        }
        
        if(allValid && noFirstCsmtIssue && (allValid1 || relationValid)){
            slctdStuWrap.stuRecNo = indx;
            var stuFirstName = document.getElementById(indx+"_student").value;
            slctdStuWrap.studentDetails.FirstName = stuFirstName;
            component.set("v.stuClsWrapper",slctdStuWrap);        
            
            var crsVar = {};
            component.set("v.slcdCrsObject",crsVar);
            component.set("v.showModal", true);
        }else{
            var type = "error";
            var msg = "Please fill all required student detail.";
            helper.alertToast(component,event,type,msg);
        }
    },
    
    closemodal : function(component, event) {
        console.log('called2');
        component.set("v.showModal", false);
    },
    deleteCls : function(component, event, helper) {
        /* var selectedCheckText = event.target.id;
        var indexList = selectedCheckText.split("_");
        var slctdCrsList= component.get("v.stuClsWrapperList");
        
        var slctCrs		= slctdCrsList[indexList[0]];
        
        var grandTot = component.get("v.grandTotAmt");
        //var crsAmt = slctCrs.slctdClsDetails[indexList[1]].totFee;
        var crsAmt = slctCrs.slctdClsDetails[indexList[1]].totWithProratedFee;
        grandTot	= grandTot-crsAmt;
        component.set("v.grandTotAmt", grandTot); 
        component.set("v.enrFeeTotAmt", grandTot);
        
        slctCrs.slctdClsDetails.splice(indexList[1],1);
        slctdCrsList[indexList[0]] = slctCrs;
        component.set("v.stuClsWrapperList",slctdCrsList); */  //alert('on delete class');
        //  helper.totAmountcalculationOnDelete(component, event);
        
        var slctdCrsWithStuList= component.get("v.stuClsWrapperList");
        var selectedCheckText = event.target.id;
        var indexList = selectedCheckText.split("_");
        
        var slctCrs		= slctdCrsWithStuList[indexList[0]];
        slctCrs.slctdClsDetails.splice(indexList[1],1);
        slctdCrsWithStuList[indexList[0]] = slctCrs;
        
        // alert(JSON.stringify(slctdCrsWithStuList));
        helper.totAmountcalculation(component, event, slctdCrsWithStuList);
        /*
        var grandTot = 0;
        var totDepFee = 0;
        for(var i = 0; i < slctdCrsWithStuList.length; i++){
            var slcdCrsList = slctdCrsWithStuList[i].slctdClsDetails
            for(var j = 0; j < slcdCrsList.length; j++){
                var slcdTstionFeeAmt  = 0;
                
                //tution fee addition
                var feeList = slcdCrsList[j].tutionFeeWrapperList; 
                for(var k = 0; k < feeList.length; k++){
                    if(feeList[k].isSelected)
                        slcdTstionFeeAmt += feeList[k].feeProratedAmount;
                }
                
                //Other fee addition 
                feeList = slcdCrsList[j].feeWrapperList; 
                for(var k = 0; k < feeList.length; k++){
                    if(feeList[k].isSelected)
                        slcdTstionFeeAmt += feeList[k].feeAmount;
                }
                //Deposit fee addition 
                feeList = slcdCrsList[j].depositWrapperList;
                for(var k = 0; k < feeList.length; k++){
                    if(feeList[k].isSelected){
                        slcdTstionFeeAmt += feeList[k].feeAmount;
                        totDepFee += feeList[k].feeAmount;
                    }
                }
                
                //Other course discount deduction
                var disList = slcdCrsList[j].disWrapperList;
                for(var k = 0; k < disList.length; k++){
                    if(disList[k].isSelected)
                        slcdTstionFeeAmt -= disList[k].amount;
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
        var tempAmt = grandTot-totDepFee; 
        tempAmt = (tempAmt*gstPrcnt/100);                            
        component.set("v.gstAmount", tempAmt); 
        
        component.set("v.enrFeeTotAmt", grandTot); 
        component.set("v.grandTotAmt", grandTot + tempAmt); 
        component.set("v.stuClsWrapperList", slctdCrsWithStuList);*/
    },
    editCls : function(component, event) {
        var selectedCheckText = event.target.id;
        var indexList = selectedCheckText.split("_");
        var slctdStuCrsList= component.get("v.stuClsWrapperList");
        var slctStu		= slctdStuCrsList[indexList[0]];
        var slctStuCrs  = slctStu.slctdClsDetails[indexList[1]];
        component.set("v.stuClsWrapper",slctStu);
        
        //console.log('@@@@@ fetch crs  '+JSON.stringify(component.get("v.slcdCrsObject")));
        var action = component.get("c.editCrsClsDetails");
        action.setParams({
            "cfStr" : JSON.stringify(slctStuCrs)
        });
        action.setCallback(this,function(result){
            if(result.getState() == "SUCCESS"){
                var res = result.getReturnValue();
                console.log(JSON.stringify(res));
                if(res){
                    //component.set("v.clsList",res.classWrapperList);
                    res.typeAddEdit = "Edit";
                    res.recNo = indexList[1];
                    component.set("v.slcdCrsObject",res);
                }
            }
        });
        $A.enqueueAction(action);
        component.set("v.showModal", true);
    },
    /* filterByCheckbox : function(component,event,helper){
        var getAllId = component.find("filtrChkBox");
        var isWeekDay   = false;
        var isDaytime  = false;
        var isClassroom = false;
        for (var i = 0; i < getAllId.length; i++) {
            var checkBoxObj = component.find("filtrChkBox")[i];
            
            if(checkBoxObj.get("v.text") == "WeekDay"){
                isWeekDay   = checkBoxObj.get("v.value");
            }else if(checkBoxObj.get("v.text") == "Daytime"){
                isDaytime  = checkBoxObj.get("v.value");
            }if(checkBoxObj.get("v.text") == "Classroom"){
                isClassroom = checkBoxObj.get("v.value");
            }
        }
        
        var slcdCrs = component.set("{!v.slcdCrsObject}");
        
        var action = component.get("c.CourseFeeWrapper");
        action.setParams({
            "crId" : crsId
        });
        action.setCallback(this,function(result){
            if(result.getState() == "SUCCESS"){
                var res = result.getReturnValue();
                if(res){
                    //component.set("v.clsList",res.classWrapperList);
                    component.set("v.slcdCrsObject",res);
                }
            }
        });
        $A.enqueueAction(action);
    },*/
    handleMyApplicationEvent : function(component, event, helper) {
        // component.set("v.modelSpinner", true); 
        var valueId = event.getParam("selectedOption");  
        var value = event.getParam("inputValue");
        var type = event.getParam("type");
        console.log('@@@@@ check type '+type);
        //var slctdCrsList= component.get("v.stuClsWrapperList");
        //console.log('@@@@@1 slctdCrsList  '+JSON.stringify(slctdCrsList));
        
        if(type == 'Course'){
            component.set("v.crsId",valueId);
            var action = component.get("c.fetchCrsClsDetails");
            action.setParams({
                "crId" : valueId
            });
            action.setCallback(this,function(result){
                if(result.getState() == "SUCCESS"){
                    var res = result.getReturnValue();
                    if(res){
                        //component.set("v.clsList",res);
                        var preSlcdCrs = component.get("v.slcdCrsObject");
                        res.typeAddEdit = preSlcdCrs.typeAddEdit;
                        res.recNo = preSlcdCrs.recNo;
                        component.set("v.slcdCrsObject",res);
                    }
                }
            });            
            $A.enqueueAction(action);
        }else if(type == 'Contact' || type == 'Corporate'){
            var action = component.get("c.getchSlcdAccDetails");
            action.setParams({
                "accId" : valueId,
                "isCorporateAccount" : component.get("v.isCorporateAccount")
            });
            action.setCallback(this,function(result){
                if(result.getState() == "SUCCESS"){
                    var res = result.getReturnValue();
                    if(res){
                        component.set("v.contactDetail",res);
                        //alert(JSON.stringify(component.get("v.contactDetail")))
                    }
                }
            });            
            $A.enqueueAction(action);
        }else if(type == 'Student'){
            var indx = event.getParam("slctIndex");
            var action = component.get("c.getchSlcdAccDetails");
            action.setParams({
                "accId" : valueId,
                "isCorporateAccount" : false
            });
            action.setCallback(this,function(result){
                if(result.getState() == "SUCCESS"){
                    var res = result.getReturnValue();
                    if(res){
                        //   console.log('@@@@@ res  '+JSON.stringify(res));
                        
                        var slctdCrsList= component.get("{!v.stuClsWrapperList}");
                        //   console.log('@@@@@2 slctdCrsList  '+JSON.stringify(component.get("v.stuClsWrapperList")));
                        slctdCrsList[indx].studentDetails = res;
                        if(component.get("v.isCorporateAccount"))
                        	slctdCrsList[indx].studentDetails.Relationship_with_contact__c = '';
                        /*try{
                        	slctdCrsList[indx].studentDetails = res;
                        }catch(err) {
                            var action1 = component.get("c.blankInitializeCstmrWrpr");
                            action1.setCallback(this,function(result){
                                var res1 = result.getReturnValue();
                                console.log('@@@@@ res1   '+JSON.stringify(res1));
                                slctdCrsList.push(res1);
                                slctdCrsList[indx].studentDetails = res;
                            });
                            
                            $A.enqueueAction(action1);
                            console.log('@@@@@ error   '+err.message);
                        }*/
                        //  console.log('@@@@@ res4   '+indx);
                        //  console.log('@@@@@ res5   '+JSON.stringify(slctdCrsList[indx].studentDetails));
                        component.set("v.stuClsWrapperList",slctdCrsList);
                        //  console.log('@@@@@ res   '+JSON.stringify(component.get("v.stuClsWrapperList")));
                    }
                }
            });            
            $A.enqueueAction(action);
        }
    },
    sameAsContact:function(component,event,helper){
        var contactDetail = component.get("v.contactDetail");  
        component.set("v.stuClsWrapper.studentDetail.FirstName",contactDetail.FirstName);
        component.set("v.stuClsWrapper.studentDetail.LastName",contactDetail.LastName);
    },
    addCourses:function(component,event,helper){
        var clsList 	= component.get("v.clsList");  
        var slctdCrsList= component.get("v.stuClsWrapperList"); 
        
        if(slctdCrsList == null)
            slctdCrsList = [];
        
        var stuDetWithCrs = component.get("v.stuClsWrapper");
        
        for(var i = 0; i < clsList.length; i++){
            var slcdCrs = clsList[i];
            if(slcdCrs.isSelected){
                stuDetWithCrs.slctdClsDetails.push(slcdCrs);
            } 
        }
        //component.set("v.slcdClsName",slcdClsName);
        component.set("v.stuClsWrapper",stuDetWithCrs);
    },
    /*call dateUpdate function on onchange event on date field*/ 
    validateEnrDate : function(component, event, helper) {
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var slcdCrd = component.get("v.slcdCrsObject");
        var slcdDate= slcdCrd.enrolDate;
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(slcdDate != '' && slcdDate < todayFormattedDate){
            component.set("v.dateValidationError" , true);
        }else{
            component.set("v.dateValidationError" , false);
        }
    },
    saveStudentCrs:function(component,event,helper){      
        var isError = true;
        var errMsg  = "";
        var getAllId = component.find("clsSlcd");
        if(getAllId.length){
            for (var i = 0; i < getAllId.length; i++) {
                var checkBoxObj = component.find("clsSlcd")[i];//alert(checkBoxObj.get("v.value"));
                if(checkBoxObj.get("v.value")){
                    isError = false;
                }
            }    
        }else{
            if(getAllId.get("v.value"))
                isError = false;
        }
        // alert("sdf     "+isError);
        if(isError){
            errMsg ="Please select a class.";
        }else{
            isError = true;
            var getAllTutionFeeId = component.find("tutionFeeChk");
            
            if(getAllTutionFeeId.length){
                for (var j = 0; j < getAllTutionFeeId.length; j++) {
                    var checkBoxObj = component.find("tutionFeeChk")[j];
                    if(checkBoxObj.get("v.value")){
                        isError = false;
                    }
                }
            }else{
                if(getAllTutionFeeId.get("v.value"))
                    isError = false;
            }
            
            if(isError){
                errMsg ="Please select a Tuition Fee.";
            }else{
                var allValid = component.find('enrIds').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && !inputCmp.get('v.validity').valueMissing;
                }, true);
                
                if(!allValid){
                    isError = true;
                    errMsg ="Please fill all required fields.";
                }
            }
        }
        var oneTimefreqCheck = false;
        var eDateCheck = false;
        if(!$A.util.isEmpty(component.get("v.slcdCrsObject.tutionFeeWrapperList"))){
            for(var i = 0; i< component.get("v.slcdCrsObject.tutionFeeWrapperList").length ; i++){
                if(component.get("v.slcdCrsObject.tutionFeeWrapperList")[i].isSelected && component.get("v.slcdCrsObject.tutionFeeWrapperList")[i].payFrequency === 'One-time'){
                    oneTimefreqCheck = true;
                }
            }
        }
        
        if(oneTimefreqCheck){
            if($A.util.isEmpty(component.get("v.slcdCrsObject.enrolEndDate"))){
                component.set("v.eDateRequiredError",true);
                errMsg ="Please fill all required fields.";
                eDateCheck = true;
                
            }
            else{
                eDateCheck = false;
                component.set("v.eDateRequiredError",false);
            }
            
        }else{       
            component.set("v.eDateRequiredError",false);
        }
        if(isError || eDateCheck){
            helper.alertToast(component,event,'Error',errMsg);
        }else{
            var crsObj = component.get("v.slcdCrsObject"); //alert(JSON.stringify(crsObj)
            console.log(JSON.stringify(crsObj));
            var action = component.get("c.calculateProratedAmount");
            action.setParams({"slcdCrsObjStr" : JSON.stringify(crsObj)});
            action.setCallback(this,function(result){
                if(result.getState() == "SUCCESS"){
                    var res = result.getReturnValue();
                    // console.log(JSON.stringify(res));
                    if(res){
                        //alert(JSON.stringify(res.tutionFeeWrapperList));   
                        //Process for early bird discount 
                        var slcdDis;
                        for(var i = 0; i < crsObj.earlybirdDisWrapperList.length; i++){
                            var slcdDiscount= crsObj.earlybirdDisWrapperList[i];
                            if(slcdDiscount.isSelected)
                                slcdDis = slcdDiscount;
                        }
                        res.earlybirdDisWrapperList = [];
                        if(slcdDis)
                            res.earlybirdDisWrapperList.push(slcdDis);   
                        
                        //Other Fee
                        res.feeWrapperList = [];
                        for(var i = 0; i < crsObj.feeWrapperList.length; i++){
                            var slcdFee = crsObj.feeWrapperList[i];
                            if(slcdFee.isSelected)
                                res.feeWrapperList.push(slcdFee); 
                        }
                        
                        //Deposit Fee
                        res.depositWrapperList = [];
                        for(var i = 0; i < crsObj.depositWrapperList.length; i++){
                            var slcdFee = crsObj.depositWrapperList[i];
                            if(slcdFee.isSelected)
                                res.depositWrapperList.push(slcdFee); 
                        }
                        
                        //Other Discount
                        res.disWrapperList = [];
                        for(var i = 0; i < crsObj.disWrapperList.length; i++){
                            var slcdDis = crsObj.disWrapperList[i];
                            if(slcdDis.isSelected)
                                res.disWrapperList.push(slcdDis); 
                        }
                        
                        //Checking that if course is edit or its new case    
                        var toastMsg = "Course successfully Added.";
                        var stuDetWithCrs = component.get("v.stuClsWrapper");
                        console.log('@@@ type of function-->'+crsObj.typeAddEdit);
                        if(crsObj.typeAddEdit == 'Edit'){
                            stuDetWithCrs.slctdClsDetails[crsObj.recNo] = res;
                            toastMsg = "Course successfully Updated.";
                        }else{
                            stuDetWithCrs.slctdClsDetails.push(res);
                        }
                        var slctdCrsWithStuList= component.get("v.stuClsWrapperList");
                        slctdCrsWithStuList[stuDetWithCrs.stuRecNo] = stuDetWithCrs;    
                        
                        //  alert(JSON.stringify(stuDetWithCrs));
                        console.log(JSON.stringify(slctdCrsWithStuList));
                        
                        //Amount calcuation
                        //Grand total caculation
                        var grandTot = 0;
                        //var totDepFee = 0;
                        var gstAppFeeAmount = 0;
                        for(var i = 0; i < slctdCrsWithStuList.length; i++){
                            var slcdCrsList = slctdCrsWithStuList[i].slctdClsDetails;
                            //	alert(JSON.stringify(slcdCrsList));
                            for(var j = 0; j < slcdCrsList.length; j++){
                                var slcdTstionFeeAmt  = 0;
                                
                                //tution fee addition
                                var feeList = slcdCrsList[j].tutionFeeWrapperList; 
                                for(var k = 0; k < feeList.length; k++){
                                    if(feeList[k].isSelected){
                                        if(feeList[k].feeProratedAmount > 0)
                                            slcdTstionFeeAmt += feeList[k].feeProratedAmount;
                                        else
                                            slcdTstionFeeAmt += feeList[k].feeAmount;
                                        
                                        if(feeList[k].isGSTApplicable && feeList[k].feeProratedAmount > 0)
                                            gstAppFeeAmount += feeList[k].feeProratedAmount;
                                        else if(feeList[k].isGSTApplicable)
                                            gstAppFeeAmount += feeList[k].feeAmount;
                                    }
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
                                        // totDepFee += feeList[k].feeAmount;
                                        
                                        if(feeList[k].isGSTApplicable)
                                            gstAppFeeAmount += feeList[k].feeAmount;
                                    }
                                }
                                
                                //Other course discount deduction
                                var disList = slcdCrsList[j].disWrapperList;
                                for(var k = 0; k < disList.length; k++){
                                    if(disList[k].isSelected)
                                        slcdTstionFeeAmt -= disList[k].amount;
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
                        // var tempAmt = grandTot-totDepFee; 
                        // alert(gstAppFeeAmount);
                        var tempAmt = (gstAppFeeAmount*gstPrcnt/100);                            
                        component.set("v.gstAmount", tempAmt); 
                        
                        component.set("v.enrFeeTotAmt", grandTot); 
                        component.set("v.grandTotAmt", grandTot + tempAmt); 
                        component.set("v.stuClsWrapperList", slctdCrsWithStuList);
                        component.set("v.showModal", false);
                        
                        
                        helper.alertToast(component,event,"Success",toastMsg);
                    }
                }
            });            
            
            $A.enqueueAction(action);
        }
    },
    
    saveEnrolments:function(component,event,helper){
        var allValid1 = true;
        if(!component.get("v.isCorporateAccount")){
            allValid1 = component.find('conDetReqId').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        }
        var parFirstName = document.getElementById("contactId").value;
        var noFirstCsmtIssue = true;
        var checkEmail = true;
        if($A.util.isEmpty(parFirstName)){
            document.getElementById("requiredContactErrorMsg").style.display = 'block';
            noFirstCsmtIssue = false;
        }else{
            document.getElementById("requiredContactErrorMsg").style.display = 'none';
        }
        
        if(!$A.util.isEmpty(component.get("v.contactDetail.PersonEmail"))){            
            var emailFieldValue = component.get("v.contactDetail.PersonEmail");
            var regExp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;             
            if(!emailFieldValue.match(regExp)){                
                helper.alertToast(component,event,"ERROR","Enter a valid email address.");
                checkEmail = true;
            } 
        }
        
        var allValid = true;
        if(!component.get("v.confrmMessage")){
            component.find('confrmmsg').showHelpMessageIfInvalid();
            allValid = false;
        }
        
        var checkStudent = false;
        var checkClass = false;
        if($A.util.isEmpty(component.get("v.stuClsWrapperList"))){
            checkStudent = true;
        }
        else{
            for(var i = 0; i < component.get("v.stuClsWrapperList").length; i++){
                if($A.util.isEmpty(component.get("v.stuClsWrapperList")[i].studentDetails.FirstName) || 
                   $A.util.isEmpty(component.get("v.stuClsWrapperList")[i].studentDetails.LastName) ||
                   $A.util.isEmpty(component.get("v.stuClsWrapperList")[i].studentDetails.PersonBirthdate)||
                   $A.util.isEmpty(component.get("v.stuClsWrapperList")[i].studentDetails.Gender__c)){
                    checkStudent = true;
                    break;
                }
                if($A.util.isEmpty(component.get("v.stuClsWrapperList")[i].studentDetails.Relationship_with_contact__c) &&
                   !component.get("v.isCorporateAccount")){
                    checkStudent = true;
                    alert('test')
                }
            }
        }
        
        if(!checkStudent){
            for(var i = 0; i < component.get("v.stuClsWrapperList").length; i++){
                if($A.util.isEmpty(component.get("v.stuClsWrapperList")[i].slctdClsDetails)){
                    checkClass = true;
                    break;
                }
            }
        }
        
        if(checkStudent){
            helper.alertToast(component,event,"ERROR","Enter Student Details Properly. All fields are mandatory");
        }
        if(checkClass){
            helper.alertToast(component,event,"ERROR","Add class for every Student");
        }
        
        if(allValid && !checkStudent && !checkClass && allValid1 && noFirstCsmtIssue && checkEmail){
            component.set("v.toggleSpinner", true);
            var contactDet = component.get("v.contactDetail");
            var slcdCrs	   = component.get("v.stuClsWrapperList");
            
            var parFirstName = document.getElementById("contactId").value;
            //contactDet.FirstName = parFirstName;
            
            console.log(slcdCrs.length);
            /*  var slcdClass = false;
            for(var i = 0; i < slcdCrs.length; i++){
                var slcdCrsList = slcdCrs[i].slctdClsDetails;
                if(slcdCrsList.length > 0){
                    slcdClass = true
                }else{
                   slcdClass = false;                     
                   break; 
                }    
            }
            if(slcdClass == false){
                
            }*/
            
            
            var action = component.get("c.completeEnrolment");
            action.setParams({
                "parAccStr" : JSON.stringify(contactDet),
                "slctdEnrolmentsStr" : JSON.stringify(slcdCrs),
                "globalDisListStr" : JSON.stringify(component.get("v.globalDisList")),
                "totPayAmt":component.get("v.grandTotAmt"),
                "refNo":component.get("v.paymentRefNumber"),
                "payMode":component.get("v.payModeSlcdStr")
            });
            action.setCallback(this,function(result){
                if(result.getState() == "SUCCESS"){
                    var res = result.getReturnValue();//alert(res);
                    if(!res.startsWith('Error')){
                        var navEvent = $A.get("e.force:navigateToSObject");  
                        navEvent.setParams({"recordId": res});
                        navEvent.fire(); 
                    }else{
                        helper.alertToast(component,event,'Error',res);
                    }
                }else{
                    // helper.showToast(component,event,'Error',retRes);
                    
                }
                component.set("v.toggleSpinner", false);
            });
            
            $A.enqueueAction(action);
        }
    },
    showSpinner : function(component,event,helper){
        component.set("v.toggleSpinner", true);  
    },
    hideSpinner : function(component,event,helper){
        component.set("v.toggleSpinner", false);
    },        
    
    handleChange :  function(component,event,helper){
        component.set("v.stuClsWrapperList",null);
        document.getElementById("contactId").value = null;
        component.set("v.isSameAsParent",false);
    },   
    
    sameAsParentChange : function(component,event,helper){
        var slctdCrsList= component.get("v.stuClsWrapperList");
        // alert(JSON.stringify(slctdCrsList))
        if(component.get("v.isSameAsParent") && !$A.util.isEmpty(slctdCrsList)){
            var parFirstName = document.getElementById("contactId").value;
            for(var i = 0; i < slctdCrsList.length; i++){
                slctdCrsList[i].studentDetails.FirstName = parFirstName;
                slctdCrsList[i].studentDetails.LastName  = component.get("v.contactDetail.LastName");
                slctdCrsList[i].studentDetails.Relationship_with_contact__c = 'Self'; 
            }    
        }
        else if(!component.get("v.isSameAsParent") && !$A.util.isEmpty(slctdCrsList)){
            var parFirstName = document.getElementById("contactId").value;
            for(var i = 0; i < slctdCrsList.length; i++){
                slctdCrsList[i].studentDetails.FirstName = '';
                slctdCrsList[i].studentDetails.LastName  = '';
                slctdCrsList[i].studentDetails.Relationship_with_contact__c = '';
            } 
        }
        component.set("v.stuClsWrapperList",slctdCrsList);
        
    },
    
    handleCourseDiscount : function(component,event,helper){
        component.set("v.courseDiscountModal",true);
        var selectedCheckText = event.target.id;
        var indexList = selectedCheckText.split("_");
        component.set("v.stuIndex",indexList[0]);
        component.set("v.clsIndex",indexList[1]);
        if(!$A.util.isEmpty(component.get("v.crsId"))){
            component.set("v.discountList",null);
            var disWrapperList = component.get("v.discountList");
            var action = component.get("c.fetchCourseDiscount");
            action.setParams({
                "courseId" : component.get("v.crsId")
            });
            action.setCallback(this,function(response){
                if(response.getState() === "SUCCESS"){
                    if(response.getReturnValue().length > 0){
                        disWrapperList = response.getReturnValue();
                        component.set("v.discountList",disWrapperList);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    closeCourseDiscountModal : function(component,event,helper){
        component.set("v.courseDiscountModal",false);
    },
    
    calculateCourseDiscount : function(component,event,helper){
        var stuWrap = component.get("v.stuClsWrapperList");
        var stuIndex = component.get("v.stuIndex");
        var clsIndex = component.get("v.clsIndex");
        var stuRec = stuWrap[stuIndex];
        var totalFee = stuWrap[stuIndex].slctdClsDetails[clsIndex].totWithProratedFee;
        if(!$A.util.isEmpty(component.get("v.discountList")) && !$A.util.isEmpty(totalFee)){
            var discountList = component.get("v.discountList");
            var discountListToAdd = [];
            for(var i = 0; i< discountList.length; i++){
                if(discountList[i].isSelected){
                    discountListToAdd.push(discountList[i]);
                }
            }
            console.log(JSON.stringify(discountListToAdd))
            console.log(JSON.stringify(stuWrap[stuIndex].slctdClsDetails[clsIndex].disWrapperList))
            stuWrap[stuIndex].slctdClsDetails[clsIndex].disWrapperList = discountListToAdd;
            helper.totAmountcalculation(component, event, stuWrap);
            component.set("v.courseDiscountModal",false);
        }
    }
})