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
			setprop("/aircraft/ccas/clr-engaged",0);
			me.clrEngaged = 0;			
			setprop("/aircraft/ccas/to-inhi-enabled",0);
			me.toInhib = 0;
			
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
			me.clrEngaged = getprop("/aircraft/ccas/clr-engaged");
			me.toInhib = getprop("/aircraft/ccas/to-inhi-enabled");
			
			##warnings
			me.oil_pressure_eng(0, me.engine1StartTime);
			me.oil_pressure_eng(1, me.engine2StartTime);			
			me.prop_brk();
			me.ldg_gear_not_down();
			me.excess_cabin_pressure();
			me.excess_cabin_altitude();
			
			##cautions
			me.flaps_unlk();
			me.idle_gate();
			me.wheels();
			me.fuel();
			me.hyd();
			
			##other
			me.parking_brake();
			
			me.clear_master();
			
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
		
	clear_master : func {
		if (getprop("/systems/electric/outputs/avionics") == 0) {
			setprop("/aircraft/ccas/master-warning-count", 0);
			setprop("/aircraft/ccas/master-caution-count", 0);
		}
	},
			
	turn_light_off : func(propertyName) {
		if (getprop("/systems/electric/outputs/avionics") == 0){		
			setprop(propertyName,0);
			return 1;
		}		
		return 0;
	},
	
	parking_brake : func {
		var propertyName = "/aircraft/ccas/parking-brake";
		
		if (me.turn_light_off(propertyName)) return;
		
		setprop(propertyName, getprop("/controls/gear/brake-parking"));
	},
	
	oil_pressure_eng : func(engineNumber, engineStartTime) {
			##must be suppressed for first 30s after engine start
			var propertyName = "/aircraft/ccas/warnings/oil-pressure-eng" ~ engineNumber;
			var lastOilPressStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if (engineStartTime == nil) {
				me.remove_warning(propertyName, lastOilPressStatus);
				return;
				}
			
			if (me.toInhib) return;
						
			if ((systime() - engineStartTime) > 30) {		
				if (getprop("/engines/engine[" ~ engineNumber ~ "]/oil-pressure-psi-adjusted") < 40) {
					me.add_warning(propertyName, lastOilPressStatus);
					}
				else {
					me.remove_warning(propertyName, lastOilPressStatus);
					}
				}
			},
			
	flaps_unlk : func {
			var propertyName = "/aircraft/ccas/cautions/flaps-unlk-fault";
			var lastFlapsUnlockStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if (me.clrEngaged == 1 or me.toInhib) {
					me.remove_caution(propertyName, lastFlapsUnlockStatus);
					return;
				}			
			
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
			var propertyName = "/aircraft/ccas/cautions/wheels-fault";
			var lastWheelsStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if (me.clrEngaged == 1 or me.toInhib) {
					me.remove_caution(propertyName, lastWheelsStatus);
					return;
				}
			
			if (getprop("/gear/brake-thermal-energy") >= 1) {
				me.add_caution(propertyName, lastWheelsStatus);
				}
			else {
				me.remove_caution(propertyName, lastWheelsStatus);
				}
			},
			
	hyd : func {
			var propertyName = "/aircraft/ccas/cautions/hyd-fault";
			var lastHydStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if (me.clrEngaged == 1 or me.toInhib) {
					me.remove_caution(propertyName, lastHydStatus);
					return;
				}
			
			var bluePressure = getprop("/systems/hydraulic/blue-pressure-psi");
			if (bluePressure == nil) bluePressure = 0;
			
			var greenPressure = getprop("/systems/hydraulic/green-pressure-psi");
			if (greenPressure == nil) greenPressure = 0;		
			
			if (getprop("/engines/engine[0]/running") and (bluePressure < 1500
					or greenPressure < 1500)) {
				me.add_caution(propertyName, lastHydStatus);
				}
			else {
				me.remove_caution(propertyName, lastHydStatus);					
				}	
			},
			
	idle_gate : func {
			var propertyName = "/aircraft/ccas/cautions/idle-gate-fault";
			var lastIdleGateStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if (me.clrEngaged == 1 or me.toInhib) {
					me.remove_caution(propertyName, lastIdleGateStatus);
					return;
				}			
			
			if (getprop("/aircraft/idle-gate") != 1) {
				me.add_caution(propertyName, lastIdleGateStatus);
				}
			else {
				me.remove_caution(propertyName, lastIdleGateStatus);					
				}	
			},
			
	fuel : func {
			var propertyName = "/aircraft/ccas/cautions/fuel-fault";
			var lastFuelStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if (me.clrEngaged == 1 or me.toInhib) {
					me.remove_caution(propertyName, lastFuelStatus);
					return;
				}			
			
			#also needs to check for fuel flow psi < 4 in line below
			if (getprop("/consumables/fuel/tank/level-kg") <= 160 
						or getprop("/consumables/fuel/tank[1]/level-kg") <= 160) {
				me.add_caution(propertyName, lastFuelStatus);
				}
			else {
				me.remove_caution(propertyName, lastFuelStatus);					
				}
			if (getprop("/consumables/fuel/tank/level-kg") <= 160) {
				setprop("/aircraft/ccas/cautions/fuel-low-left", 1);
				}
			else {
				setprop("/aircraft/ccas/cautions/fuel-low-left", 0);
				}			
			if (getprop("/consumables/fuel/tank[1]/level-kg") <= 160) {
				setprop("/aircraft/ccas/cautions/fuel-low-right", 1);
				}
			else {
				setprop("/aircraft/ccas/cautions/fuel-low-right", 0);
				}			
			},
			
	prop_brk : func {
			var propertyName = "/aircraft/ccas/warnings/prop-brake-fault";
			var lastPropBrakeStatus = getprop(propertyName);

			if (me.turn_light_off(propertyName)) return;
			
			if ((getprop("/aircraft/prop-brake") == 1) or (getprop("/aircraft/prop-brake-fail") == 1)){
				me.add_warning(propertyName, lastPropBrakeStatus);
				}
			else {
				me.remove_warning(propertyName, lastPropBrakeStatus);
				}
			},
			
	ldg_gear_not_down : func {
			var propertyName = "/aircraft/ccas/warnings/ldg_gear_not_down";
			var lastGearWarningStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if ((getprop("/surface-positions/flap-pos-norm") == 1) 
					and (me.all_gear_down() == 0) 
					and (getprop("/position/altitude-agl-ft") <= 500)) {
				me.add_warning(propertyName, lastGearWarningStatus);
				}
			else {
				me.remove_warning(propertyName, lastGearWarningStatus);
				}
			},
		
	excess_cabin_pressure : func {
			var propertyName = "/aircraft/ccas/warnings/excess-cab-press-change-fault";
			var lastPressureStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if (getprop("/instrumentation/pressurization/pressure-difference-psi") >= 6.35) {
				me.add_warning(propertyName, lastPressureStatus);
				}
			else {
				me.remove_warning(propertyName, lastPressureStatus);
				}			
			},
			
	excess_cabin_altitude : func {
			var propertyName = "/aircraft/ccas/warnings/excess-cab-alt-fault";
			var lastAltitudeStatus = getprop(propertyName);
			
			if (me.turn_light_off(propertyName)) return;
			
			if (getprop("/instrumentation/pressurization/cabin-altitude-ft") > 10000) {
				me.add_warning(propertyName, lastAltitudeStatus);
				}
			else {
				me.remove_warning(propertyName, lastAltitudeStatus);
				}			
			},
	
	add_caution : func(propertyName = "", propertyLastStatus = 0) {
			setprop(propertyName, 1);
			if (propertyLastStatus != 1) {
				
				me.totalCurrentMasterCaution += 1;
				setprop("/aircraft/ccas/master-caution-count", me.totalCurrentMasterCaution);
				
				me.totalCurrentActiveCautions += 1;
				setprop("/aircraft/ccas/sound/caution", me.totalCurrentActiveCautions);			
				}
			},
			
	remove_caution : func(propertyName = "", propertyLastStatus=0) {
			setprop(propertyName, 0);
			if (propertyLastStatus != 0) {
				if (me.totalCurrentMasterCaution > 0) {
					me.totalCurrentMasterCaution -= 1;
					setprop("/aircraft/ccas/master-caution-count", me.totalCurrentMasterCaution);
					}
				if (me.totalCurrentActiveCautions > 0) {
					me.totalCurrentActiveCautions -= 1;
					setprop("/aircraft/ccas/sound/caution", me.totalCurrentActiveCautions);
					}
				}
			},
			
	add_warning : func (propertyName="", propertyLastStatus=0) {
			setprop(propertyName, 1);
			if (propertyLastStatus != 1) {
				
				me.totalCurrentMasterWarn += 1;
				setprop("/aircraft/ccas/master-warning-count", me.totalCurrentMasterWarn);
				
				me.totalCurrentActiveWarnings += 1;
				setprop("/aircraft/ccas/sound/warning", me.totalCurrentActiveWarnings);			
				}
			},
			
	remove_warning : func (propertyName="", propertyLastStatus=0) {
			setprop(propertyName, 0);
			if (propertyLastStatus != 0) {
				if (me.totalCurrentMasterWarn > 0) {
					me.totalCurrentMasterWarn -= 1;
					setprop("/aircraft/ccas/master-warning-count", me.totalCurrentMasterWarn);
					}
				if (me.totalCurrentActiveWarnings > 0) {
					me.totalCurrentActiveWarnings -= 1;
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
	engine1changed : func {
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
	engine2changed : func {
			var engineRunningProperty = "/engines/engine[1]/running";
			if (getprop(engineRunningProperty) == 1) {
				if (me.engine2StartTime == nil) {
					me.engine2StartTime = systime();
					}
				}
			if (getprop(engineRunningProperty) == 0) {
				me.engine2StartTime = nil;
				}
			},			
};
setlistener("/engines/engine[0]/running", func {ccas.engine1changed();});
setlistener("/engines/engine[1]/running", func {ccas.engine2changed();});
setlistener("/sim/signals/fdm-initialized", func{ccas.init();});
