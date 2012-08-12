var ccas = {
	
	
	init : func {
			me.loopInterval = 0.1;
			setprop("/aircraft/ccas/sound/warning",0);
			me.totalCurrentActiveWarnings = 0;
			setprop("/aircraft/ccas/sound/caution",0);
			me.totalCurrentActiveCautions = 0;
			setprop("/aircraft/ccas/master-warning-count",0);
			me.totalCurrentMasterWarn = 0;
			setprop("/aircraft/ccas/master-caution-count",0);
			me.totalCurrentMasterCaution = 0;
			
			me.engine1StartTime = nil;
			
			me.update();
			},
	
	update : func {
	
			## this needs to exit immediately if power isn't available in the aircraft
			
			## when power is available do the following
			me.totalCurrentMasterWarn = getprop("/aircraft/ccas/master-warning-count");	
			me.totalCurrentMasterCaution = getprop("/aircraft/ccas/master-caution-count");	
			me.totalCurrentActiveWarnings = getprop("/aircraft/ccas/sound/warning");	
			me.totalCurrentActiveCautions = getprop("/aircraft/ccas/sound/caution");	
			
			me.ldg_gear_not_down();
			me.prop_brk();
			me.fuel();
			me.idle_gate();
			me.wheels();
			me.flaps_unlk();
			me.oil_pressure_eng(0);
			me.oil_pressure_eng(1);

			if (getprop("/aircraft/ccas/master-warning-count") > 0) {
				setprop("/aircraft/ccas/master-warning", 1);
			}
			else {
				setprop("/aircraft/ccas/master-warning", 0);
			}
			
			if (getprop("/aircraft/ccas/master-caution-count") > 0) {
				setprop("/aircraft/ccas/master-caution", 1);
			}
			else {
				setprop("/aircraft/ccas/master-caution", 0);
			}
			
			settimer(func {me.update();}, me.loopInterval);
			},
			
	oil_pressure_eng : func(engineNumber) {
			##must be suppressed for first 30s after engine start
			if (me.engine1StartTime == nil) return;
						
			if ((systime() - me.engine1StartTime) > 30) {
				var propertyName = "/aircraft/ccas/oil-pressure-eng" ~ engineNumber;
				var lastOilPressStatus = getprop(propertyName);
				if (getprop("/engines/engine[" ~ engineNumber ~ "]/oil-pressure-psi-adjusted") < 40) {
					me.add_warning(propertyName, lastOilPressStatus);
					}
				else {
					me.remove_warning(propertyName, lastOilPressStatus);
					}
				}
			},
			
	flaps_unlk : func {
			var propertyName = "/aircraft/ccas/flaps-unlk-fault";
			var lastFlapsUnlockStatus = getprop(propertyName);
			var flapPosNorm = getprop("/surface-positions/flap-pos-norm");
			var flapFlightPos = getprop("/controls/flight/flaps");
			if (flapPosNorm == nil) flapPosNorm = 0;
			if (flapFlightPos == nil) flapFlightPos = 0;
			
			if ((flapFlightPos == 0.428) and 
					(flapPosNorm < 0.314 or 
					 flapPosNorm > 0.542)) {
				me.add_caution(propertyName, lastFlapsUnlockStatus);
				}
			elsif ((flapFlightPos == 0.714) and 
					(flapPosNorm < 0.600 or 
					 flapPosNorm > 0.828)) {
				me.add_caution(propertyName, lastFlapsUnlockStatus);
				}
			elsif ((flapFlightPos == 1) and 
					(flapPosNorm < 0.886 or 
					 flapPosNorm > 1.114)) {
				me.add_caution(propertyName, lastFlapsUnlockStatus);
				}	
			else {
				me.remove_caution(propertyName, lastFlapsUnlockStatus);
				}	
			},
			
	wheels : func {
			var propertyName = "/aircraft/ccas/wheels-fault";
			var lastWheelsStatus = getprop(propertyName);
			
			if (getprop("/gear/brake-thermal-energy") >= 1) {
				me.add_caution(propertyName, lastWheelsStatus);
				}
			else {
				me.remove_caution(propertyName, lastWheelsStatus);
				}
			},
			
	idle_gate : func {
			var propertyName = "/aircraft/ccas/idle-gate-fault";
			var lastIdleGateStatus = getprop(propertyName);
			
			if (getprop("/aircraft/idle-gate") != 1) {
				me.add_caution(propertyName, lastIdleGateStatus);
				}
			else {
				me.remove_caution(propertyName, lastIdleGateStatus);					
				}	
			},
			
	fuel : func {
			var propertyName = "/aircraft/ccas/fuel-fault";
			var lastFuelStatus = getprop(propertyName);
			
			#also needs to check for fuel flow psi < 4 in line below
			if (getprop("/consumables/fuel/total-fuel-kg") < 160) {
				me.add_caution(propertyName, lastFuelStatus);
				}
			else {
				me.remove_caution(propertyName, lastFuelStatus);					
				}
			},
			
	prop_brk : func {
			var propertyName = "/aircraft/ccas/prop-brake-fault";
			var lastPropBrakeStatus = getprop(propertyName);

			if ((getprop("/aircraft/prop-brake") == 1) or (getprop("/aircraft/prop-brake-fail") == 1)){
				me.add_warning(propertyName, lastPropBrakeStatus);
				}
			else {
				me.remove_warning(propertyName, lastPropBrakeStatus);
				}
			},
			
	ldg_gear_not_down : func {
			var propertyName = "/aircraft/ccas/ldg_gear_not_down";
			var lastGearWarningStatus = getprop(propertyName);
			if ((getprop("/surface-positions/flap-pos-norm") == 1) 
					and (me.all_gear_down() == 0) 
					and (getprop("/position/altitude-agl-ft") <= 500)) {
				me.add_warning(propertyName, lastGearWarningStatus);
				}
			else {
				me.remove_warning(propertyName, lastGearWarningStatus);
				}
			},
			
	add_caution : func(propertyName = "", propertyLastStatus = 0) {
			setprop(propertyName, 1);
			if (propertyLastStatus != 1) {
				
				me.totalCurrentMasterCaution = me.totalCurrentMasterCaution + 1;
				setprop("/aircraft/ccas/master-caution-count", me.totalCurrentMasterCaution);
				
				me.totalCurrentActiveCautions = me.totalCurrentActiveCautions + 1;
				setprop("/aircraft/ccas/sound/caution", me.totalCurrentActiveCautions);			
				}
			},
			
	remove_caution : func(propertyName = "", propertyLastStatus=0) {
			setprop(propertyName, 0);
			if (propertyLastStatus != 0) {
				if (me.totalCurrentMasterCaution > 0) {
					me.totalCurrentMasterCaution = me.totalCurrentMasterCaution - 1;
					setprop("/aircraft/ccas/master-caution-count", me.totalCurrentMasterCaution);
					}
				if (me.totalCurrentActiveCautions > 0) {
					me.totalCurrentActiveCautions = me.totalCurrentActiveCautions - 1;
					setprop("/aircraft/ccas/sound/caution", me.totalCurrentActiveCautions);
					}
				}
			},
			
	add_warning : func (propertyName="", propertyLastStatus=0) {
			setprop(propertyName, 1);
			if (propertyLastStatus != 1) {
				
				me.totalCurrentMasterWarn = me.totalCurrentMasterWarn + 1;
				setprop("/aircraft/ccas/master-warning-count", me.totalCurrentMasterWarn);
				
				me.totalCurrentActiveWarnings = me.totalCurrentActiveWarnings + 1;
				setprop("/aircraft/ccas/sound/warning", me.totalCurrentActiveWarnings);			
				}
			},
			
	remove_warning : func (propertyName="", propertyLastStatus=0) {
			setprop(propertyName, 0);
			if (propertyLastStatus != 0) {
				if (me.totalCurrentMasterWarn > 0) {
					me.totalCurrentMasterWarn = me.totalCurrentMasterWarn - 1;
					setprop("/aircraft/ccas/master-warning-count", me.totalCurrentMasterWarn);
					}
				if (me.totalCurrentActiveWarnings > 0) {
					me.totalCurrentActiveWarnings = me.totalCurrentActiveWarnings - 1;
					setprop("/aircraft/ccas/sound/warning", me.totalCurrentActiveWarnings);
					}
				}				
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
	engine1started : func {
			var engineRunningProperty = "/engines/engine[0]/running";
			if (getprop(engineRunningProperty) == 1) {
				if (me.engine1StartTime == nil) {
					me.engine1StartTime = systime();
					}
				}
			if (getprop(engineRunningProperty) == 0) {
				me.engine1StartTime = nil;
				}
			},
};
setlistener("/engines/engine[0]/running", func {ccas.engine1started();});
setlistener("/sim/signals/fdm-initialized", func{ccas.init();});
