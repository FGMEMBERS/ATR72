var ohp = "/controls/ohpanel/";

var ohpanel = {
       init : func {
            me.UPDATE_INTERVAL = 0.02;
            me.loopid = 0;
            
            me.reset();
    },
    	update : func {

    	# Landing Gear Indicators
    	
    	if (getprop("/gear/gear[0]/position-norm") == 0) {
    		setprop(ohp~ "ldggearn", 0); }
    	elsif (getprop("/gear/gear[0]/position-norm") == 1) {
    		setprop(ohp~ "ldggearn", 2); }
    	else { setprop(ohp~ "ldggearn", 1); }
    	
    	if (getprop("/gear/gear[1]/position-norm") == 0) {
    		setprop(ohp~ "ldggearl", 0); }
    	elsif (getprop("/gear/gear[1]/position-norm") == 1) {
    		setprop(ohp~ "ldggearl", 2); }
    	else { setprop(ohp~ "ldggearl", 1); }
    	
    	if (getprop("/gear/gear[2]/position-norm") == 0) {
    		setprop(ohp~ "ldggearr", 0); }
    	elsif (getprop("/gear/gear[2]/position-norm") == 1) {
    		setprop(ohp~ "ldggearr", 2); }
    	else { setprop(ohp~ "ldggearr", 1); }
    	
    	# Electric Generators and Buses
    	
    	if (getprop("/systems/electric/elec-buses/ac-bus1/volts") < 8) {
    		setprop(ohp~ "acbus1", 2); }
    	else {
    		setprop(ohp~ "acbus1", 0); }
    		
    	if (getprop("/systems/electric/elec-buses/ac-bus2/volts") < 8) {
    		setprop(ohp~ "acbus2", 2); }
    	else {
    		setprop(ohp~ "acbus2", 0); }
    		
    	if (getprop("/systems/electric/elec-buses/dc-bus1/volts") < 8) {
    		setprop(ohp~ "dcbus1", 2); }
    	else {
    		setprop(ohp~ "dcbus1", 0); }
    		
    	if (getprop("/systems/electric/elec-buses/ac-bus2/volts") < 8) {
    		setprop(ohp~ "dcbus2", 2); }
    	else {
    		setprop(ohp~ "dcbus2", 0); }
    	
    	if (getprop("/systems/electric/util-volts") < 8) {
    		setprop(ohp~ "util", 2); }
    	elsif (getprop("/controls/elec_panel/util-bus")) {
    		setprop(ohp~ "util", 0); }
    	else {
    		setprop(ohp~ "util", 1); }
    		
    	if (getprop("/controls/elec_panel/DCgen1")) {
    		setprop(ohp~ "dcgen1", 0);
    	} else {
    		setprop(ohp~ "dcgen1", 1);
    	}
    	
    	if (getprop("/controls/elec_panel/DCgen2")) {
    		setprop(ohp~ "dcgen2", 0);
    	} else {
    		setprop(ohp~ "dcgen2", 1);
    	}
    	
    	if (getprop("/controls/elec_panel/gen1")) {
    		setprop(ohp~ "acgen1", 0);
    	} else {
    		setprop(ohp~ "acgen1", 1);
    	}
    	
    	if (getprop("/controls/elec_panel/gen2")) {
    		setprop(ohp~ "acgen2", 0);
    	} else {
    		setprop(ohp~ "acgen2", 1);
    	}
    	
    	if ((getprop("/controls/elec_panel/ext-pwr") == 1) and (getprop("velocities/groundspeed-kt") < 10)) {
    		setprop(ohp~ "extpwr", 2);
    	} elsif (getprop("/velocities/groundspeed-kt")< 10) {
    		setprop(ohp~ "extpwr", 1);
    	} else {
    		setprop(ohp~ "extpwr", 0);
    	}
    	
    	if (getprop("/engines/engine[0]/fuelflow-kgph") < 300) {
    		setprop(ohp~ "lfuelind", 1);
    	} else {
    		setprop(ohp~ "lfuelind", 0);
    	}
    	
    	if (getprop("/engines/engine[1]/fuelflow-kgph") < 300) {
    		setprop(ohp~ "rfuelind", 1);
    	} else {
    		setprop(ohp~ "rfuelind", 0);
    	}
    	
    	if (getprop("/systems/electric/elec-buses/ac-bus1/amps") < 12) {
    		setprop(ohp~ "bluepump", 2);
    	} elsif (getprop("/controls/hyd_panel/blue-pump") == 0) {
    		setprop(ohp~ "bluepump", 1);
    	} else {
    		setprop(ohp~ "bluepump", 0);
    	}
    	
    	if (getprop("/systems/electric/elec-buses/ac-bus2/amps") < 12) {
    		setprop(ohp~ "greenpump", 2);
    	} elsif (getprop("/controls/hyd_panel/green-pump") == 0) {
    		setprop(ohp~ "greenpump", 1);
    	} else {
    		setprop(ohp~ "greenpump", 0);
    	}
    	
    	if (getprop("/systems/electric/util-volts") < 8) {
    		setprop(ohp~ "auxpump", 2);
    	} elsif (getprop("/controls/hyd_panel/aux-pump") == 0) {
    		setprop(ohp~ "auxpump", 1);
    	} else {
    		setprop(ohp~ "auxpump", 0);
    	}
    	
    	if (getprop("/systems/hydraulic/blue-pressure-psi") != nil) {
			if (getprop("/systems/hydraulic/blue-pressure-psi") < 2000) {
				setprop(ohp~ "hydblueind", 1);
			} else {
				setprop(ohp~ "hydblueind", 0);
			}
    	}
    	
    	if (getprop("/systems/hydraulic/green-pressure-psi") != nil) {
			if (getprop("/systems/hydraulic/green-pressure-psi") < 2000) {
				setprop(ohp~ "hydgreenind", 1);
			} else {
				setprop(ohp~ "hydgreenind", 0);
			}
		}
    	
    	if (getprop("/systems/electric/elec-buses/ac-bus1/volts") < 12) {
    		setprop(ohp~ "gen1", 2);
    	} elsif (getprop("controls/elec_panel/gen1") == 0) {
    		setprop(ohp~ "gen1", 1);
    	} else {
    		setprop(ohp~ "gen1", 0);
    	}
    	
    	if (getprop("/systems/electric/elec-buses/ac-bus2/volts") < 12) {
    		setprop(ohp~ "gen2", 2);
    	} elsif (getprop("controls/elec_panel/gen2") == 0) {
    		setprop(ohp~ "gen2", 1);
    	} else {
    		setprop(ohp~ "gen2", 0);
    	}
    	
    	# Battery Flip Switches
    	
    	if (getprop("/controls/elec_panel/battery")) {
    	
    		if (getprop("/controls/elec_panel/battery-mode")) {
    			setprop("/controls/elec_panel/batt-main", 0);
    			setprop("/controls/elec_panel/batt-emer", 1);
    		} else {
    			setprop("/controls/elec_panel/batt-main", 1);
    			setprop("/controls/elec_panel/batt-emer", 0);
    		}
    	
    	} else {
    	
    		setprop("/controls/elec_panel/batt-main", 0);
    		setprop("/controls/elec_panel/batt-emer", 0);
    	
    	}

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

setlistener("sim/signals/fdm-initialized", func
 {
 ohpanel.init();
 });
