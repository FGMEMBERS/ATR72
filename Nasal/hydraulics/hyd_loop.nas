var hyd_ctrl = "/controls/hyd_panel/";

var hydraulics_loop = {
       init : func {
            me.UPDATE_INTERVAL = 2;
            me.loopid = 0;
            
            # Initialize Pump Settings
            
            setprop(hyd_ctrl~ "blue-pump", 1);
            setprop(hyd_ctrl~ "green-pump", 1);
            setprop(hyd_ctrl~ "aux-pump", 0);
            setprop(hyd_ctrl~ "x-feed", 0);
            
            me.reset();
    },
    	update : func {
    	
    	# BLUE and AUX Hydraulics Pump
    	
    	if (getprop(hyd_ctrl~ "blue-pump") == 1)
    		hyd_blue.elec_pump(getprop("/systems/electric/elec-buses/ac-bus1/amps"));
    	else
    		hydraulics.blue_psi = 0;
    		
    	# GREEN Hydraulics Pump
    	
    	if (getprop(hyd_ctrl~ "green-pump") == 1)
    		hyd_green.elec_pump(getprop("/systems/electric/elec-buses/ac-bus2/amps"));
    	else
    		hydraulics.green_psi = 0;
    		
		# AUX Hydraulics Pump
		
		if (getprop(hyd_ctrl~ "aux-pump") == 1)
    		hyd_blue.aux_pump(getprop("/systems/electric/util-volts"));
    	
    	# Some Final Stuff and copy nasal variables to the property tree
    	
    	if (getprop(hyd_ctrl~ "x-feed"))    	
    		hydraulics.xfeed_apply();
    		
    	if (hydraulics.green_psi > 3000)
    		hydraulics.green_psi = 3000;
    		
    	if (hydraulics.blue_psi > 3000)
    		hydraulics.blue_psi = 3000;
    	
    	hydraulics.update_props();
    	
    	# Now, run output calculation and priority valve functions for individual systems
    	
    	## GREEN HYDRAULIC SYSTEM
    	
    	hyd_green.power_outputs();
    	
    	## BLUE HYDRAULIC SYSTEM
    	
    	hyd_blue.power_outputs();
		
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
 hydraulics_loop.init();
 print("ATR72 Hydraulic System ..... Initialized");
 });
