var hyd_blue = {

	elec_pump : func(lbus) {
	
		if (lbus >= 100) {
		
			var out_basic = lbus * 15;
		
			if (out_basic > 3000)
				hydraulics.blue_psi = 3000; # Filter
			else
				hydraulics.blue_psi = out_basic;
				
		} else {
		
			hydraulics.blue_psi = 0;
		
		}
	
	},
	
	aux_pump : func(bus) {
	
		if (bus >= 12) {
		
			var out_basic = bus * 125;
		
			if (hydraulics.blue_psi + out_basic > 3000)
				hydraulics.blue_psi = 3000; # Filter
			else
				hydraulics.blue_psi += out_basic;
				
		}
	
	},
	
	high_priority_outputs : ["/sim/failure-manager/controls/flight/rudder/serviceable", "/sim/failure-manager/controls/flight/flaps/serviceable"],
	
	power_outputs : func {
	
		if (hydraulics.blue_psi >= 1000) {
		
			foreach(var hp_output; me.high_priority_outputs) {
			
				setprop(hp_output, 1);
			
			}
		
		} else {
		
			foreach(var hp_output; me.high_priority_outputs) {
			
				setprop(hp_output, 0);
			
			}
		
		}
	
	}

};
