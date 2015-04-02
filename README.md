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



For anyone new to Electric Imp, please check out the [quickstart](https://electricimp.com/docs/gettingstarted/quickstartguide/) guide.



---------------------------------------------------------------------------------------------------------------------

**How does it work?**

The Electric Imp development platform is unique in that the user codes two different portions for its function: the device portion and the agent portion. The device code controls the functionality of the device itself and how it behaves in its environment. Here, in the device portion, is where you would code the imp to respond to certain stimuli. Later on, I will include the code for the agent portion which governs how the Imp communicates with the server and the internet. 

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
    
    // if our digital input pin sees a HIGH, tell the agent to run it's code!!!
    if (status == 1) {
        agent.send("cut", status);
    }
    
}

// Start reading from our pin
readPin();

```

This code governs the functionality of the device. Ok, so, when the device powers on, the first code that is run is the call to the readPin() function at the bottom. When we've called the readPin() function, we jump up to that code and proceed downards. In readPin(), the first thing we do is create a variable named "pin" and assign it to the first pin on the Imp april dev board ( local pin = hardware.pin1 ). This will be the pin which determines if the lock has been cut. 

Next in the readPin() function, we configure our newly created pin to be a digital input. This means that we are assigning that particular pin for a parcticular mode of operation. In this case, it will be used as a digital input which will recieve a 0 or a 1. More specifically, we are using DIGITAL_IN_WAKEUP which is a specific function of the configure library. DIGITAL_IN_WAKEUP allows the device to enter a sleep state and only proceed with the following code when the configured pin recieves a digital HIGH. 






















