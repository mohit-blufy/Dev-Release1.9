public class VirtualClassFactory {

    public static String getAuthURI(Virtual_Class_Config__mdt config,String redirectUI,String locationId){
        String authuri = '';
        if(config.Virtual_Platform__c == 'Zoom'){
            String key = EncodingUtil.urlEncode(config.Client_Id__c,'UTF-8');
            String uri = EncodingUtil.urlEncode(redirectUI,'UTF-8');
            authuri = 'https://zoom.us/oauth/authorize?'+
            'client_id='+key+
            '&response_type=code'+
            '&scope='+
            '&redirect_uri='+uri+
            '&state='+locationId;
            system.debug('authuri'+authuri);
        }
        return authuri;
    }
}