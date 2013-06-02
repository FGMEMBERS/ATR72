round = func(val, dec) {

	var integer = int(val);

	var decimal = val - integer;

	var decimal_rounded = int(decimal*(math.pow(10, dec)));

	return integer~"."~decimal_rounded;

};

fmcPages["perfinit"] = {

	initDisplay: func() {

		title.setText("PERF INIT").setColor(blue);
		pageNo.setText("1/2").setColor(blue);
		
		labels[0].setText("GR WT").setColor(blue);
		labels[1].setText("FUEL").setColor(blue);
		labels[2].setText("ZFW").setColor(blue);
		labels[3].setText("RESERVES").setColor(blue);
		labels[4].setText("TRANS ALT").setColor(blue);
		labels[5].setText("-------------------------------------------------------").setColor(blue);
		
		labels[12].setText("CRZ ALT").setColor(blue);
		labels[13].setText("CLIMB").setColor(blue);
		labels[14].setText("CRUISE").setColor(blue);
		labels[15].setText("DESCENT").setColor(blue);
		labels[16].setText("SPD TRANS").setColor(blue);
		
		var grwt = getprop("/aircraft/fmc/perf/grwt");
		if (grwt != nil) {
			values[0].setText(round(grwt, 1)).setColor(white);
		}
		else {
			values[0].setText("--.-").setColor(white);
		}
	
		var fuel = getprop("/aircraft/fmc/perf/fuel");
		if (fuel != nil) {
			values[1].setText(round(fuel, 1)).setColor(white);
		}
		else {
			values[1].setText("--.- CALC").setColor(white);
		}
		
		values[2].setText("28.5").setColor(white);
		
		if (getprop("/aircraft/fmc/perf/rsv") != nil)
			values[3].setText(getprop("/aircraft/fmc/perf/rsv")).setColor(white);
		else
			values[3].setText("--.-").setColor(white);
			
		values[4].setText(getprop("/aircraft/fmc/perf/trans-alt")).setColor(white);
		
		values[12].setText(getprop("/aircraft/fmc/perf/crz-alt")).setColor(white);
		values[13].setText(getprop("/aircraft/fmc/perf/climb")).setColor(white).setFontSize(40, 1.2);
		values[14].setText(getprop("/aircraft/fmc/perf/cruise")).setColor(white).setFontSize(40, 1.2);
		values[15].setText(getprop("/aircraft/fmc/perf/descent")).setColor(white).setFontSize(40, 1.2);
		values[16].setText(getprop("/aircraft/fmc/perf/spd-trans")).setColor(white).setFontSize(40, 1.2);
		
	},
	
	l1: func() {
	
		setprop("/aircraft/fmc/perf/grwt", (int(getprop("/fdm/jsbsim/inertia/weight-lbs")/10)/100));
		values[0].setText(round(getprop("/aircraft/fmc/perf/grwt"), 1)).setColor(white);
	
	},
	
	l2: func() {
	
		setprop("/aircraft/fmc/perf/fuel", (int(getprop("/consumables/fuel/total-fuel-lbs")/10)/100));
		values[1].setText(round(getprop("/aircraft/fmc/perf/fuel"),1)).setColor(white);
	
	},
	
	l4: func() {
	
		var input = getprop(fmc~ "input");
	
		if (input != nil) {
			setprop("/aircraft/fmc/perf/rsv", input);
			values[3].setText(input).setColor(white);
			clearInput();
		} else
			setprop(fmc~ "input", "ERROR: WRONG FORMAT");
	
	},
	
	l5: func() {
	
		var input = getprop(fmc~ "input");
		
		setprop("/aircraft/fmc/perf/trans-alt", input);
		
		values[4].setText(input).setColor(white);
		
		clearInput();
	
	},
	
	r1: func() {
	
		var input = getprop(fmc~ "input");
		
		setprop("/aircraft/fmc/perf/crz-alt", input);
		
		values[12].setText(input).setColor(white);
		
		values[5].setText("< ERASE").setColor(green);
		
		setprop(fmc~ "exec-lt", 1);
		
		clearInput();
	
	},
	
	r2: func() {
	
		var input = getprop(fmc~ "input");
		
		setprop("/aircraft/fmc/perf/climb", input);
		
		values[13].setText(input).setColor(white);
		
		clearInput();
	
	},
	
	r3: func() {
	
		var input = getprop(fmc~ "input");
		
		setprop("/aircraft/fmc/perf/cruise", input);
		
		values[14].setText(input).setColor(white);
		
		clearInput();
	
	},
	
	r4: func() {
	
		var input = getprop(fmc~ "input");
		
		setprop("/aircraft/fmc/perf/descent", input);
		
		values[15].setText(input).setColor(white);
		
		clearInput();
	
	},
	
	r5: func() {
	
		var input = getprop(fmc~ "input");
		
		setprop("/aircraft/fmc/perf/spd-trans", input);
		
		values[16].setText(input).setColor(white);
		
		clearInput();
	
	},
	
	l6: func() {
	
		setprop("/aircraft/fmc/perf/crz-alt", "FL160");
		
		values[5].setText("").setColor(white);
		
		values[12].setText("FL160").setColor(white);
		
		setprop(fmc~ "exec-lt", 0);
	
	},
	
	exec: func() {
	
		setprop("/aircraft/afcs/crz-alt", getprop("/aircraft/fmc/perf/crz-alt"));
	
		values[5].setText("").setColor(white);
		
		setprop(fmc~ "exec-lt", 0);
	
	},

	next: func() {
	
		GoToPage("descent");
	
	}

};

