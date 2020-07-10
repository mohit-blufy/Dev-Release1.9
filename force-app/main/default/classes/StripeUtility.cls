public class StripeUtility {
	public static StripeCustomer createStripeCustomer(string token,string name,string email, string description,String baseUrl,String apiKey){
        StripeCustomer sc = new StripeCustomer();
        string customerUrl = baseurl + '/v1/customers';
        
        HttpRequest http = new HttpRequest();
        http.setEndpoint(customerUrl);
        http.setMethod('POST');
        Blob headerValue = Blob.valueOf(apiKey + ':');
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        http.setHeader('Authorization', authorizationHeader);
        
        string url = '&' + EncodingUtil.urlEncode('source', 'UTF-8') + '=' + EncodingUtil.urlEncode(token, 'UTF-8') + '&';
        url += EncodingUtil.urlEncode('metadata[Name]', 'UTF-8') + '=' + EncodingUtil.urlEncode(name, 'UTF-8') + '&';
        url += EncodingUtil.urlEncode('email', 'UTF-8') + '=' + EncodingUtil.urlEncode(email, 'UTF-8') + '&';
        url += EncodingUtil.urlEncode('description', 'UTF-8') + '=' + EncodingUtil.urlEncode(description, 'UTF-8') + '&';
        
        http.setBody(url);
        
        Integer statusCode;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        
        hs = con.send(http);
        
        statusCode = hs.getStatusCode();
        
        system.debug('Response===='+hs.getBody());
        string response = hs.getBody();
        response = cleanJson(response);
        
        sc = (StripeCustomer) System.JSON.deserialize(response, StripeCustomer.class);
        sc.statusCode = statusCode;
        return sc;
    }
    
    Public static String cleanJson(String json) {
        json = json.replaceAll('"object":', '"stripeObject":');
        json = json.replaceAll('"date":', '"stripeDate":');
        json = json.replaceAll('"end":', '"endDate":');
        json = json.replaceAll('"data":', '"stripeData":');
        json = json.replaceAll('"currency":', '"stripeCurrency":');
        json = json.replaceAll('"type":', '"stripeType":');
        
        json = json.replaceAll('"customer":\\s?"cus_', '"customer_id": "cus_');
        json = json.replaceAll('"invoice":\\s?"in_', '"invoice_id": "in_');
        
        return json;
    }
    public class StripeCustomer{
        Public Integer created;
        Public Integer account_balance;
        Public String description;
        Public StripeError error;
        Public Boolean livemode;
        public String default_source;
        Public String token;
        Public String id;
        Public Map<String, String> metadata;
        
        Public CardList cards;
        Public String default_card;
        public integer statusCode;
        public cls_sources sources;
    }
    public class cls_sources {
        public cls_data[] stripeData;
        public boolean has_more;
        public Integer total_count; 
        public String url; 
    }
    public class cls_data {
        public String id;   
        public String brand;    
        public String country;  
        public String customer; 
        public String cvc_check;    
        public Integer exp_month;   
        public Integer exp_year;    
        public String fingerprint;  
        public String funding; 
        public String last4;   
    }
    
    Public class CardList {
        Public Integer count;
        Public String url;
        Public List<StripeCard> stripeData;
    }
    
    public class StripeCard{
        Public String stripeType;
        Public String country;
        Public Integer exp_month;
        Public String fingerprint;
        Public Integer exp_year;
        Public String last4;
        Public String stripeObject;
        Public String id;
        Public String name;
        public String brand;
        Public StripeError error;
        Public String customer_id;
        public Integer statusCode;
    }
    
    Public class StripeError {
        public String charge; 
        Public String stripeType;
        Public String param;
        Public String message;
        Public String code;
        public String decline_code;
    }
    /*
    public class StripeCharge{
        Public Integer amount;
        Public Integer created;
        Public String stripeCurrency;
        Public String customer_id;
        Public StripeCustomer customer;
        Public String description;
        Public Boolean disputed;
        Public Integer fee;
        Public String id;
        Public Boolean livemode;
        Public String stripeObject;
        Public Boolean paid;
        Public Boolean refunded;
        Public Integer amount_refunded;
        Public StripeCard card;
        Public StripeError error;
        Public String invoice_id;
        Public String failure_message;
        Public Map<String, String> metadata;
        public integer statusCode;
    }
    
    public class StripeRefund{
        Public String id;
        Public Integer amount;
        public String balance_transaction;
        public String charge;
        Public Integer created;
        Public String stripeCurrency;
        Public Map<String, String> metadata;
        public String status;
        Public StripeError error;
        public integer statusCode;
    }*/
}