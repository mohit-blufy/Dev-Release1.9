({
    fillData : function(component, event) {
        let rowsArr = component.get("v.rows");
        let days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        let todayDate = new Date(); 
        let noOfDay = todayDate.getDay();
        for(let index = 0; index <=4; index++){           
            rowsArr.push({
                'index':index,
                'Day':days[noOfDay],
                'DayNumber':noOfDay,
                'StartDt':'',
                'Duration' : 0,
                'TeacherId':'',
                'RoomId':'',
            });
            noOfDay++;
            if(noOfDay == 7){
                noOfDay = 0;
            }
           
        }
        console.log('rowsArr',rowsArr);
        component.set("v.rows",rowsArr);
    }
})
