var rev_prop = "/controls/reverse-pitch";
var pwr_setting = "/controls/power-setting";
setprop(rev_prop, 0);
setprop(pwr_setting, 1.00);

# Propellers Class

var DEG2RAD = 0.0174532925;

var approach_trgt = func(target_val, val_prop, incr_step, decr_step, band) {

	if (math.abs(target_val - getprop(val_prop)) > band) {
	
		if (getprop(val_prop) < target_val) {
		
			setprop(val_prop, getprop(val_prop) + incr_step);
		
		} else {
		
			setprop(val_prop, getprop(val_prop) - decr_step);
		
		}
	
	}

};

var prop = {

	propid: 0,
	name: "Propeller",
	numblades: 0,
	minrpm: 0,
	maxrpm: 0,
	minpitch: 0,
	maxpitch: 0,
	revpitch: 0,
	C_thrust: 0,
	hp: 0,
	feedtank: 0,
	
	# Functions with propellers
	
	## Constructor
	
	new: func(id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) {
	
		var t = {parents:[prop]};
		 
		t.propid = id;
		t.name = arg1;
		t.numblades = arg2;
		t.minrpm = arg3;
		t.maxrpm = arg4;
		t.minpitch = arg5;
		t.maxpitch = arg6;
		t.revpitch = arg7;
		t.C_thrust = arg8;
		t.hp = arg9;
		t.feedtank = arg10;
		
		return t;
	
	},
	
	## RPM Convert
	
	set_rpm: func(in_prop, out_prop, start_val) {
	
		if (getprop(in_prop) < start_val) {
		
			var rpm_trgt = 0 + (getprop("/velocities/airspeed-kt")/2);
		
			approach_trgt(rpm_trgt, out_prop, 4, 1, 4);
			
		} else {
		
			var C_pwr = getprop(pwr_setting);
		
			var rpm_trgt = C_pwr * me.maxrpm;
		
			# var rpm_trgt = (me.maxrpm * (getprop(in_prop) - start_val)/(100 - start_val)) + (getprop("/velocities/airspeed-kt")/2);
			
			approach_trgt(rpm_trgt, out_prop, 4, 1, 10);
			
		}
	
	},
	
	## Automatic Pitch
		
	set_pitch: func(n1_prop, out_prop, rpm_prop) {
	
		if(getprop(rev_prop)) {
		
			approach_trgt(me.revpitch, out_prop, 0.25, 0.25, 0.5);
		
		} else {
	
			var rpm = getprop(rpm_prop);
			
			if (rpm < 400) {
				setprop(out_prop, (((400 - rpm)/400) * (me.maxpitch - me.minpitch)) + me.minpitch);
			} else {
			
			#	var pitch = (((rpm - me.minrpm)/(me.maxrpm - me.minrpm)) * me.maxpitch);
			
			var pitch = ((getprop(n1_prop) - 50)/50)*me.maxpitch;
				
			if (pitch < me.minpitch)
				approach_trgt(me.minpitch, out_prop, 0.25, 0.25, 0.5);
			elsif (pitch > me.maxpitch)
				approach_trgt(me.maxpitch, out_prop, 0.25, 0.25, 0.5);
			else
				approach_trgt(pitch, out_prop, 0.25, 0.25, 0.5);
			
			}
			
		}
	
	},
	
	## Calculate Thrust
	
	set_thrust: func(dens_prop, rpm_prop, pitch_prop, thrust_prop) {
	
		var density = getprop(dens_prop);
		
		var rpm = getprop(rpm_prop);
		
		var pitch = getprop(pitch_prop);
	
		var thrust = me.numblades * me.C_thrust * density * rpm * rpm  * pitch * DEG2RAD * math.cos((pitch-6) * DEG2RAD * 1.1);
	
		setprop(thrust_prop, thrust);
	
	},
	
	## Propeller Shaft Torque
	
	set_torque: func(n1_prop, rpm_prop, torque_prop) {
	
		var pwr_hp = (me.hp * (getprop(n1_prop) - 20))/80;
		
		var torque = (4500 * pwr_hp) / (2 * math.pi * (getprop(rpm_prop) + 10));
		
		if (torque < 25.231)
			torque = 25.231;
			
		if (torque > 4000)
			torque = 4000;
		
		setprop(torque_prop, torque);
	
	},
	
	set_oilpressure : func (defaultoilpressure_property, oilpressure_property) {
		
		var currentPressure = getprop(defaultoilpressure_property);
		
		setprop(oilpressure_property, currentPressure*2);
	},
	
	set_oiltempCelsius : func (degreesF_property, degreesC_property) {
		var currentF = getprop(degreesF_property);
		setprop(degreesC_property, (currentF - 32) * 0.555556);
	},
	
	## Fuel Flow (this is done here as the engine used in a dummy engine)
	
	set_fuelflow: func(psfc, rpm_prop, fuelflow_prop) {

		var pwr_hp = (me.hp * getprop(rpm_prop))/me.maxrpm;
		
		var fuelflow = 0;
		
		if (pwr_hp > 0)
			fuelflow = (psfc * pwr_hp * 0.58); # Fuel flow is in KG/H
		
		setprop(fuelflow_prop, fuelflow);
	
	},
	
	fuel_consumption: func(fuelflow_prop, tank_kg_prop) {
	
		var delta_sec = getprop("/sim/time/delta-sec");
		
		var fuelflow_kgpds = (getprop(fuelflow_prop) / 3600) * delta_sec;
		
		setprop(tank_kg_prop, getprop(tank_kg_prop) - fuelflow_kgpds);
	
	}

};

