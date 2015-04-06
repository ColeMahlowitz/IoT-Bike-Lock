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

#Assembling the Physical Device

Once you have soldered male pins to the development board, you can connect it to your breadboard and wire up the device according to the schematic and image below:


*Fritzing*

![alt tag](https://cloud.githubusercontent.com/assets/11773778/6984998/7d700762-d9fc-11e4-86f9-5da2cd7b5131.png)


*Eagle*

![alt tag] (https://cloud.githubusercontent.com/assets/11773778/6984997/7c0c222a-d9fc-11e4-9a36-1eebf2fd6e25.png)



*notice in both images there is a long snaky looking wire from pin3 of the op amp (the non-inverting input pin) to ground. This is the wire that will snake along your actual chain which will be our detect wire!*


In terms of op amp selection, you can use any general op amp. I chose the lm358 dual low power op amp because I already had it in my posetion. Most typical single op amps will have their output on pin 5 or 6, so please check your op amps datasheet. The output for the LM358's first op amp is pin1 which is connected to the April's pin1 as seen in the Fritzing and Eagle images.


![alt tag] (https://cloud.githubusercontent.com/assets/11773778/6999374/8ff69adc-dbd6-11e4-8622-0a7ba3e6d7b5.JPG)

![alt tag] (https://cloud.githubusercontent.com/assets/11773778/6999375/9934b494-dbd6-11e4-8397-2f452757ffd9.JPG)


And above are some photos of the actual device. The long yellow wire is the wire that you would snake along your actual bike lock. The wire itself doesn't neccesarily have to be discrete because it is impossible to remove the bike and not break the wire unless you know how to power the device on and off. 



--------------------------------------------------------------------------------------------------------------------

# Seting up the Software Code


The Electric Imp IDE platform is unique in that the user codes two different portions for its function: the device portion and the agent portion. The device code controls the functionality of the device itself and how it behaves in its environment. Here, in the device portion, is where you would code the imp to respond to certain stimuli. Later on, I will include the code for the agent portion which governs how the Imp communicates with the server and the internet. 

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



**...wait.......how do you generate a digital "HIGH" when you cut/disconnect a wire?**



I could have easily connected pin1 to voltage and written the code to text me when the pin goes low (when the lock has been cut and the pin has been separated from voltage) and just coded the imp to wakeup every second or so and check the pin status to see if it was high. This would have worked, but would have drained the battery much quicker than using DIGITAL_IN_WAKEUP which puts the Imp into a sleep state and only runs and calls a function when it recieves a HIGH input. 



In this configuration, I am using the 358 op amp as a comparator. If you refer to the schematic and fritzing image at the top of the tutorial, you will notice that only the non inverting input (pin3) of the op amp is tied to ground. Because only the + pin of the op amp's input is tied to ground and the - pin is left floating, the voltage on the negative pin is effectively higher, causing the op amp to rail LOW. Once the thief cuts the lock and separates pin3 from ground, the output rails HIGH. 



essentially...... when the thief breaks the lock, they separate the wire connecting the op amps positive input to ground, causing the op amp to rail HIGH which wakes up the Imp!!!!!


--------------------------------------------------------------------------------------------------------------------


#Agent Code

Okaaaay, so now that we are able to wake the Imp up and established a communication with the server (using agent.send(string, object) ), we can now code the *agent* portion of the Imp which runs on the Imp cloud and will determine how the Imp communicates via the internet.



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

**What's going on in the agent code?**

Once we wakeup the device and ping the server with the variable "status" stored in the second parameter of  agent.send(), we interface with Twilio via the internet and tell Twilio to send us a text with a message we specified.
In order to do so, we need to include all of the parameters that the squirrel language will need via the [Twilio API](https://github.com/electricimp/Twilio). These are found under the Twilio class at the top of the agent code.

When the agent code first reaches [device.on](https://electricimp.com/docs/api/device/on/)("cut", sendText), it calls the sendText() method which executes Twilio's text messaging service via the "twilio.send" function.

Notice how both your personal phone number and your Twilio phone number HAVE a "+" in front of them in the Twilio class at the top of the code and DON'T HAVE a "+" in the sendText function. This will not work if you don't have those +'s in the right places!

--------------------------------------------------------------------------------------------------------------------

#Hooking Up the Device to Your Bicycle Lock


Once you build and run this code on your breadboard device and power the device, you should recieve a text message via Twilio when you disconnect the op amp's pin3 to ground. In order to make this work as a continuity breaker, we have to connect a wire from ground on the device, loop it all the way around your chain (underneath your clotch cover ofcourse so it's not visible), and connect it back to pin3 of the op amp on the device. This way it is impossible for the thief to take your bike without separating pin3 from ground, thus triggering the Imp to ping the server and make Twilio send us a text!! Yeahhh!!!!!!11!1!!!11111!!!


--------------------------------------------------------------------------------------------------------------------

#Conclusion


Essentially, this device was built to immediately alert me via text when my lock has been cut. It does so in these steps:

1) device stays dormant until it detects a break in continuity

2) device pings to the server that continuity has been broken

3) server runs the agent code and communicates with twilio over the Imp cloud

4) Twilio sends us a text message



This code is simple enough to be implemented wherever you need to be alerted that something has been broken. For example, I can use the exact same code to alert me via text if......let's say.........when any kind of security lock has been opened, or if the integrity of some building structure has been compromised etc.... 


Right now, this is a stage 1 prototype, so there are a few things that could be implimented in the future to make this much more usable. For example, the user needs to connect pin3 to ground before powering up the device lest they send a text to themselves upon chaining up their bike. It would also be really cool to disable this feature via your phone which would require some callback capabilities. 



--------------------------------------------------------------------------------------------------------------------

#Rescources

-https://electricimp.com/docs/gettingstarted/quickstartguide/

-http://www.ee.surrey.ac.uk/Projects/CAL/op-amps/comparators/comparat.htm

-http://alexba.in/blog/2014/01/06/receiving-sms-notifications-from-your-washer/

-https://electricimp.com/docs/

-https://github.com/electricimp/Twilio