fmcPages["descent"] = {

	initDisplay: func() {

		title.setText("DESCENT").setColor(blue);
		pageNo.setText("2/2").setColor(blue);
		
		labels[1].setText("AT TOD").setColor(magenta);
		labels[3].setText("E/" ~ getprop("/autopilot/route-manager/destination/airport")).setColor(white);
		labels[4].setText("FIX/ALT").setColor(blue);
		labels[5].setText("-------------------------------------------------------").setColor(blue);
		
		labels[6].setText("VTK ERR").setColor(blue);
		
		labels[12].setText("VS").setColor(blue);
		labels[13].setText("DTG   VS REQ").setColor(blue);
		labels[14].setText("").setColor(blue);
		labels[15].setText("FPA   VB").setColor(blue);
		
		values[1].setText(getprop("/aircraft/afcs/crz-alt")).setColor(magenta);
		values[2].setText(getprop("/aircraft/afcs/crz-alt")).setColor(white);
		values[3].setText("---- FT").setColor(white);
		
		var fl = substr(getprop("/aircraft/afcs/crz-alt"), 2, 3);
		
		var descent = split("/", getprop("/aircraft/fmc/perf/descent"));
		
		var desc_ias = descent[0];
		
		var desc_tas = desc_ias + (fl/4); # (Actual formula: TAS = IAS + FL/2, but we want to assume half the FL as average)
		
		var desc_time_hr = (fl * 100) / 72000;
		
		var tod = int(desc_time_hr * desc_tas);
		
		values[12].setText("00").setColor(white);
		values[13].setText(tod ~ " NM  -1200").setColor(magenta);
		
		var rte_num = getprop("/autopilot/route-manager/route/num");
		
		if (rte_num > 2) {
		
			var last_wp = rte_num - 2;
			
			var dist = 0;
			
			var last_wp_id = "-----";
			var req_vs = "+0000";
			
			var exit = 0;
			
			for(var n=last_wp; exit != 1; n-=1) {
			
				if (n == 1) {
				
					exit = 1;
				
				}
			
				dist += getprop("/autopilot/route-manager/route/wp[" ~ n ~ "]/leg-distance-nm");
				
				if (dist > tod) {
				
					last_wp_id = getprop("/autopilot/route-manager/route/wp[" ~ n ~ "]/id");
					
					var desc_time_hr = dist / desc_tas;
					
					var vs = (fl * 100) / (desc_time_hr * 60); # 60 is the hr -> min conv factor and 100 is the fl to alt conv factor
					
					req_vs = int(vs / 100) ~ "00";
					
					exit = 1;
				
				}
			
			}
			
			labels[2].setText("AT " ~ last_wp_id).setColor(white);
			values[14].setText(int(dist) ~ " NM  -" ~ req_vs).setColor(white);
		
		} else {
		
			labels[2].setText("AT -----").setColor(white);
			values[14].setText("--- NM  +0000").setColor(white);
		
		}
		
	},
	
	prev: func() {
	
		GoToPage("perfinit");
	
	}

};
