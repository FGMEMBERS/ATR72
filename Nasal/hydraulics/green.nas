var hyd_green = {

	elec_pump : func(rbus) {
	
		if (rbus >= 100) {
		
			var out_basic = rbus * 15;
		
			if (out_basic > 3000)
				hydraulics.green_psi = 3000; # Filter
			else
				hydraulics.green_psi = out_basic;
				
		} else {
		
			hydraulics.green_psi = 0;
		
		}
	
	},
	
	high_priority_outputs : ["gear/serviceable"],
	
	power_outputs : func {
	
		if (hydraulics.green_psi >= 1200) {
		
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
