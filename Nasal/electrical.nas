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
	new: func(name, type, volts, amps, dep, dep_prop, dep_max, dep_req, sw_prop) {
	
		var t = {parents:[supplier]};
		
		t.name = name;
		t.type = type;
		t.volts = volts;
		t.amps = amps;
		t.dep = dep;
		t.dep_prop = dep_prop;
		t.dep_max = dep_max;
		t.dep_req = dep_req;
		t.sw_prop = sw_prop;
		
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
	new: func(name, type, suppliers) {
	
		var t = {parents:[bus]};
		
		t.name = name;
		t.type = type;
		t.suppliers = suppliers;
		
		return t;
	
	}

};

## Electrical Outputs

var output = {

	name: "",
	min_volt: "",
	run_amps: 0,
	bus: [],
	serviceableVolts: 0,
	serviceable: func() {
	
		var serviceable = 0;
	
		foreach(var out_bus; me.bus) {
	
			foreach(var bus; atr_buses) {
		
				if (out_bus == bus.name) {
			
					if ((bus.get_volts() >= me.min_volt) and (bus.get_amps() >= me.run_amps)) {
				
						serviceable = 1;
						
						if (me.serviceableVolts < bus.get_volts())
						{
							me.serviceableVolts = bus.get_volts();
						}
					}
			
				}
		
			}
		
			if ((out_bus == "util-bus") and (getprop("/controls/elec_panel/ext-pwr")) and (getprop("/controls/elec_panel/util-bus"))) {
			
				serviceable = 1;
			
			}
			
		}
		
		if (serviceable == 1) {
		
			setprop("/systems/electric/outputs/" ~ me.name, 1);
			setprop("/systems/electrical/outputs/" ~ me.name, me.serviceableVolts);
		
		} else {
		
			setprop("/systems/electric/outputs/" ~ me.name, 0);
			setprop("/systems/electrical/outputs/" ~ me.name, me.serviceableVolts);		
		}
	
	},
	new: func(name, min_volt, run_amps, bus) {
	
		var t = {parents:[output]};
		
		t.name = name;
		t.min_volt = min_volt;
		t.run_amps = run_amps;
		t.bus = bus;
		
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
			
			atr_suppliers = [supplier.new("eng1-gen", "AC", 115, 400, 1, "/engines/engine/thruster/prop_rpm", 1400, 350, "/controls/elec_panel/gen1"), supplier.new("eng1-DCgen", "DC", 28, 200, 1, "/engines/engine/n1", 100, 20, "/controls/elec_panel/DCgen1"), supplier.new("eng2-gen", "AC", 115, 400, 1, "/engines/engine[1]/thruster/prop_rpm", 1400, 350, "/controls/elec_panel/gen2"), supplier.new("eng2-DCgen", "DC", 28, 200, 1, "/engines/engine[1]/n1", 100, 20, "/controls/elec_panel/DCgen2"), supplier.new("ext-pwr", "DC", 28, 600, 0, "", 0, 0, "/controls/elec_panel/ext-pwr"), supplier.new("batt-main", "DC", 24, 43, 0, "", 0, 0, "/controls/elec_panel/batt-main"), supplier.new("batt-emer", "DC", 24, 15, 0, "", 0, 0, "/controls/elec_panel/batt-emer")];
			
			atr_buses = [bus.new("dc-bus1", "DC", ["eng1-DCgen"]), bus.new("ac-bus1", "AC", ["eng1-gen"]), bus.new("dc-bus2", "DC", ["eng2-DCgen"]), bus.new("ac-bus2", "AC", ["eng2-gen"]), bus.new("hot-main-bat-bus", "DC", ["batt-main"]), bus.new("hot-emer-bat-bus", "DC", ["batt-emer"])]; # 2 AC Generators also exist but are not being used currently, I'll probably put them in later.
			
			atr_outputs = [
				output.new("avionics", 12, 1, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "hot-emer-bat-bus", "util-bus"]), 
				output.new("comm", 12, 1, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "hot-emer-bat-bus"]), 
				output.new("fuel-pump1", 28, 20, ["dc-bus1", "util-bus"]), 
				output.new("fuel-pump2", 28, 20, ["dc-bus2", "util-bus"]), 
				output.new("anti-icing", 24, 2, ["dc-bus1", "dc-bus2", "hot-main-bat-bus"]), 
				output.new("lights", 24, 12, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "util-bus"]), 
				output.new("nav", 16, 2, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "hot-emer-bat-bus"]), 
				output.new("pneu", 24, 12, ["dc-bus1", "hot-main-bat-bus", "hot-emer-bat-bus"]), 
				output.new("hydraulic-blue", 24, 12, ["ac-bus1"]), 
				output.new("hydraulic-aux", 24, 8, ["dc-bus1", "util-bus"]), 
				output.new("hydraulic-green", 24, 12, ["ac-bus2", "hot-main-bat-bus", "hot-main-emer-bus"]),
				output.new("x-feed", 8, 2, ["dc-bus1", "dc-bus2", "util-bus", "hot-emer-bat-bus", "hot-main-bat-bus"]),
				output.new("mk-viii", 28, 1, ["dc-bus1", "dc-bus2", "hot-emer-bat-bus", "hot-main-bat-bus"]),
				output.new("adf", 12, 1, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "hot-emer-bat-bus"]),
				output.new("dme", 12, 1, ["dc-bus1", "dc-bus2", "hot-main-bat-bus", "hot-emer-bat-bus"])
				];
            
            setprop("/systems/electric/util-volts", 0);
            
            setprop("/controls/elec_panel/dc-btc", 0);
            
            setprop("/controls/elec_panel/ac-btc", 0);
            
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
    	
    	if ((getprop("/systems/electric/outputs/comm") == 1) and (getprop("/aircraft/collins/com0-mode") == 1)) {
    	
    		setprop("/instrumentation/comm/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/comm/serviceable", 0);
    	
    	}
    	
    	if ((getprop("/systems/electric/outputs/comm") == 1) and (getprop("/aircraft/collins/com1-mode") == 1)) {
    	
    		setprop("/instrumentation/comm[1]/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/comm[1]/serviceable", 0);
    	
    	}
    	
    	if ((getprop("/systems/electric/outputs/nav") == 1) and (getprop("/aircraft/collins/nav0-mode") == 1)) {
    	
    		setprop("/instrumentation/nav/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/nav/serviceable", 0);
    	
    	}
    	
    	if ((getprop("/systems/electric/outputs/nav") == 1) and (getprop("/aircraft/collins/nav1-mode") == 1)) {
    	
    		setprop("/instrumentation/nav[1]/serviceable", 1);
    	
    	} else {
    	
    		setprop("/instrumentation/nav[1]/serviceable", 0);
    	
    	}
    	
    	if (getprop("/controls/elec_panel/util-bus")) {
    	
    		var volts = 0;
    	
    		if (getprop("/controls/elec_panel/ext-pwr") and (getprop("velocities/groundspeed-kt") < 10)) {
    		
    			volts = 24;
    		
    		}
    		
    		setprop("/systems/electric/util-volts", volts);
    	
    	}
    	
    	if (getprop("/controls/elec_panel/dc-btc")) {
    	
    		var dclbus_v = getprop("/systems/electric/elec-buses/dc-bus1/volts");
    		var dcrbus_v = getprop("/systems/electric/elec-buses/dc-bus2/amps");
    		
    		var dclbus_a = getprop("/systems/electric/elec-buses/dc-bus1/volts");
    		var dcrbus_a = getprop("/systems/electric/elec-buses/dc-bus2/amps");
    		
    		if (dclbus_v > dcrbus_v) {
    			setprop("/systems/electric/elec-buses/dc-bus2/amps", dclbus_v);
    		} else {
    			setprop("/systems/electric/elec-buses/dc-bus1/amps", dcrbus_v);
    		}
    		
    		var total_amps = dclbus_a + dcrbus_a;
    		
    		setprop("/systems/electric/elec-buses/dc-bus1/amps", total_amps/2);
    		setprop("/systems/electric/elec-buses/dc-bus2/amps", total_amps/2);
    	
    	}
    	
    	if (getprop("/controls/elec_panel/ac-btc")) {
    	
    		var aclbus_v = getprop("/systems/electric/elec-buses/ac-bus1/volts");
    		var acrbus_v = getprop("/systems/electric/elec-buses/ac-bus2/amps");
    		
    		var aclbus_a = getprop("/systems/electric/elec-buses/ac-bus1/volts");
    		var acrbus_a = getprop("/systems/electric/elec-buses/ac-bus2/amps");
    		
    		if (aclbus_v > acrbus_v) {
    			setprop("/systems/electric/elec-buses/ac-bus2/amps", aclbus_v);
    		} else {
    			setprop("/systems/electric/elec-buses/ac-bus1/amps", acrbus_v);
    		}
    		
    		var total_amps = aclbus_a + acrbus_a;
    		
    		setprop("/systems/electric/elec-buses/ac-bus1/amps", total_amps/2);
    		setprop("/systems/electric/elec-buses/ac-bus2/amps", total_amps/2);
    	
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
 print("ATR72 Electrical System .... Initialized");
 });
