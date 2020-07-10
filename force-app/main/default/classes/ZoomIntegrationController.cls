public with sharing class ZoomIntegrationController {
   /* 
    static String clientId = 'e_FGIWuxQ52jbBOT6L1n_w';
    static String clientSecret = 'ZHM3s03nE6kgYQNTA91w659jhGR5LL7Y';
    static String redirect_uri = 'https://blufydev-dev-ed--educato.visualforce.com/apex/ZoomAuthorizePage';
    
    String code = '';  
    public String locationId{get;set;}

    public ZoomIntegrationController(){
        code = ApexPages.currentPage().getParameters().get('code');
        locationId = ApexPages.currentPage().getParameters().get('locationId');
        //redirect_uri += '?locationId='+locationId;
        system.debug('redirect_uri'+redirect_uri);
        if(code != '' && code != null){
            locationId = ApexPages.currentPage().getParameters().get('state');
            //getAccessToken() ;
        }
    }

    public PageReference zoomAuth(){
        //Authenticating
        PageReference pg = new PageReference(zoomAuthUri()) ;
        return pg ;
    }

    public String zoomAuthUri(){

		system.debug('redirect_uri'+redirect_uri);
        String key = EncodingUtil.urlEncode(clientId,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = '';
        authuri = 'https://zoom.us/oauth/authorize?'+
        'client_id='+key+
        '&response_type=code'+
        '&scope='+
        '&redirect_uri='+uri+
        '&state='+locationId;
        system.debug('authuri'+authuri);
        return authuri;
    }

    public void getAccessToken(){
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://zoom.us/oauth/token');
        system.debug('code'+code);
        String messageBody = 'code='+code+'&client_id='+clientId+'&client_secret='+clientSecret+'&redirect_uri='+redirect_uri+'&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);

        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        system.debug('res'+res.getBody());
        resp = res.getBody();
        if(res.getStatusCode() == 200){
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            system.debug('tokenResponse'+tokenResponse);
            String accesstoken = (String) tokenResponse.get('access_token');
            String refreshToken = (String) tokenResponse.get('refresh_token');
            System.debug(' You can parse the response to get the access token ::: ' + resp);
            system.debug('accesstoken'+accesstoken);   
            upsertAccessToken(locationId, accesstoken, refreshToken);   
        }          
        
    }

    public static  void getRefreshToken(String locatId){
        List<Account> accLst = [SELECT Id, Access_Token__c, Refresh_Token__c FROM Account WHERE Id =: locatId LIMIT 1];
        if(accLst.size() > 0){
            String refreshTokn = accLst[0].Refresh_Token__c;
            String baseUrl = 'https://zoom.us/oauth/token?grant_type=refresh_token&refresh_token='+refreshTokn;
            blob customerSecert = Blob.valueOf(clientId+':'+clientSecret);
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
                String accesstoken = (String) tokenResponse.get('access_token');
                String refreshToken = (String) tokenResponse.get('refresh_token');   
                upsertAccessToken(locatId, accesstoken, refreshToken);          
            }           
        }
    }

    public static void createMeeting(String jsonString, String locationId){
        List<Account> accLst = [SELECT Id, Access_Token__c, Refresh_Token__c  FROM Account WHERE id =:locationId LIMIT 1];
        if(accLst.size() > 0 && accLst[0].Access_Token__c != null){
            CustomZoomWrapper custObj = new CustomZoomWrapper();
            String accessTok = accLst[0].Access_Token__c;
            String userId = 'arpit.vijay@blufy.com';
            system.debug('accessTokn'+accessTok);
            system.debug('jsonString'+jsonString);
            if(String.isNotBlank(jsonString)){
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint('https://api.zoom.us/v2/users/'+userId+'/meetings');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Bearer '+accessTok);
                req.setBody(jsonString);
                Http htt = new Http();
                HttpResponse res = htt.send(req);
                system.debug('res'+res);
                system.debug('res'+res.getBody());
                if(res.getStatusCode() == 201){
                    ZoomResponseParser zoomObj = ZoomResponseParser.parse(res.getBody());
                    custObj.meetingId = zoomObj.id;
                    custObj.hostId = zoomObj.host_id;
                    custObj.topic = zoomObj.topic;
                    custObj.meetingType = zoomObj.type_Z;
                    custObj.agenda = zoomObj.agenda;
                    custObj.meetingStartUrl = zoomObj.start_url;
                    custObj.joinUrl = zoomObj.join_url;
                    if(zoomObj.occurrences != null && zoomObj.occurrences.size() > 0){
                        List<OccurrencesWrapper> occLst = new List<OccurrencesWrapper>();
                        for(ZoomResponseParser.occurrences zoomOccObj : zoomObj.occurrences){
                            OccurrencesWrapper occObj = new OccurrencesWrapper();
                            occObj.occurrence_id = zoomOccObj.occurrence_id;
                            occObj.start_time = zoomOccObj.start_time;
                            occObj.duration = zoomOccObj.duration;
                            occObj.status = zoomOccObj.status;
                            occLst.add(occObj);
                        }
                        if(occLst.size() > 0){
                            custObj.occurrences = occLst;
                        }
                    }
                    system.debug('custObj'+custObj);
                }else if(res.getStatusCode() == 401){
                    Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());            
                    String msg = (String) tokenResponse.get('message');
                    system.debug('msg'+msg);
                    if(msg == 'Access token is expired.'){
                        getRefreshToken(locationId);
                        createMeeting(jsonString, locationId);
                    }            
                }            
            }   
        }         
    }
    
    public static void updateMeeting(String jsonString, String locationId, String meetingId){
        List<Account> accLst = [SELECT Id, Access_Token__c, Refresh_Token__c  FROM Account WHERE id =:locationId LIMIT 1];
        if(accLst.size() > 0 && accLst[0].Access_Token__c != null){
            String accessTokn = accLst[0].Access_Token__c;
            HttpRequest req = new HttpRequest();                
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+accessTokn);
            req.setMethod('POST');
            req.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId); //+ '?_HttpMethod=PATCH');
           
             req.setHeader('X-HTTP-Method-Override','PATCH');
            req.setBody(jsonString);

            Http htt = new Http();
            HttpResponse res = htt.send(req);
            system.debug(res);
            system.debug(res.getBody());
            if(res.getStatusCode() == 204){
                system.debug('meeting updated succesfully');
            }
        }
    }

    public static void updateMeetingStatus(String locationId, String meetingId){
        List<Account> accLst = [SELECT Id, Access_Token__c, Refresh_Token__c  FROM Account WHERE id =:locationId LIMIT 1];
        if(accLst.size() > 0 && accLst[0].Access_Token__c != null){
            String accessTokn = accLst[0].Access_Token__c;
            HttpRequest req = new HttpRequest();       
            req.setMethod('PUT');         
            req.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId+'/status');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+accessTokn);
            req.setBody('{"action":"end"}');
            
            Http htt = new Http();
            HttpResponse res = htt.send(req);
            system.debug(res);
            system.debug(res.getBody());
            if(res.getStatusCode() == 204){
                system.debug('meeting updated succesfully');
            }
        }
    }

    public static void deleteMeeting(String locatId, String meetingId, String occurrenceId){
        List<Account> accLst = [SELECT Id, Access_Token__c, Refresh_Token__c  FROM Account WHERE id =:locatId LIMIT 1];
        if(accLst.size() > 0 && accLst[0].Access_Token__c != null){
            String accessTokn = accLst[0].Access_Token__c;
            HttpRequest req = new HttpRequest();       
            req.setMethod('DELETE'); 
            if(String.isNotBlank(occurrenceId)){
                req.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId+'?occurrence_id='+occurrenceId);
            }else{
                req.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId);
            }        
            req.setHeader('Authorization', 'Bearer '+accessTokn);

            Http htt = new Http();
            HttpResponse res = htt.send(req);
            system.debug(res);
            system.debug(res.getBody());
            if(res.getStatusCode() == 204){
                system.debug('meeting delete succesfully');
            }else if(res.getStatusCode() == 401){
                Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());            
                String msg = (String) tokenResponse.get('message');
                if(msg == 'Access token is expired.'){
                    getRefreshToken(locatId);
                    deleteMeeting(locatId, meetingId, occurrenceId);
                }            
            }
        }
    }

    public static void createMeetingBodyForSingleDay(String topic, Integer type, String startDateTime, Integer duration, String timeZone, String agenda, String locatId ){
        system.debug('startDateTime'+startDateTime);
        //DateTime newDt = DateTime.valueOf(startDateTime);
        Map<String, Object> meetingBody = new Map<String, Object>();
        meetingBody.put('topic', topic);
        meetingBody.put('type', type);
        meetingBody.put('startDateTime', startDateTime);
        meetingBody.put('duration', duration);
        meetingBody.put('timezone', timeZone);
        meetingBody.put('agenda', agenda);
        system.debug('JSON body'+ JSON.Serialize(meetingBody));
        createMeeting(JSON.Serialize(meetingBody), locatId);
    }

    public static void createMeetingBodyForWeeklyDays(String topic, Integer type, String startDateTime, Integer duration, String timeZone, String agenda, Integer recurrenceType, Integer repeatInterval, String weeklyDays, Integer endTimes, String locatId){
        Map<String, Object> meetingBody = new Map<String, Object>();
        Map<String, Object> recurrenceBody = new Map<String, Object>();
        //DateTime newDt = DateTime.valueOf(startDateTime);

        meetingBody.put('topic', topic);
        meetingBody.put('type', type);
        meetingBody.put('startDateTime', startDateTime);
        meetingBody.put('duration', duration);
        meetingBody.put('timezone', timeZone);
        meetingBody.put('agenda', agenda);

        recurrenceBody.put('type', recurrenceType);
        recurrenceBody.put('repeat_interval', repeatInterval);
        if(recurrenceType == 2){            
            recurrenceBody.put('weekly_days', weeklyDays);
        }
        recurrenceBody.put('end_times', endTimes);
        
        meetingBody.put('recurrence',recurrenceBody);

        system.debug('JSON body'+ JSON.Serialize(meetingBody));

        createMeeting(JSON.Serialize(meetingBody), locatId);
    }

    public static  void upsertAccessToken(String locatId , String accesstoken, String refreshToken){
        if(String.isNotBlank(locatId)){
            List<Account> accList = [SELECT Id, Access_Token__c, Refresh_Token__c FROM Account WHERE Id =: locatId];
            if(accList.size() > 0){
                accList[0].Refresh_Token__c = refreshToken;
                accList[0].Access_Token__c = accesstoken;               
                upsert accList;                     
            }
        }
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
    }*/
}