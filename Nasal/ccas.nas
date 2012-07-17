var ccas = {
	init : func {
			me.loopInterval = 0.1;
			setprop("/aircraft/ccas/sound/warning",0);
			setprop("/aircraft/ccas/sound/caution",0);
			setprop("/aircraft/ccas/master-warning",0);
			setprop("/aircraft/ccas/master-caution",0);
			me.update();
			},
	
	update : func {
			var totalCurrentMasterWarn = getprop("/aircraft/ccas/master-warning");	
			var totalCurrentMasterCaution = getprop("/aircraft/ccas/master-caution");	
			var totalCurrentActiveWarnings = getprop("/aircraft/ccas/sound/warning");	
			var totalCurrentActiveCautions = getprop("/aircraft/ccas/sound/caution");	
			
#-- LDG GEAR NOT DOWN --#
			var lastGearWarningStatus = getprop("/aircraft/ccas/ldg_gear_not_down");
			if ((getprop("/surface-positions/flap-pos-norm") == 1) 
					and (me.all_gear_down() == 0) 
					and (getprop("/position/altitude-agl-ft") <= 500)) {
		
				setprop("/aircraft/ccas/ldg_gear_not_down", 1);
				if (lastGearWarningStatus != 1) {
					setprop("/aircraft/ccas/master-warning", totalCurrentMasterWarn + 1);
					setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings + 1);
					}
				}
			else {
				setprop("/aircraft/ccas/ldg_gear_not_down", 0);
				if (lastGearWarningStatus != 0) {
					if (totalCurrentMasterWarn > 0) {
						setprop("/aircraft/ccas/master-warning", totalCurrentMasterWarn - 1);
						}
					if (totalCurrentActiveWarnings > 0) {
						setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings - 1);
						}
					}
				}

#-- end LDG GEAR NOT DOWN --#
#-- PROP BRK --#	
			var lastPropBrakeStatus = getprop("/aircraft/ccas/prop-brak-fault");

			if ((getprop("/aircraft/prop-brake") < 1 and getprop("/aircraft/prop-brake") > 0)
					or (getprop("/aircraft/prop-brake-fail") == 1)){
				
				setprop("/aircraft/ccas/prop-brake-fault", 1);
				if (lastPropBrakeStatus != 1) {
					setprop("/aircraft/ccas/master-warning", totalCurrentMasterWarn + 1);
					setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings + 1);
					}
				}
			else {
				setprop("/aircraft/ccas/prop-brake-fault", 0);
				if (lastPropBrakeStatus != 0) {
					if (totalCurrentMasterWarn > 0) {
						setprop("/aircraft/ccas/master-warning", totalCurrentMasterWarn - 1);
						}
					if (totalCurrentActiveWarnings > 0) {
						setprop("/aircraft/ccas/sound/warning", totalCurrentActiveWarnings - 1);
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
					setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution + 1);
					setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions + 1);
					}				
				}
			else {
				setprop("/aircraft/ccas/fuel-fault", 0);
				if (lastFuelStatus != 0) {
					if (totalCurrentMasterCaution > 0) {
						setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution - 1);
						}
					if (totalCurrentActiveCautions > 0) {
						setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions - 1);
						}
					}					
				}
#-- end FUEL --#	
#-- IDLE GATE --#
			var lastIdleGateStatus = getprop("/aircraft/ccas/idle-gate-fault");

			if (getprop("/controls/atr72/idle-gate") != 1) {
				setprop("/aircraft/ccas/idle-gate-fault", 1);
				if (lastIdleGateStatus != 1) {
					setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution + 1);
					setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions + 1);
					}				
				}
			else {
				setprop("/aircraft/ccas/idle-gate-fault", 0);
				if (lastIdleGateStatus != 0) {
					if (totalCurrentMasterCaution > 0) {
						setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution - 1);
						}
					if (totalCurrentActiveCautions > 0) {
						setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions - 1);
						}
					}					
				}
#-- end IDLE GATE --#		
#-- WHEELS --#
			var lastWheelsStatus = getprop("/aircraft/ccas/wheels-fault");
			
			if (getprop("/gear/brake-thermal-energy") >= 1) {
				setprop("/aircraft/ccas/wheels-fault", 1);
				if (lastWheelsStatus != 1) {
					setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution + 1);
					setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions + 1);
					}				
				}
			else {
				setprop("/aircraft/ccas/wheels-fault", 0);
				if (lastWheelsStatus != 0) {
					if (totalCurrentMasterCaution > 0) {
						setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution - 1);
						}
					if (totalCurrentActiveCautions > 0) {
						setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions - 1);
						}
					}					
				}
#-- end WHEELS --#	
#-- FLAPS UNLK --#
			var lastFlapsUnlockStatus = getprop("/aircraft/ccas/flaps-unlk-fault");
			var flapPosNorm = getprop("/surface-positions/flap-pos-norm");
			var flapFlightPos = getprop("/controls/flight/flaps");
			if (flapPosNorm == nil) flapPosNorm = 0;
			if (flapFlightPos == nil) flapFlightPos = 0;
			
			if ((flapFlightPos == 0.428) and 
					(flapPosNorm < 0.314 or 
					 flapPosNorm > 0.542)) {
				setprop("/aircraft/ccas/flaps-unlk-fault", 1);
				if (lastFlapsUnlockStatus != 1) {
					setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution + 1);
					setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions + 1);
					}				
				}
			elsif ((flapFlightPos == 0.714) and 
					(flapPosNorm < 0.600 or 
					 flapPosNorm > 0.828)) {
				setprop("/aircraft/ccas/flaps-unlk-fault", 1);
				if (lastFlapsUnlockStatus != 1) {
					setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution + 1);
					setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions + 1);
					}				
				}
			elsif ((flapFlightPos == 1) and 
					(flapPosNorm < 0.886 or 
					 flapPosNorm > 1.114)) {
				setprop("/aircraft/ccas/flaps-unlk-fault", 1);
				if (lastFlapsUnlockStatus != 1) {
					setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution + 1);
					setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions + 1);
					}				
				}	
			else {
				setprop("/aircraft/ccas/flaps-unlk-fault", 0);
				if (lastFlapsUnlockStatus != 0) {
					if (totalCurrentMasterCaution > 0) {
						setprop("/aircraft/ccas/master-caution", totalCurrentMasterCaution - 1);
						}
					if (totalCurrentActiveCautions > 0) {
						setprop("/aircraft/ccas/sound/caution", totalCurrentActiveCautions - 1);
						}
					}					
				}
#-- end FLAPS UNLK --#	

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