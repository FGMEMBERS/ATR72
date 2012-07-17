########################### ATR72 Electrical System ############################
##################### Modeled by Narendran Muraleedharan #######################

# Electrical Classes

## Electrical Power Suppliers

var supplier = {

	name: "",
	type: "",
	volts: 0,
	amps: 0,
	dep: 0,
	dep_prop: "",
	dep_max: 0,
	dep_req: 0,
	sw_prop: "",
	supply: func() {
	
		var amps = 0;
	
		if (getprop(me.sw_prop) != 0) {
	
			if (me.dep == 1) {
		
				var dep_val = getprop(me.dep_prop);
			
				if (dep_val > me.dep_req) {
			
					amps = (dep_val / me.dep_max) * me.amps;
			
				} 
		
			} else {
		
				amps = me.amps;
		
			}
			
		}
		
		return amps;
	
	},
	new: func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) {
	
		var t = {parents:[supplier]};
		
		t.name = arg1;
		t.type = arg2;
		t.volts = arg3;
		t.amps = arg4;
		t.dep = arg5;
		t.dep_prop = arg6;
		t.dep_max = arg7;
		t.dep_req = arg8;
		t.sw_prop = arg9;
		
		return t;
	
	}

};

## Electrical Buses

var bus = {

	name: "",
	type: "",
	suppliers: [],
	get_volts: func() {
	
		var volts = 0;
	
		foreach(var bus_supplier; me.suppliers) {
		
			foreach(var supplier; atr_suppliers) {
			
				if (bus_supplier == supplier.name) {
				
					if(supplier.supply() != 0) {
					
						if (supplier.volts > volts) {
						
							volts = supplier.volts;
						
						}
					
					}
				
				}
			
			}
		
		}
		
		return volts;
	
	},
	get_amps: func() {
	
		var amps = 0;
	
		foreach(var bus_supplier; me.suppliers) {
		
			foreach(var supplier; atr_suppliers) {
			
				if (bus_supplier == supplier.name) {
				
					amps += supplier.supply();
				
				}
			
			}
		
		}
		
		return amps;
	
	},
	new: func(arg1, arg2, arg3) {
	
		var t = {parents:[bus]};
		
		t.name = arg1;
		t.type = arg2;
		t.suppliers = arg3;
		
		return t;
	
	}

};

## Electrical Outputs

var output = {

	name: "",
	min_volt: "",
	run_amps: 0,
	bus: [],
	serviceable: func() {
	
		var serviceable = 0;
	
		foreach(var out_bus; me.bus) {
	
			foreach(var bus; atr_buses) {
		
				if (out_bus == bus.name) {
			
					if ((bus.get_volts() > me.min_volt) and (bus.get_amps() > me.run_amps)) {
				
						serviceable = 1;
				
					}
			
				}
		
			}
			
		}
		
		if (serviceable == 1) {
		
			setprop("/systems/electric/outputs/" ~ me.name, 1);
		
		} else {
		
			setprop("/systems/electric/outputs/" ~ me.name, 0);
		
		}
	
	},
	new: func(arg1, arg2, arg3, arg4) {
	
		var t = {parents:[output]};
		
		t.name = arg1;
		t.min_volt = arg2;
		t.run_amps = arg3;
		t.bus = arg4;
		
		return t;
	
	}

};

# Initialize Empty Vectors

var atr_suppliers = [];
var atr_buses = [];
var atr_outputs = [];

# Main Electrical Loop

