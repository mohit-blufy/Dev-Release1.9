/*
	Name		:	VirtualClassAuthController
	Date		:	05/01/2020
	Author		:	Arpit vijayvergiya
	Description :	This controller is being used to authorize a location for creating virtual class.
*/
public class VirtualClassAuthController {
   /* public String locationId{get;set;}
    private String code;
    public Virtual_Class_Config__mdt config{get;set;}
    public String authURI = 'https://blufydev-dev-ed--educato.visualforce.com/apex/VirtualClassAuth';
    //String authURI = 'https://blufydev-dev-ed--educato.visualforce.com/apex/ZoomAuthorizePage';
    public VirtualClassAuthController(ApexPages.StandardController controller){
        List<Virtual_Class_Config__mdt> configs = [SELECT Id, Virtual_Platform__c, Client_Id__c, Client_Secret__c FROM Virtual_Class_Config__mdt LIMIT 1];
        config = configs[0];
        locationId = controller.getId();
        code = ApexPages.currentPage().getParameters().get('code');
        if(String.isBlank(locationId)){
            locationId = ApexPages.currentPage().getParameters().get('state');
        }
    }
    
    public PageReference initAuth(){
       // System.debug('locationId '+locationId);
        PageReference pg = new PageReference(VirtualClassFactory.getAuthURI(config,authURI,locationId)) ;
        return pg ;
    }
    public void getAccessToken(){
            ZoomIntegrationHandler zoom = new ZoomIntegrationHandler();
            AuthResponse res = zoom.getAccessToken(code, config.Client_Id__c, config.Client_Secret__c, authURI, 'authorization_code');
            Account objAcc = new Account(Id = locationId);
            objAcc.put('Access_Token__c',res.accessToken);
            objAcc.put('Refresh_Token__c',res.refreshToken);
            update objAcc;
        
    }*/
}