# Main Propeller Loop

var propeller = {
       init : func {
            me.UPDATE_INTERVAL = 0.01;
            me.loopid = 0;
            
			me.props = [prop.new(0, "HS 568F 6 Blade Propeller", 6, 850, 1200, 4, 45, -12, 0.58, 2700, 2), prop.new(1, "HS 568F 6 Blade Propeller", 6, 850, 1200, 4, 45, -10, 0.58, 2700, 3)];
            
            setprop("/engines/engine/thruster/prop_pitch", 10);
            setprop("/engines/engine[1]/thruster/prop_pitch", 10);
            
            setprop("/engines/engine/thruster/prop_rpm", 0);
            setprop("/engines/engine[1]/thruster/prop_rpm", 0);
            
            setprop("/engines/engine/thruster/prop_torque", 25);
            setprop("/engines/engine[1]/thruster/prop_torque", 25);
            
            setprop("/engines/engine/fuelflow_kgph", 0);
            setprop("/engines/engine[1]/fuelflow_kgph", 0);            
            
			setprop("/engines/engine/oil-pressure-psi-adjusted", 0);
            setprop("/engines/engine[1]/oil-pressure-psi-adjusted", 0);
            
            setprop("/aircraft/prop-brake-fail", 0);
            
            me.reset();
    },
    	update : func {

    	foreach(var propeller; me.props) {
    	
    		var eng_tree = "/engines/engine[" ~ propeller.propid ~ "]/";
    	
    		if (getprop("/aircraft/prop-brake") == 1) {
    		
    			approach_trgt(0, eng_tree ~ "thruster/prop_rpm", 1, 5, 1);
    		
    		} else {
    		
    			propeller.set_rpm(eng_tree ~ "n1", eng_tree ~ "thruster/prop_rpm", 50);
    		
    		}
    		
    		propeller.set_pitch(eng_tree ~ "n1", eng_tree ~ "thruster/prop_pitch", eng_tree ~ "thruster/prop_rpm");
    		
    		propeller.set_thrust("environment/density-slugft3", eng_tree ~ "thruster/prop_rpm", eng_tree~ "thruster/prop_pitch", "/fdm/jsbsim/external_reactions/hs568f_prop" ~ propeller.propid ~ "/magnitude");
    		
    		propeller.set_torque(eng_tree ~ "n1", eng_tree ~ "thruster/prop_rpm", eng_tree ~ "thruster/prop_torque");
    		
    		propeller.set_fuelflow(0.45, eng_tree ~ "thruster/prop_rpm", eng_tree ~ "fuelflow-kgph");
    		
			propeller.set_oilpressure(eng_tree ~ "oil-pressure-psi", eng_tree ~ "oil-pressure-psi-adjusted");
    		
			propeller.set_oiltempCelsius(eng_tree ~ "oil-temperature-degf", eng_tree ~ "oil-temperature-degc");
			
    		propeller.fuel_consumption(eng_tree ~ "fuelflow-kgph", "/consumables/fuel/tank[" ~ propeller.feedtank ~ "]/level-kg");
    	
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
 propeller.init();
 });
