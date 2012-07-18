setprop("/instrumentation/fmc/vspeeds/V1", 0);
setprop("/instrumentation/fmc/vspeeds/VR", 0);
setprop("/instrumentation/fmc/vspeeds/V2", 0);

var nose_wow_sav = 0;
var left_wow_sav = 0;
var right_wow_sav = 0;

var cpy_props = func() {

	if ((getprop("/sim/replay/time") == 0) or (getprop("/sim/replay/time") == nil)) {
	
		setprop("/aircraft/wingflex", getprop("/fdm/jsbsim/aero/force/Lift_alpha"));
		
	}

};

var general_loop_1 = {
       init : func {
            me.UPDATE_INTERVAL = 0.02;
            me.loopid = 0;
            
            setprop("/gear/tilt/left-tilt-deg", 0);
            setprop("/gear/tilt/right-tilt-deg", 0);
            
            me.strobe_count = 0;
            me.beacon_count = 0;
            
            me.reset();
    },
    	update : func {

    	cpy_props();
    	
    	# Strobe Lights
    	
    	if (getprop("/controls/lighting/strobe")) {
    		
    		if ((me.strobe_count == 30) or (me.strobe_count == 31) or (me.strobe_count == 37) or (me.strobe_count == 36)) {
    			setprop("/controls/lighting/strobe-state", 1);
    		} else {
    			setprop("/controls/lighting/strobe-state", 0);
    		}
    		
    		if (me.strobe_count == 40) {
    			me.strobe_count = 0;
    		} else {
    			me.strobe_count += 1;
    		}
    		
    	} else {
    		setprop("/controls/lighting/strobe-state", 0);
    	}
    	
    	# Beacon Lights
    	
    	if (getprop("/controls/lighting/beacon")) {
    		
    		if ((me.beacon_count == 15) or (me.beacon_count == 16) or (me.beacon_count == 17)) {
    			setprop("/controls/lighting/beacon-state", 1);
    		} else {
    			setprop("/controls/lighting/beacon-state", 0);
    		}
    		
    		if (me.beacon_count == 40) {
    			me.beacon_count = 0;
    		} else {
    			me.beacon_count += 1;
    		}
    		
    	} else {
    		setprop("/controls/lighting/beacon-state", 0);
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

var tyresmoke = {
       init : func {
            me.UPDATE_INTERVAL = 0.1;
            me.loopid = 0;
            
            me.reset();
    },
    	update : func {
    	
    	# Tyre-smoke
    	
			var nose_wow_cur = getprop("/gear/gear/wow");
			var left_wow_cur = getprop("/gear/gear[1]/wow");
			var right_wow_cur = getprop("/gear/gear[1]/wow");
		
			if (!nose_wow_cur or nose_wow_sav) {
				setprop("/gear/gear[0]/tyresmoke", 0);
			} else {
				setprop("/gear/gear[0]/tyresmoke", 1);
			}
			
			if (!left_wow_cur or left_wow_sav) {
				setprop("/gear/gear[1]/tyresmoke", 0);
			} else {
				setprop("/gear/gear[1]/tyresmoke", 1);
			}
			
			if (!right_wow_cur or right_wow_sav) {
				setprop("/gear/gear[2]/tyresmoke", 0);
			} else {
				setprop("/gear/gear[2]/tyresmoke", 1);
			}
		
			nose_wow_sav = nose_wow_cur;
			left_wow_sav = left_wow_cur;
			right_wow_sav = right_wow_cur;
				
			if (left_wow_cur and (getprop("/velocities/airspeed-kt") > 70) and (getprop("controls/gear/brake-left") > 0.5)) {
				setprop("/gear/gear[1]/tyresmoke", 1);
			}
				
			if (right_wow_cur and (getprop("/velocities/airspeed-kt") > 70) and (getprop("controls/gear/brake-right") > 0.5)) {
				setprop("/gear/gear[2]/tyresmoke", 1);
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
 general_loop_1.init();
 tyresmoke.init();
 });
