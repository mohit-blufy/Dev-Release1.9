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
        let dayNumber = rowArr[size - 1].DayNumber;
        let date = new Date(rowArr[size - 1].StartDt);
        console.log(date);
        date = new Date(date.setDate(date.getDate() + 1));
        console.log(date);
        let days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        if (dayNumber == 6) {
            dayNumber = 0;
        } else {
            dayNumber++;
        }
        console.log(dayNumber);
        console.log(days);
        rowArr.push({
            'index': size,
            'Day': days[dayNumber],
            'DayNumber': dayNumber,
            'StartDt': helper.createDateFormat(date) + 'T' + helper.createTimeFormat(date),
            'Duration': 0,
            'TeacherId': '',
            'RoomId': '',
        });
        component.set("v.rows", rowArr);
    },
    deleteRow: function (component, event, helper) {
        helper.removeRowData(component, event);
    },
    handleDateEvent : function(component, event, helper){
        console.log(event.getParams());
        let values = event.getParams();
        let rowArr = component.get("v.rows");
        let days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        console.log(rowArr[values.index]);
        if(rowArr[values.index]){
            let row = rowArr[values.index];
            let date = new Date(values.selectedDate);
            row.StartDt = helper.createDateFormat(date) + 'T' + helper.createTimeFormat(date);
            row.DayNumber = date.getDay();
            row.Day = days[date.getDay()];
            rowArr[values.index] = row;
            component.set("v.rows", rowArr);
        }
    },
    handleModalEvent : function(component, event, helper){       
        component.set("v.objectName",event.getParams().objectName);
        component.set("v.isModalOpen",true);
    }
})
