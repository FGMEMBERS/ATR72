var brakes = {

	# Manual Brakes get hydraulic power supply from crew stepping on brake pedals. Autobrakes get power from yellow hydraulic system. The yellow hydraulic system needs to provide atleast 1400 PSI hydraulic power to get autobrakes to work. An accumulator is used with auto-brakes to maintain constant hydraulic flow.
	
	# BRAKE SYSTEM INDICATOR
	# > Left Brake Press : Pressure applied on left main gear brakes
	# > Right Brake Press : Pressure applied on right main gear brakes
	# > Accumulator Press : Pressure of hydraulic fluid stored in hydraulic accumulator
	
	# The air pressure in accumulator (without any hydraulic fluid) is by defauly, 600 psi. The maximum pressure in there would be 4000 and the optimal pressure zone would be from 2500 to 3500 PSI.
	
	pressurize : func() {
	
		var brake_l = getprop("/controls/gear/brake-left");
		var brake_r = getprop("/controls/gear/brake-right");
		
		setprop("systems/hydraulic/brakes/pressure-left-psi", brake_l * 3000);
		setprop("systems/hydraulic/brakes/pressure-right-psi", brake_r * 3000);
		
		# NOTE: Max pressure available from brake pedals = 3000, but for auto-brakes the equation would be brake_x * yellow_hyd_press
		
		var accum_press = 600;
		
		if (hydraulics.blue_psi > 1600)
			accum_press = hydraulics.blue_psi - 1200;
		elsif (hydraulics.blue_psi > 600)
			accum_press = hydraulics.blue_psi;
			
		setprop("systems/hydraulic/brakes/accumulator-pressure-psi", accum_press);
	
	}

};
