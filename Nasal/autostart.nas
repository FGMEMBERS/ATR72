var autostart = func() {

	# Set Throttles to IDLE
	setprop("/controls/engines/engine[0]/throttle", 0);
	setprop("/controls/engines/engine[1]/throttle", 0);
	
	# Set Fuel Values to OPEN
	setprop("/controls/engines/engine[0]/fuel-pump", 1);
	setprop("/controls/engines/engine[1]/fuel-pump", 1);
	
	# Set Idle Gate Lever to FLIGHT IDLE
	setprop("/controls/atr72/idle-gate", 1);
	
	# Set Propeller Brake to OFF
	setprop("/controls/atr72/prop-brake", 0);
	
	#Cranking is not required for autostart, that's just something to make the manual start-up procedure more realistic
	
	# This is the START A+B part of the manual start-up
	setprop("/controls/electric/startAB", 1);
	
	
	setprop("controls/engines/engine[0]/cutoff", 0);
	
	# Now, the engine starters
	
	var engine1start = setlistener("engines/engine/n1", func
	{
		if (getprop("/engines/engine/n1") > 40) {
			settimer(func() {
				setprop("/controls/engines/engine[1]/starter", 1);	
			}, 2);
			settimer(func() {
				setprop("controls/engines/engine[1]/cutoff", 0);
			}, 2);
			removelistener(engine1start);
		}
	}, 0, 0);
	

	# Turn on Engine Generators
	
	setprop("/controls/electric/gen0", 1);
	setprop("/controls/electric/gen1", 1);
	
	setprop("/controls/engines/engine/starter", 1);
	setprop("/controls/engines/engine[1]/starter", 1);
	
	setprop("/controls/electric/startAB", 0);

};
