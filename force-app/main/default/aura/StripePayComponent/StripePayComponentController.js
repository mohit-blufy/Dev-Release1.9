({
    stripeSetup : function(component, event, helper) {
        var stripe = Stripe('pk_test_youcdsla1iXWQuud4jxOwwYp00VvMEZkFE');
                                    
        var elements = stripe.elements();
        var style = {
            base: {
                color: '#32325d',
                fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
                fontSmoothing: 'antialiased',
                fontSize: '16px',
                '::placeholder': {
                    color: '#aab7c4'
                }
            },
            invalid: {
                color: '#fa755a',
                iconColor: '#fa755a'
            }
        };
        var card = elements.create('card', {style: style,hidePostalCode:true});
        card.mount('#card-element');
        card.addEventListener('change', function(event) {
            var displayError = document.getElementById('card-errors');
            if (event.error) {
                console.log(event.error);
                displayError.textContent = event.error.message;
            } else {
                displayError.textContent = '';
            }
        });
        
        // Handle form submission.
        var form = document.getElementById('payment-form');
        form.addEventListener('submit', function(event) {
            event.preventDefault();
            console.log('aa');
            stripe.createToken(card).then(function(result) {
                if (result.error) {
                    var errorElement = document.getElementById('card-errors');
                    errorElement.textContent = result.error.message;
                } else {
                    alert(result.token);
                }
            });
            
        });
    },
    
    makePayment : function(component,event,helper) {
        var stripe = component.get("v.stripe");
        var cardNumber = component.get("v.cardNumber"); //console.log(JSON.stringify(cardNumber));
        stripe.createToken(cardNumber).then(function(result) {
                if (result.error) {
                    var errorElement = document.getElementById('card-errors');
                    errorElement.textContent = result.error.message;
                }else{
                    alert(JSON.stringify(result.token));
                }
            });
    }
})