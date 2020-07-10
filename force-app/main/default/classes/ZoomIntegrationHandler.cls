public class ZoomIntegrationHandler implements iVirtualClass{
    //authorization_code
    public AuthResponse getAccessToken(String code,String clientId,String secretKey,String redirectURI,String grantType){
        AuthResponse objResponse = new AuthResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://zoom.us/oauth/token');
        String messageBody = 'code='+code+'&client_id='+clientId+'&client_secret='+secretKey+'&redirect_uri='+redirectURI+'&grant_type='+grantType;
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);

        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        if(res.getStatusCode() == 200){
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            objResponse.accessToken  = (String) tokenResponse.get('access_token');
            objResponse.refreshToken = (String) tokenResponse.get('refresh_token');
             
        }
        return objResponse;
    }
    
    public AuthResponse refreshAccessToken(String accessToken,String refreshToken,String clientId,String secretKey){
        AuthResponse objResponse = new AuthResponse();
        String baseUrl = 'https://zoom.us/oauth/token?grant_type=refresh_token&refresh_token='+refreshToken;
        blob customerSecert = Blob.valueOf(clientId+':'+secretKey);
        String resp;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');           
        req.setEndpoint(baseUrl);          
        req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(customerSecert));
        
        Http htt = new Http();
        HttpResponse res = htt.send(req);
        resp = res.getBody();
        system.debug('resp->'+resp);
        Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if(tokenResponse.containsKey('access_token') && tokenResponse.containsKey('refresh_token')){
            objResponse.accessToken  = (String) tokenResponse.get('access_token');
            objResponse.refreshToken = (String) tokenResponse.get('refresh_token');
            //upsertAccessToken(locatId, accesstoken, refreshToken);          
        }           
        return objResponse;
    }
    
    public VirtualClassParser createMeeting(String body,String accessToken){
        VirtualClassParser objVirtual = new VirtualClassParser();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.zoom.us/v2/users/me/meetings');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setBody(body);
        Http htt = new Http();
        HttpResponse res = htt.send(req);
        System.debug(res);
        System.debug(res.getBody());
        if(res.getStatusCode() == 201){
            ZoomResponseParser zoomObj = ZoomResponseParser.parse(res.getBody());
            objVirtual.meetingId = zoomObj.id;
            objVirtual.hostId = zoomObj.host_id;
            objVirtual.topic = zoomObj.topic;
            objVirtual.meetingType = zoomObj.type_Z;
            objVirtual.agenda = zoomObj.agenda;
            objVirtual.meetingStartUrl = zoomObj.start_url;
            objVirtual.joinUrl = zoomObj.join_url;
            if(zoomObj.occurrences != null && zoomObj.occurrences.size() > 0){
                List<VirtualClassOccurence> occLst = new List<VirtualClassOccurence>();
                for(ZoomResponseParser.occurrences zoomOccObj : zoomObj.occurrences){
                    VirtualClassOccurence occObj = new VirtualClassOccurence();
                    occObj.occurrenceID = zoomOccObj.occurrence_id;
                    occObj.startTime = zoomOccObj.start_time;
                    occObj.duration = zoomOccObj.duration;
                    occObj.status = zoomOccObj.status;
                    occLst.add(occObj);
                }
                if(occLst.size() > 0){
                    objVirtual.occurrences = occLst;
                }
            }
            system.debug('objVirtual'+objVirtual);
        }else if(res.getStatusCode() == 401){
            
        }
        return objVirtual;
    }
 	
    public static Boolean deleteMeeting(String meetingId, String occurrenceId,String accessToken){
        Boolean isDeleted = false;
        HttpRequest req = new HttpRequest();       
        req.setMethod('DELETE'); 
        if(String.isNotBlank(occurrenceId)){
            req.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId+'?occurrence_id='+occurrenceId);
        }else{
            req.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId);
        }        
        req.setHeader('Authorization', 'Bearer '+accessToken);
        
        Http htt = new Http();
        HttpResponse res = htt.send(req);
        system.debug(res);
        system.debug(res.getBody());
        if(res.getStatusCode() == 204){
            isDeleted = true;
            //system.debug('meeting delete succesfully');
        }else if(res.getStatusCode() == 401){
        
        }
        return isDeleted;
        
    }
    public String createSingleMeetingBody(String topic,  String startDateTime, Integer duration, String agenda){
        Map<String, Object> meetingBody = new Map<String, Object>();
        meetingBody.put('topic', topic);
        //meetingBody.put('type', type);
        meetingBody.put('startDateTime', startDateTime);
        meetingBody.put('duration', duration);
        //meetingBody.put('timezone', timeZone);
        //meetingBody.put('schedule_for','vijayarpit.vijay@gmail.com');
        meetingBody.put('agenda', agenda);
        system.debug('JSON body'+ JSON.Serialize(meetingBody));
        return JSON.Serialize(meetingBody);
    }
    
    
    public String createRecurringMeetingBody(String topic, String startDateTime, Integer duration,  String agenda, String recurrenceType,  String weeklyDays, String endTimes){
        Map<String, Object> meetingBody = new Map<String, Object>();
        Map<String, Object> recurrenceBody = new Map<String, Object>();
        //DateTime newDt = DateTime.valueOf(startDateTime);

        meetingBody.put('topic', topic);
        meetingBody.put('type',8);
        meetingBody.put('startDateTime', startDateTime);
        meetingBody.put('duration', duration);
        //meetingBody.put('timezone', timeZone);
        meetingBody.put('agenda', agenda);

        recurrenceBody.put('type', 2);
        //recurrenceBody.put('repeat_interval', repeatInterval);
        if(recurrenceType == 'Weekly'){            
            recurrenceBody.put('weekly_days', weeklyDays);
        }
        recurrenceBody.put('end_date_time', endTimes);
        
        meetingBody.put('recurrence',recurrenceBody);

        system.debug('JSON body'+ JSON.Serialize(meetingBody));
        return JSON.Serialize(meetingBody);
    }
    
    public class CustomZoomWrapper{
        long meetingId;
        String meetingStartUrl;
        String joinUrl;
        String hostId;
        String topic;
        String agenda;
        Integer meetingType;        
        List<OccurrencesWrapper> occurrences;
    }
    public class OccurrencesWrapper{
        String occurrence_id;  
        String start_time;
        Integer duration;
        String status;
   }
}