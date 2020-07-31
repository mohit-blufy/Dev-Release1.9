({
    fillData: function (component, event) {
        let rowsArr = component.get("v.rows");
        let days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        let todayDate = new Date();
        let noOfDay = todayDate.getDay();
        for (let index = 0; index <= 4; index++) {
            rowsArr.push({
                'index': index,
                'Day': days[noOfDay],
                'DayNumber': noOfDay,
                'StartDt': this.createDateFormat(todayDate) + 'T' + this.createTimeFormat(todayDate),
                'Duration': 0,
                'TeacherId': '',
                'RoomId': '',
            });
            noOfDay++;
            todayDate = new Date(todayDate.setDate(todayDate.getDate() + 1));
            if (noOfDay == 7) {
                noOfDay = 0;
            }

        }
        console.log('rowsArr', rowsArr);
        component.set("v.rows", rowsArr);
    },
    removeRowData: function (component, event) {
        //remove a row in a table                  
        let index = event.target.id;
        console.log(index);
        let rowsArr = component.get("v.rows");
        if (rowsArr[index] != undefined) {
            rowsArr.splice(index, 1);
            component.set("v.rows", rowsArr);
        }
    },
    createTimeFormat: function (currentDate) {
        let hour = currentDate.getHours();
        let minute = currentDate.getMinutes();
        let second = currentDate.getSeconds();
        hour = (hour < 10) ? "0" + hour : hour;
        minute = (minute < 10) ? "0" + minute : minute;
        second = (second < 10) ? "0" + second : second;
        return [hour, minute, second].join(':');
    },
    createDateFormat: function (currentDate) {
        let month = '' + (currentDate.getMonth() + 1);
        let day = '' + currentDate.getDate();
        let year = currentDate.getFullYear();

        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;

        return [year, month, day].join('-');
    }
})
