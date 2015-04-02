# IoT-Bike-Lock
Electric Imp IoT Bike Lock

Hello bicycle and motorcycle enthusiasts!!!

This project was inspired out of the frustration I've experience with bicycle theft living here in NYC. It's a constant problem, and I wanted to create a connected device that would somehow allow me to know exactly when my bicycle's security has been compromised. 

The device is built on the Electric Imp platform and uses a rather simple implementation. It works with as a continuity breaker; when a thief has broken and/or cut my bicycle lock, the electric imp senses a change in voltage on a particular pin and pings an SMS text service to send me a text saying that the lock has been cut, and from there you can immediately proceed to retrieving your property before it is scraped for parts.

---------------------------------------------------------------------------------------------------------------------

**What you will need:** 

1) [Electric Imp](http://www.adafruit.com/products/1129)

2) [Electric imp April dev board](http://www.adafruit.com/products/1130?gclid=CLzq7sOB2MQCFZEdgQodVnUA9w)

3) Small breadboard and a couple jumper wires:

4) [Any general purpose op amp](http://www.digikey.com/product-detail/en/LF411CN%2FNOPB/LF411CN%2FNOPB-ND/8891)



For anyone new to Electric Imp, please check out the quickstart guide found here:
https://electricimp.com/docs/gettingstarted/quickstartguide/


---------------------------------------------------------------------------------------------------------------------

**How does it work?**

The Electric Imp development platform is unique in that the user codes two different portions for its function: the device portion and the agent portion. The device code controls the functionality of the device itself and how it behaves in its environment. Here, in the device portion, is where you would code the imp to respond to certain stimuli.

Below is the portion of code that you can copy into the *device* section of the Electric Imp environment on the right hand side of the page:


```
function readPin() {
    
    // create a variable called "pin" and assign it to Electric Imp pin #1
    local pin = hardware.pin1;
    
    // configure our pin to be a digital IN 
    pin.configure(DIGITAL_IN_WAKEUP, readPin);
    
    // create a variable called "status" and store within it the voltage of the pin
    local status = pin.read();
    
    server.log(status);
    
    if (status == 1) {
        agent.send("cut", status);
    }
    
}

// Start reading from our pin
readPin();

```

This code governs the functionality of the device. Essentially, we have a function called "readPin" which is called at the bottom 

