var hydraulics = {

	blue_psi: 0,
	green_psi: 0,

	xfeed_apply : func {
		
		var avg_psi = (me.green_psi + me.blue_psi) / 2;
		
		if (math.abs(me.green_psi - me.blue_psi) >= 500) {
		
			me.green_psi = avg_psi;
			
			me.blue_psi = avg_psi;
		
		}
	
	},
	
	update_props : func {
	
		setprop("systems/hydraulic/green-pressure-psi", me.green_psi);
		setprop("systems/hydraulic/blue-pressure-psi", me.blue_psi);
	
	}
	
	# Other functions are hydraulic system specific (green/blue)

};
