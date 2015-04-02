function readPin() {
    
    
    local pin = hardware.pin1;
    
    pin.configure(DIGITAL_IN_WAKEUP, readPin);
    
    local status = pin.read();
    
    server.log(status);
    
    if (status == 1) {
        agent.send("cut", status);
    }
    
    
}

readPin();
