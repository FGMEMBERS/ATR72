var arduyoke = {
       init : func {
            me.UPDATE_INTERVAL = 0.01;
            me.loopid = 0;
            
            me.reset();
    },
    	update : func {

		if(getprop("/arduino/input/pitch-cmd") != nil) {
			setprop("/controls/flight/elevator", getprop("/arduino/input/pitch-cmd")/130);
		}
		
		if(getprop("/arduino/input/roll-cmd") != nil) {
			setprop("/controls/flight/aileron", getprop("/arduino/input/roll-cmd")/80);
		}
		
		if(getprop("/arduino/input/rudder") != nil) {
			setprop("/controls/flight/rudder", getprop("/arduino/input/rudder")*math.abs(getprop("/arduino/input/rudder"))*1.5);
		}
		
		setprop("/controls/engines/engine[1]/throttle", getprop("/controls/engines/engine/throttle"));
		
		# Switches
		
		if (getprop("/arduino/input/switches/starter") != nil) {
			setprop("/controls/elec_panel/start-mode", getprop("/arduino/input/switches/starter")*4);
			if (getprop("/arduino/input/switches/starter")) {
				setprop("/controls/electric/engine[0]/generator", 1);
				setprop("/controls/electric/engine[1]/generator", 1);
			}
			controls.startEngine(getprop("/arduino/input/switches/starter"));
		}
		
		setprop("/controls/gear/brake-left", getprop("/arduino/input/switches/brakes")*0.6);
		
		setprop("/controls/gear/brake-right", getprop("/arduino/input/switches/brakes")*0.6);
		
		setprop("/controls/engines/engine[0]/cutoff", !getprop("/arduino/input/switches/mag-l"));
		setprop("/controls/engines/engine[0]/generator", getprop("/arduino/input/switches/mag-l"));
		
		setprop("/controls/engines/engine[1]/cutoff", !getprop("/arduino/input/switches/mag-r"));
		setprop("/controls/engines/engine[1]/generator", getprop("/arduino/input/switches/mag-r"));
		
		setprop("/controls/elec_panel/gen1", getprop("/arduino/input/switches/mag-l"));
		setprop("/controls/elec_panel/gen2", getprop("/arduino/input/switches/mag-r"));
	
		setprop("/controls/engines/engine/fuel-pump", getprop("/arduino/input/switches/f-pump"));
		setprop("/controls/engines/engine[1]/fuel-pump", getprop("/arduino/input/switches/f-pump"));
		
		setprop("/controls/elec_panel/batt-main", getprop("/arduino/input/switches/master"));
		setprop("/controls/elec_panel/battery", getprop("/arduino/input/switches/master"));
    	
	},

        reset : func {
            me.loopid += 1;
            me._loop_(me.loopid);
    },
        _loop_ : func(id) {
            id == me.loopid or return;
            me.update();
            settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }

};

setlistener("sim/signals/fdm-initialized", func {
	arduyoke.init();
	print("Initialized ArduCockpit Mega v1.0");
});
