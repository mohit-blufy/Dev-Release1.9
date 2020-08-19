/**
Name        :   RoomService
Date        :   21-JULY-2020
Description :   
*/
public class RoomService {
     /**
    Name        :  getRooms
    Date        :  21-JULY-2020
    Description :  
    Dev         :  
    */	
    public static list<Sobject> getRooms(String selectedLocation, String selectedRoomType){
        String query = 'SELECT Id,Name FROM Room__c WHERE ';
        if(String.isNotBlank(selectedRoomType) && selectedRoomType != 'All_Room_Types'){
         	   query += ' Type__c IN('+ selectedRoomType+') AND ';
        }
        query += ' Location__c =: selectedLocation WITH SECURITY_ENFORCED';
        System.debug('query'+query);
        return Database.query(query);
    }
}