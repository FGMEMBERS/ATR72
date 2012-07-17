var ccas = {
	init : func {
			me.loopInterval = 0.1;
			setprop("/aircraft/ccas/sound/warning",0);
			setprop("/aircraft/ccas/master",0);
			me.update();
			},
	
	update : func {
			var totalCurrentMaster = getprop("/aircraft/ccas/master");	
			var totalCurrentActiveWarnings = getprop("/aircraft/ccas/sound/warning");	
			
#-- LDG GEAR NOT DOWN --#
			var lastGearWarningStatus = getprop("/aircraft/ccas/ldg_gear_not_down");
			if ((getprop("/surface-positions/flap-pos-norm") == 1) 
					and (me.all_gear_down() == 0) 
					and (getprop("/position/altitude-agl-ft") <= 500)) {
		
				setprop("/aircraft/ccas/ldg_gear_not_down", 1);
				if (lastGearWarningStatus != 1) {
					setprop("/aircraft/ccas/master", totalCurrentMaster + 1);
					setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings + 1);
					}
				}
			else {
				setprop("/aircraft/ccas/ldg_gear_not_down", 0);
				if (lastGearWarningStatus != 0) {
					if (totalCurrentMaster > 0) {
						setprop("/aircraft/ccas/master", totalCurrentMaster - 1);
						}
					if (totalCurrentActiveWarnings > 0) {
						setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings - 1);
						}
					}
				}

#-- end LDG GEAR NOT DOWN --#
#-- PROP BRK --#	
			var lastPropBrakeStatus = getprop("/aircraft/ccas/prop-brak-fault");
			if (getprop("/controls/atr72/prop-brake") != nil) {
				if (getprop("/controls/atr72/prop-brake") < 1 and getprop("/controls/atr72/prop-brake") > 0) {
					setprop("/aircraft/ccas/prop-brake-fault", 1);
					if (lastPropBrakeStatus != 1) {
						setprop("/aircraft/ccas/master", totalCurrentMaster + 1);
						setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings + 1);
						}
					}
				else {
					setprop("/aircraft/ccas/prop-brake-fault", 0);
					if (lastPropBrakeStatus != 0) {
						if (totalCurrentMaster > 0) {
							setprop("/aircraft/ccas/master", totalCurrentMaster - 1);
							}
						if (totalCurrentActiveWarnings > 0) {
							setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings - 1);
							}
						}				
					}
				}
#-- end PROP BRK --#
#-- FUEL --#
			var lastFuelStatus = getprop("/aircraft/ccas/fuel-fault");
			#also needs to check for fuel flow psi < 4 in line below
			if (getprop("/consumables/fuel/total-fuel-kg") < 160) {
				setprop("/aircraft/ccas/fuel-fault", 1);
				if (lastFuelStatus != 1) {
					setprop("/aircraft/ccas/master", totalCurrentMaster + 1);
					setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings + 1);
					}				
				}
			else {
				setprop("/aircraft/ccas/fuel-fault", 0);
				if (lastFuelStatus != 0) {
					if (totalCurrentMaster > 0) {
						setprop("/aircraft/ccas/master", totalCurrentMaster - 1);
						}
					if (totalCurrentActiveWarnings > 0) {
						setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings - 1);
						}
					}					
				}
#-- end FUEL --#			
			settimer(func {me.update();}, me.loopInterval);
			},
			
	all_gear_down : func {
			var gear0 = getprop("/gear/gear[0]/position-norm");
			var gear1 = getprop("/gear/gear[1]/position-norm");
			var gear2 = getprop("/gear/gear[2]/position-norm");

			if (gear0 == 1.0 and gear1 == 1.0 and gear2 == 1.0) {	
				return 1;
				}
			else {
				return 0;
				}
			},
};

setlistener("/sim/signals/fdm-initialized", func{ccas.init();});