var electrical = {
       init : func {
            me.UPDATE_INTERVAL = 1;
            me.loopid = 0;
            
			# Create Electrical Systems (using suppliers, buses and outputs)
			
			# Create Suppliers
			
			atr_suppliers = [supplier.new("eng1-gen", "AC", 115, 400, 1, "/engines/engine/thruster/prop_rpm", 1400, 350, "/controls/elec_panel/gen1"), supplier.new("eng1-DCgen", "DC", 28, 200, 1, "/engines/engine/thruster/prop_rpm", 1400, 350, "/controls/elec_panel/DCgen1"), supplier.new("eng2-gen", "AC", 115, 400, 1, "/engines/engine[1]/thruster/prop_rpm", 1400, 350, "/controls/elec_panel/gen2"), supplier.new("eng2-DCgen", "DC", 28, 200, 1, "/engines/engine[1]/thruster/prop_rpm", 1400, 350, "/controls/elec_panel/DCgen2"), supplier.new("ext-pwr", "DC", 28, 600, 0, "", 0, 0, "/controls/elec_panel/ext-pwr"), supplier.new("batt-main", "DC", 24, 43, 0, "", 0, 0, "/controls/elec_panel/batt-main"), supplier.new("batt-emer", "DC", 24, 15, 0, "", 0, 0, "/controls/elec_panel/batt-emer")];
			
			atr_buses = [bus.new("dc-bus1", "DC", ["eng1-DCgen"]), bus.new("ac-bus1", "AC", ["eng1-gen"]), bus.new("dc-bus2", "DC", ["eng2-DCgen"]), bus.new("ac-bus2", "AC", ["eng2-gen"]), bus.new("hot-main-bat-bus", "DC", ["batt-main"]), bus.new("hot-emer-bat-bus", "DC", ["batt-emer"])]; # 2 AC Generators also exist but are not being used currently, I'll probably put them in later.
			
			atr_outputs = [output.new("avionics", 12, 1, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "hot-emer-bat-bus"]), output.new("comm", 12, 1, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "hot-emer-bat-bus"]), output.new("fuel-pump1", 28, 20, ["dc-bus1"]), output.new("fuel-pump2", 28, 20, ["dc-bus2"]), output.new("anti-icing", 24, 2, ["dc-bus1", "dc-bus2", "hot-main-bat-bus"]), output.new("lights", 24, 12, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "util-bus-cont"]), output.new("nav", 16, 2, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "hot-emer-bat-bus"]), output.new("pneu", 24, 12, ["dc-bus1", "hot-main-bat-bus", "hot-emer-bat-bus"]), output.new("hydraulic-blue", 24, 12, ["ac-bus1"]), output.new("hydraulic-aux", 24, 8, ["dc-bus1"]), output.new("hydraulic-green", 24, 12, ["ac-bus2", "hot-main-bat-bus", "hot-main-emer-bus"])];
            
            setprop("/systems/electric/util-volts", 0);
            
            me.reset();
    },
    	update : func {
    	
    	# Tie Objects to Properties
    	
    	foreach(var supply; atr_suppliers) {
    	
    		var amps = supply.supply();
    		var volts = 0;
    		
    		if (amps != 0) {
    		
    			volts = supply.volts;
    		
    		}
    		
    		setprop("/systems/electric/suppliers/" ~ supply.name ~ "/volts", volts);
    		setprop("/systems/electric/suppliers/" ~ supply.name ~ "/amps", amps);
    	
    	}
    	
    	foreach(var bus; atr_buses) {
    	
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/volts", bus.get_volts());
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/amps", bus.get_amps());
    	
    	}

    	foreach(var output; atr_outputs) {
    	
    		output.serviceable();
    	
    	}
    	
    	# Communication and Navigation Systems
    	
    	if (getprop("/systems/electric/outputs/comm") == 1) {
    	
    		setprop("/instrumentation/comm/serviceable", 1);
    		setprop("/instrumentation/comm[1]/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/comm/serviceable", 0);
    		setprop("/instrumentation/comm[1]/serviceable", 0);
    	
    	}
    	
    	if (getprop("/systems/electric/outputs/nav") == 1) {
    	
    		setprop("/instrumentation/nav/serviceable", 1);
    		setprop("/instrumentation/nav[1]/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/nav/serviceable", 0);
    		setprop("/instrumentation/nav[1]/serviceable", 0);
    	
    	}
    	
    	if (getprop("/systems/elec_panel/util-bus")) {
    	
    		var volts = 0;
    	
    		if (getprop("/controls/elec_panel/ext-pwr") and (getprop("velocities/groundspeed-kt") < 10)) {
    		
    			volts = 24;
    		
    		}
    		
    		setprop("/systems/electric/util-volts", volts);
    	
    	}
    	
    	# The rest of the individual pump/equipment serviceability is managed in the individual system files.

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
 electrical.init();
 });
