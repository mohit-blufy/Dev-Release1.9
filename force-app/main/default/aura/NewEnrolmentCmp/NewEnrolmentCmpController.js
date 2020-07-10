({
    doInit : function(component,event,helper){
        var action = component.get("c.fetchCourses");
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            component.set("v.crsList",res);
        });
        
        $A.enqueueAction(action);
        
        helper.fetchCntry(component, 'Account', 'BillingCountryCode');
        helper.fetchGender(component, 'Account', 'Gender__c');
        helper.fetchRelationsShip(component, 'Account', 'Relationship_with_contact__c');
        helper.initilizeCstmrList(component, event, 'Relationship_with_contact__c');
    },  
    collapse: function(cmp, event) {
        console.log('called222');
        /*var cmpTarget = cmp.find('customsec');       
        var cmpTarget = event.getSource().get("v.name");*/
        var cmpTarget = event.getSource().get("v.name");
        var currentButton = event.getSource(); 
    
        var newCmpTarget = cmpTarget+'New';
        console.log(newCmpTarget);
         var x = document.getElementById(newCmpTarget);
          if (x.style.display == "none") {
            x.style.display = "";
              currentButton.set("v.iconName", "utility:chevronup");
            
          } else {
            x.style.display = "none";
              currentButton.set("v.iconName", "utility:chevrondown");
          }
    },
    addStudent2: function(component,event,helper){
        var tb = document.getElementById("stutable");
        var rw = tb.insertRow(1);
        var cl = rw.insertCell(0);
		var k = tb.rows.length;	
        cl.innerHTML = k;
        cl = rw.insertCell(1);
        var txtbx = document.createElement("input");
        txtbx.setAttribute("type", "textbox");
        txtbx.setAttribute("id", "stu_txtbx_lname_" + k);
        cl.appendChild(txtbx); 
        cl = rw.insertCell(2);
        txtbx = document.createElement("input");
        txtbx.setAttribute("type", "textbox");
        txtbx.setAttribute("id", "stu_txtbx_lname_" + k);
        cl.appendChild(txtbx);
        cl = rw.insertCell(3);
        cl = rw.insertCell(4);
        cl = rw.insertCell(5);
        cl = rw.insertCell(6);
        cl = rw.insertCell(7);
        cl = rw.insertCell(8);

    },
    addStudent : function(component, event) {
         //helper.onSelectChange(component, event);
         //helper.onSelectChange(component, event);
        var allValid = component.find('conDetReqId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
        console.log('-----------'+allValid);
        
        if(allValid){
            var slctdCrsList= component.get("{!v.stuClsWrapperList}");       
            if(slctdCrsList == null)
                slctdCrsList = [];
          
            var action = component.get("c.blankInitializeCstmrWrpr");
            action.setCallback(this,function(result){
                var res = result.getReturnValue();
                slctdCrsList.push(res);
                component.set("v.stuClsWrapperList",slctdCrsList);
            });
            $A.enqueueAction(action);
        }else{
           // helper.showToast(component, event, "error", "Please fill all required contact detail.");
            var type = "error";
            var msg = "Please fill all required contact detail.";
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": type+"!",
                "type" : type,
                "message": msg
            });
            toastEvent.fire();
        }
    },
    deleteStudent : function(component, event) {
        var slctdCrsList= component.get("{!v.stuClsWrapperList}");
      	var indx = parseInt(event.target.id);
      	slctdCrsList.splice(indx,1);
        component.set("v.stuClsWrapperList",slctdCrsList);        
        
      //  helper.showToast(component, event, "success", "Student successfully removed.");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : "Success",
            "message":"Student successfully removed."
        });
        toastEvent.fire();
    },
    selectClass : function(component, event) {
    	var selectedCheckText = event.getSource().get("v.text");
        var getAllId = component.find("clsSlcd");
        for (var i = 0; i < getAllId.length; i++) {
            var checkBoxObj = component.find("clsSlcd")[i];
            if(selectedCheckText != checkBoxObj.get("v.text")){
                checkBoxObj.set("v.value", false);
            }
        }
        
        var indx = parseInt(selectedCheckText);
        var crsObj = component.get("{!v.slcdCrsObject}");
        var slcdCls = crsObj.classWrapperList[indx];
        crsObj.slcdClsWrapObj = slcdCls;
        
        
        var action = component.get("c.checkEarlyBirdDiscount");
        action.setParams({
            "clsWrap" : slcdCls
        });
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            crsObj.disWrapperList = res;
            component.set("v.slcdCrsObject", crsObj);
        });
        component.set("v.slcdCrsObject", crsObj);
        $A.enqueueAction(action);
	},
    tutionFeeOnCheck : function(component, event) {
        //alert('on check');  
    	//var selectedHeaderCheck = event.getSource().get("v.value");
		//alert(component.find("clsSlcd"));        
       // var getAllId = component.find("tutionFeeChk");
         /*var checkCmp = component.find("clsSlcd");
        alert(component.find("clsSlcd")[0].get("v.value"));
        component.find("clsSlcd")[0].set("v.value", true);*/
        
        var selectedCheckText = event.getSource().get("v.text");
        var getAllId = component.find("tutionFeeChk");
        for (var i = 0; i < getAllId.length; i++) {
            var checkBoxObj = component.find("tutionFeeChk")[i];
            if(selectedCheckText != checkBoxObj.get("v.text")){
                checkBoxObj.set("v.value", false);
            }
        }
        
        //Calcuting total fee amount for the class, When tution fee selected
        //Tution fee addition 
        var indx = parseInt(selectedCheckText);
        var crsObj = component.get("{!v.slcdCrsObject}");
        var slcdTstionFeeAmt  = crsObj.tutionFeeWrapperList[indx].feeAmount;
         
        //alert(JSON.stringify(crsObj))
      //  alert(JSON.stringify(crsObj.tutionFeeWrapperList[indx]))
       //Other fee addition 
        var feeList = crsObj.feeWrapperList; 
        for(var i = 0; i < feeList.length; i++)
            slcdTstionFeeAmt += feeList[i].feeAmount;
        
        //Deposit fee addition 
        feeList = crsObj.depositWrapperList;
        for(var i = 0; i < feeList.length; i++)
            slcdTstionFeeAmt += feeList[i].feeAmount;
        
        crsObj.totFee = slcdTstionFeeAmt;
        component.set("v.slcdCrsObject", crsObj);
    },
    discountOnCheck : function(component, event) {
        var selectedCheckText = event.getSource().get("v.text");
        var indx = parseInt(selectedCheckText);
        
        var crsObj = component.get("{!v.slcdCrsObject}");
        var slcdDisFeeAmt  = crsObj.disWrapperList[indx].amount;
       
        if(event.getSource().get("v.value"))
        	crsObj.totFee = crsObj.totFee - slcdDisFeeAmt;
		else
            crsObj.totFee = crsObj.totFee + slcdDisFeeAmt;
        
        component.set("v.slcdCrsObject", crsObj);
    },
    mydiscount:function(component, event) {
        component.set("v.discountModal", true);
    },
    mymodal : function(component, event) {
      /*  console.log('called');
        var action = component.get("c.blankInitializeCstmrWrpr");
        action.setCallback(this,function(result){
            var res = result.getReturnValue();
            component.set("v.stuClsWrapper",res);
        });
        
        $A.enqueueAction(action);*/
        
        var allValid = component.find('StuDetReqId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
        if(allValid){
            var indx = parseInt(event.target.id);
            var slctdCrsList= component.get("{!v.stuClsWrapperList}");
            var slctdStuWrap =slctdCrsList[indx];
            slctdStuWrap.stuRecNo = indx;
            component.set("v.stuClsWrapper",slctdStuWrap);        
            
            
            //var clsList =[];  
           // component.set("v.clsList",clsList);
            var crsVar = {};
            component.set("v.slcdCrsObject",crsVar);
            component.set("v.showModal", true);
        }else{
            var type = "error";
            var msg = "Please fill all required student detail.";
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": type+"!",
                "type" : type,
                "message": msg
            });
            toastEvent.fire();
        }
    },
    
    closemodal : function(component, event) {
        console.log('called2');
        component.set("v.showModal", false);
        component.set("v.discountModal", false);
    },
    selectCrs : function(component,event,helper){
        helper.showSpinner(component);
        var crsId = event.getSource().get("v.value");
      
       // var action = component.get("c.fetchClassDetails");
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
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    deleteCls : function(component, event) {
        var selectedCheckText = event.target.id;
        var indexList = selectedCheckText.split("_");
        var slctdCrsList= component.get("{!v.stuClsWrapperList}");
        var slctCrs		= slctdCrsList[indexList[0]];
        
        var grandTot = component.get("{!v.grandTotAmt}");
        var crsAmt = slctCrs.slctdClsDetails[indexList[1]].totFee;
        grandTot	= grandTot-crsAmt;
        component.set("v.grandTotAmt", grandTot); 
        
        slctCrs.slctdClsDetails.splice(indexList[1],1);
        slctdCrsList[indexList[0]] = slctCrs;
        component.set("v.stuClsWrapperList",slctdCrsList);   
        
        
    },
    filterByCheckbox : function(component,event,helper){
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
    },
    handleMyApplicationEvent : function(component, event, helper) {
        component.set("v.modelSpinner", true); 
        var valueId = event.getParam("selectedOption");  
        var value = event.getParam("inputValue");
        
        //alert(valueId);
        //alert(valueId);
        //alert(value);
      //  var action = component.get("c.fetchClassDetails");
        var action = component.get("c.fetchCrsClsDetails");
        action.setParams({
            "crId" : valueId
        });
        action.setCallback(this,function(result){
            //alert(result.getState());
            if(result.getState() == "SUCCESS"){
                var res = result.getReturnValue();
                //alert(res);
                if(res){
                    //component.set("v.clsList",res);
                    component.set("v.slcdCrsObject",res);
                }
            }
        });
        component.set("v.modelSpinner", false); 
        $A.enqueueAction(action);
    },
    sameAsContact:function(component,event,helper){
        var contactDetail = component.get("{!v.contactDetail}");  
        component.set("v.stuClsWrapper.studentDetail.FirstName",contactDetail.FirstName);
        component.set("v.stuClsWrapper.studentDetail.LastName",contactDetail.LastName);
    },
    addCourses:function(component,event,helper){
        var clsList 	= component.get("{!v.clsList}");  
        var slctdCrsList= component.get("{!v.stuClsWrapperList}"); 
        //  var slcdClsName = component.get("{!v.slcdClsName}");  
        //if(!slcdClsName)
        //	slcdClsName = '';
        if(slctdCrsList == null)
            slctdCrsList = [];
        //alert(clsList.length);
        
        //  var crsList = [];
        var stuDetWithCrs = component.get("{!v.stuClsWrapper}");
        
        //  if(stuDetWithCrs == null)
        // stuDetWithCrs = {};
        //alert(stuDetWithCrs);
        // if(stuDetWithCrs.slctdClsDetails == null)
        //  stuDetWithCrs.slctdClsDetails = [];
        
        for(var i = 0; i < clsList.length; i++){
            var slcdCrs = clsList[i];
            if(slcdCrs.isSelected){
                // alert(slcdCrs.isSelected);
                // if(slcdClsName.legnth > 0)
                //   slcdClsName = slcdClsName + ';';
                
                // slcdClsName += slcdCrs.clsName;
                stuDetWithCrs.slctdClsDetails.push(slcdCrs);
            } 
        }
        //alert(stuDetWithCrs.slctdClsDetails.length);
        //component.set("v.slcdClsName",slcdClsName);
        component.set("v.stuClsWrapper",stuDetWithCrs);
    },
    saveStudentCrs:function(component,event,helper){
        /*  Running code
        var clsList 	= component.get("{!v.clsList}");  
        var slctdCrsList= component.get("{!v.stuClsWrapperList}"); 
        if(slctdCrsList == null)
            slctdCrsList = [];
        
        var stuDetWithCrs = component.get("{!v.stuClsWrapper}");
        var indx = parseInt(event.target.id);
        var slcdCrs = clsList[indx];
        stuDetWithCrs.slctdClsDetails.push(slcdCrs);
        */
        //alert(stuDetWithCrs.stuRecNo);
       /* for(var i = 0; i < clsList.length; i++){
            var slcdCrs = clsList[i];
            //if(slcdCrs.isSelected){
                stuDetWithCrs.slctdClsDetails.push(slcdCrs);
           // } 
        }*/
        
       /* var slctdCrsWithStuList = component.get("{!v.stuClsWrapperList}");
        if(slctdCrsWithStuList == null)
            slctdCrsWithStuList = [];
        slctdCrsWithStuList.push(component.get("{!v.stuClsWrapper}"));
        
        var counter = 0;
        for(var i = 0; i < slctdCrsWithStuList.length; i++){
            for(var j = 0; j < slctdCrsWithStuList[i].slctdClsDetails.length; j++){
                counter = counter +1;
                slctdCrsWithStuList[i].slctdClsDetails[j].recNo = counter;
            }
        }*/
        
        /*  Running code
        var slctdCrsWithStuList = component.get("{!v.stuClsWrapperList}");
        slctdCrsWithStuList[stuDetWithCrs.stuRecNo] = stuDetWithCrs;
        
        var counter = 0;
        for(var i = 0; i < slctdCrsWithStuList.length; i++){
            for(var j = 0; j < slctdCrsWithStuList[i].slctdClsDetails.length; j++){
                counter = counter +1;
                slctdCrsWithStuList[i].slctdClsDetails[j].recNo = counter;
            }
        }
         console.log('3------->'+JSON.stringify(slctdCrsWithStuList));
        component.set("v.stuClsWrapperList", slctdCrsWithStuList); */
		var isError = true;
        var errMsg  = "";
        var getAllId = component.find("clsSlcd");alert
        for (var i = 0; i < getAllId.length; i++) {
            var checkBoxObj = component.find("clsSlcd")[i];
            if(checkBoxObj.get("v.value")){
                isError = false;
            }
        }    
        if(isError){
        	errMsg ="Please select a class.";
        }else{
            isError = true;
            getAllId = component.find("tutionFeeChk");
            for (var j = 0; j < getAllId.length; j++) {
                var checkBoxObj = component.find("tutionFeeChk")[j];
                if(checkBoxObj.get("v.value")){
                    isError = false;
                }
            }
            //if(getAllId.length == 0)
             //   isError = false;
            
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
        
        
        if(isError){
            //lper.showToast(component,event,'Error','Please select a class');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "Error",
                "message":errMsg
            });
            toastEvent.fire();
        }else{
            var crsObj = component.get("{!v.slcdCrsObject}"); //alert(JSON.stringify(crsObj));
            crsObj.classWrapperList = [];// alert(JSON.stringify(crsObj.slcdClsWrapObj));
            
            //Add selected tution fee
            var slcdTutionFee;
            for(var i = 0; i < crsObj.tutionFeeWrapperList.length; i++){
                var slcdTFees= crsObj.tutionFeeWrapperList[i];
                if(slcdTFees.isSelected){
                    slcdTutionFee = slcdTFees;
                } 
            }
            crsObj.tutionFeeWrapperList = [];
            if(slcdTutionFee)
                crsObj.tutionFeeWrapperList.push(slcdTutionFee);
            
            //Add selected Discount
            var slcdDis;
            for(var i = 0; i < crsObj.disWrapperList.length; i++){
                var slcdDiscount= crsObj.disWrapperList[i];
                if(slcdDiscount.isSelected){
                    slcdDis = slcdDiscount;
                } 
            }
            crsObj.disWrapperList = [];
            if(slcdDis)
                crsObj.disWrapperList.push(slcdDis);
            
            var slctdCrsWithStuList= component.get("{!v.stuClsWrapperList}"); //alert(JSON.stringify(slctdCrsWithStuList));
            var stuDetWithCrs = component.get("{!v.stuClsWrapper}");//alert(JSON.stringify(stuDetWithCrs));
            stuDetWithCrs.slctdClsDetails.push(crsObj);//alert(stuDetWithCrs.stuRecNo);
            slctdCrsWithStuList[stuDetWithCrs.stuRecNo] = stuDetWithCrs;
            
            
            //Grand total caculation
            var grandTot = 0;
            for(var i = 0; i < slctdCrsWithStuList.length; i++){
                var slcdCrsList = slctdCrsWithStuList[i].slctdClsDetails;
                for(var j = 0; j < slcdCrsList.length; j++){
                    grandTot += slcdCrsList[j].totFee;
                }
            }
            component.set("v.grandTotAmt", grandTot); 
            
            //console.log(JSON.stringify(slctdCrsWithStuList));
            component.set("v.stuClsWrapperList", slctdCrsWithStuList);
            component.set("v.showModal", false);
            
            //helper.alertToast(component,event,"Success","Course successfully Added.");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type" : "Success",
                "message":"Course successfully Added."
            });
            toastEvent.fire();
        }
    },
    saveEnrolments:function(component,event,helper){
   		var contactDet = component.get("{!v.contactDetail}");
        var slcdCrs	   = component.get("{!v.stuClsWrapperList}");
      //  alert(JSON.stringify(contactDet));
        
        var action = component.get("c.completeEnrolment");
        action.setParams({
            "parAcc" : contactDet,
            "slctdEnrolments" : slcdCrs
        });
        action.setCallback(this,function(result){
            //ert(result.getReturnValue());
            if(result.getState() == "SUCCESS"){
                var res = result.getReturnValue();
                if(!res.startsWith('Error')){
                    var navEvent = $A.get("e.force:navigateToSObject");  
                    navEvent.setParams({"recordId": res});
                    navEvent.fire(); 
                }else{
                    helper.showToast(component,event,'Error',res);
                }
            }else{
                // helper.showToast(component,event,'Error',retRes);
                
            }
        });
        
        $A.enqueueAction(action);
    },
    showSpinner : function(component,event,helper){
        component.set("v.toggleSpinner", true);  
    },
    hideSpinner : function(component,event,helper){
        component.set("v.toggleSpinner", false);
    },
    
})