# IoT-Bike-Lock


**Introduction**

Hello bicycle and motorcycle enthusiasts!!!

This project was inspired out of the frustration I've experience with bicycle theft living here in NYC. It's a constant problem, and I wanted to create a connected device that would somehow allow me to know exactly when my bicycle's security has been compromised. 

The device is built on the Electric Imp platform and uses a rather simple implementation. It works with as a continuity breaker; when a thief has broken and/or cut my bicycle lock, the electric imp senses a change in voltage on a particular pin and pings an SMS text service to send me a text saying that the lock has been cut. From that piont, I can immediately proceed to retrieving my bicycle/moped before it's taken to nowheresville and scrapped for parts!


---------------------------------------------------------------------------------------------------------------------

#What you will need:

1) [Electric Imp](http://www.adafruit.com/products/1129)

2) [Electric imp April dev board](http://www.adafruit.com/products/1130?gclid=CLzq7sOB2MQCFZEdgQodVnUA9w)

3) Small breadboard and a couple jumper wires

4) [Any general purpose op amp](http://www.digikey.com/product-detail/en/LF411CN%2FNOPB/LF411CN%2FNOPB-ND/8891). I am using the LM2904 low power op amp.

5) A Twilio account ([sign in](https://www.twilio.com/login) / [sign up](https://www.twilio.com/try-twilio))

6) [An Electric Imp user account] (https://ide.electricimp.com/login)


*nota bene* if you aren't yet familiar with the Imp platform, please check out the [quickstart](https://electricimp.com/docs/gettingstarted/quickstartguide/) guide.

--------------------------------------------------------------------------------------------------------------------

#Assembling the Device

Once you have soldered male pins to the development board, you can connect it to your breadboard and wire up the device according to the schematic and image below:


Fritzing:



Eagle:










--------------------------------------------------------------------------------------------------------------------

#How does it work?

The Electric Imp development platform is unique in that the user codes two different portions for its function: the device portion and the agent portion. The device code controls the functionality of the device itself and how it behaves in its environment. Here, in the device portion, is where you would code the imp to respond to certain stimuli. Later on, I will include the code for the agent portion which governs how the Imp communicates with the server and the internet. 

Below is the portion of code that you can copy into the **device** section of the Electric Imp environment on the right hand side of the page once you login to your account:


#Device Code


```
function readPin() {
    
    // create a variable called "pin" and assign it to Electric Imp pin #1
    local pin = hardware.pin1;
    
    // configure our pin to be a digital IN 
    pin.configure(DIGITAL_IN_WAKEUP, readPin);
    
    // create a variable called "status" and store within it the voltage of the pin
    local status = pin.read();
    
    server.log(status);
    
    // if our digital input pin sees a HIGH, tell the agent to run it's code!!!
    if (status == 1) {
        agent.send("cut", status);
    }
    
}

// Start reading from our pin
readPin();
```

This code governs the functionality of the device. Ok, so, when the device powers on, the first code that is run is the call to the readPin() function at the bottom. When we've called the readPin() function, we jump up to that code and proceed downards. In readPin(), the first thing we do is create a variable named "pin" and assign it to the first pin on the Imp april dev board ( [local pin = hardware.pin1](http://electricimp.com/docs/api/hardware/pin/) ). This will be the pin which determines if the lock has been cut. 

Next in the readPin() function, we configure our newly created pin to be a digital input. This means that we are assigning that particular pin for a parcticular mode of operation. In this case, it will be used as a digital input which will recieve a 0 or a 1. More specifically, we are using [DIGITAL_IN_WAKEUP](https://electricimp.com/docs/api/hardware/pin/configure/) which is a specific function of the configure library. DIGITAL_IN_WAKEUP allows the device to enter a sleep state and only proceed with the following code when the configured pin recieves a digital HIGH. This demonstrates the event driven nature of the Imp. Please check [event driven programming](https://electricimp.com/docs/resources/eventprogramming/) for more info on event driven programming and how it corresponds with the Imp model.

Then, I make a variable called "status" and store in it the voltage I read from the pin (which will be high when I arrive at this portion of the code). The next portion of the code uses an "if" statement which sends a message to the *agent* (internet communicative) portion of the code once the variable stored in status (the voltage on pin1) is HIGH. The Imp device talks the the Imp agent via [agent.send](https://electricimp.com/docs/api/agent/send/)



**...wait...how will I generate a digital "HIGH" when I cut/disconnect a wire?**



I could have easily connected pin1 to voltage and written the code to text me when the pin goes low (when the lock has been cut and the pin has been separated from voltage) and just coded the imp to wakeup every second or so and check the pin status to see if it was high. This would have worked, but would have drained the battery much quicker than using DIGITAL_IN_WAKEUP which puts the Imp into a sleep state and only runs and calls a function when it recieves a HIGH. 



In this configuration, I am using an LM2904 op amp as a comparator. If you refer to the schematic and fritzing image at the top of the tutorial, you will notice that both the inverting input (pin2) and the non inverting input (pin3) of the op amp are both tied to ground. Because they are referenecd to the same point, the output of the op amp which is connected to our wakeup pin is LOW. When the thief cuts the lock (breaking the long wire which snakes from pin3 to ground), the op amp will rail HIGH because the voltage at that pin will be floating and effectively higher than the voltage on pin2 (which is always tied to ground). 


essentially...... when the thief breaks the lock, they separate the wire connecting the op amps positive input to ground, causing the op amp to rail HIGH which wakes up the Imp!!!!!


--------------------------------------------------------------------------------------------------------------------


#Agent Code

Okaaaay, so now that we are able to wake the Imp up and established a communication with the server (using agent.send(string, object) ), we can now code the *agent* portion of the Imp to determine how it will communicate over the internet.



```
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
```




You will need to copy and paste this into the *agent* section of the Imp environment online and insert all of the specified information into the blank "_____________" sections. More information about your account SID and the authors token can be found [here](https://www.twilio.com/help/faq/twilio-basics/what-is-the-auth-token-and-how-can-i-change-it)








