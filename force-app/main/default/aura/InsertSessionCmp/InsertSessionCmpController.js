({
    doInit: function (component, event, helper) {
        //component.set("v.showSpinner",true);
        component.set("v.showComponent", true);
        helper.fillData(component, event);
    },
    addRows: function (component, event, helper) {
        console.log('calling');
        let rowArr = component.get("v.rows");
        console.log(rowArr);
        let size = rowArr.length;
        console.log(size);
        let dayNumber = rowArr[size-1].DayNumber;
       
        let days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        if(dayNumber == 6){
            dayNumber = 0;
        }else{
            dayNumber++;
        }
        console.log(dayNumber);
        console.log(days);
        rowArr.push({
            'index': size,
            'Day': days[dayNumber],
            'DayNumber':dayNumber,
            'StartDt': '',
            'Duration': 0,
            'TeacherId': '',
            'RoomId': '',
        });
        component.set("v.rows",rowArr);
    }
})
