var autostart = func() {

	print("Autostarting Aircraft Engines, please set Electrical configs/settings yourself from the OHPanel depending on your aircraft's needs.");

	# Set Throttles to IDLE
	setprop("/controls/engines/engine[0]/throttle", 0);
	setprop("/controls/engines/engine[1]/throttle", 0);
	
	# Set Fuel Values to OPEN
	setprop("/controls/engines/engine[0]/fuel-pump", 1);
	setprop("/controls/engines/engine[1]/fuel-pump", 1);
	
	# Set Idle Gate Lever to FLIGHT IDLE
	setprop("/aircraft/idle-gate", 1);
	
	# Set Propeller Brake to OFF
	setprop("/aircraft/prop-brake", 0);
	
	#Cranking is not required for autostart, that's just something to make the manual start-up procedure more realistic
	
	# This is the START A+B part of the manual start-up
	setprop("/controls/electric/engine[0]/generator", 1);
	setprop("/controls/electric/engine[1]/generator", 1);
	
	
	setprop("controls/engines/engine[0]/cutoff", 0);
	setprop("/controls/engines/engine[0]/starter", 1);	
	
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
			setprop("/controls/electric/engine[0]/generator", 0);
			setprop("/controls/engines/engine[1]/starter", 0);
			removelistener(engine1start);
		}
	}, 0, 0);
	
	var engine2start = setlistener("engines/engine[1]/n1", func
	{
		if (getprop("/engines/engine[1]/n1") > 40) {
			setprop("/controls/electric/engine[1]/generator", 0);
			setprop("/controls/engines/engine[1]/starter", 0);
			
			print("Both Aircraft Engines (PW127F) have been started up, have a nice flight!");
			
			removelistener(engine2start);
		}
	}, 0, 0);
	

	# Turn on Engine Generators
	
	setprop("/controls/elec_panel/gen1", 1);
	setprop("/controls/elec_panel/gen2", 1);

};
