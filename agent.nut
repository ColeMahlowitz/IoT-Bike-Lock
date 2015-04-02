// Our url
server.log(http.agenturl());

class Twilio {

   TWILIO_ACCOUNT_SID = "____________________________"  // INSERT YOUR TWILIO ACCOUNT SID HERE
   TWILIO_AUTH_TOKEN = "______________________________" // INSERT YOUR TWILIO AUTH TOKEN HERE
   TWILIO_FROM_NUMBER = "+_______________";             // INSERT YOUR TWILIO PHONE NUMBER HERE


function send(to, message, callback = null) {
    local twilio_url = format("https://api.twilio.com/2010-04-01/Accounts/%s/SMS/Messages.json&amp;quot&quot;", TWILIO_ACCOUNT_SID);

    local auth = "Basic " + http.base64encode(TWILIO_ACCOUNT_SID+":"+TWILIO_AUTH_TOKEN);
    local body = http.urlencode({From=TWILIO_FROM_NUMBER, To="+________________", Body=message});       // INSERT YOUR PERSONAL PHONE NUMBER HERE
    local req = http.post(twilio_url, {Authorization=auth}, body);
    local res = req.sendsync();
    //server.log(auth);
        if(res.statuscode != 201) {
            server.log("error sending message: "+res.body);
        }
}

}


function requestHandler(request, response) {
   try {
    numberToSendTo <- "_______________";                 // INSERT YOUR PERSONAL PHONE NUMBER HERE
    message <- "Quick! Your lock has been cut!!!!!!";

    local response = twilio.send(numberToSendTo, message)

    server.log(response.statuscode + ": " + response.body)
    device.send("cut", "hello");
    response.send(200);
    }
    catch(err) {
        response.send(500);
    }
}

function sendText(whatever) {
    // Twilio
    twilioURL <- "https://USER:PASS@api.twilio.com/2010-04-01/Accounts/ID/Messages.json";
    twilioHeaders <- { "Content-Type": "application/x-www-form-urlencoded" };
    twilioNumber <- "_____________";                  // INSERT YOUR TWILIO PHONE NUMBER HERE


    server.log(whatever);

    numberToSendTo <- "_____________";               // INSERT YOUR TWILIO PHONE NUMBER HERE

    // Twilio Params
    message <- "Quick! Your lock has been cut!!!";
    authToken <- "________________________";         // INSERT YOUR TWILIO AUTHORS TOKEN HERE
    accSid <- "___________________________";         // INSERT YOUR TWILIO ACCOUNT SID HERE

    // Twilio Init
    twilio <- Twilio(accSid, authToken, numberToSendTo)
    twilio.send(numberToSendTo, message, function(response) {
         server.log(response.statuscode + " - " + response.body);
    });
}

device.on("cut", sendText);
