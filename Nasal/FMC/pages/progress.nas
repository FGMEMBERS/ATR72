var getFL = func(alt) {

	if ((alt != "-----") and (alt != nil)) {

		if (alt > getprop("/aircraft/fmc/perf/trans-alt")) {

			var fl = int(alt/100);

			return "FL"~fl;

		} else {

			return int(alt)~"FT";

		}

	} else {

		return "-----";

	}

};

round = func(val, dec) {

	var integer = int(val);

	var decimal = val - integer;

	var decimal_rounded = int(decimal*(math.pow(10, dec)));

	return integer~"."~decimal_rounded;

};

getProg = func(wp) {

	var data = gpsSearchAll(wp);

	var dist = round(data[0].dist, 1);

	var fl = substr(getprop("/aircraft/afcs/crz-alt"), 2,3);

	var crz = split("/", getprop("/aircraft/fmc/perf/cruise"));

	var gs = crz[0] + (fl/2);

	var utc_time = getprop("/aircraft/fmc/time/utc");

	var time = int(utc_time + ((dist/gs)*60));

	var returnData = {

		dtg: dist,
		eta: time~"z"

	};

	return returnData;

};

getArpt = func(icao) {

	var arpt = airportinfo(icao);

	var dist = round(getDistance(arpt.lat, arpt.lon), 1);
	
	var fl = substr(getprop("/aircraft/afcs/crz-alt"), 2,3);

	var crz = split("/", getprop("/aircraft/fmc/perf/cruise"));

	var gs = crz[0] + (fl/2);

	var utc_time = getprop("/aircraft/fmc/time/utc");

	var time = int(utc_time + ((dist/gs)*60));

	var returnData = {

		dtg: dist,
		eta: time~"z"

	};

};

fmcPages["progress"] = {

	initDisplay: func() {
	
		title.setText("PROGRESS").setColor(blue);
		
		labels[0].setText("LAST").setColor(blue);
		labels[1].setText("TO").setColor(blue);
		labels[2].setText("NEXT").setColor(blue);
		labels[3].setText("DEST").setColor(blue);
		labels[5].setText("-------------------------------------------------------").setColor(blue);
		labels[6].setText("ETA").setColor(blue);
		labels[7].setText("ALT    ATA").setColor(blue);
		labels[8].setText("DTG    ETA").setColor(blue);
		labels[12].setText("FUEL").setColor(blue);

		values[12].setText(round(getprop("/aircraft/fmc/perf/fuel"),1)).setColor(white);
		values[17].setText("POS REF>").setColor(green);
	
	},

	updateDisplay: func() {
		var num = getprop("/aircraft/fmc/active-rte/num");

		if(num > 1) {

			var last_wp = getprop("/aircraft/fmc/active-rte/wp["~(num-1)~"]/id");
			var last_alt = getprop("/aircraft/fmc/active-rte/wp["~(num-1)~"]/alt");
			var last_info = getProg(last_wp);

			var cur_wp = getprop("/aircraft/fmc/active-rte/current-wp");

			var to = getprop("/aircraft/fmc/active-rte/wp["~cur_wp~"]/id");
			var to_info = getProg(to);

			var next_info = nil;
			
			var next = getprop("/aircraft/fmc/active-rte/wp["~(cur_wp+1)~"]/id");
			if (next != nil) {
				next_info = getProg(next);
			}
			

			var dest = getprop("/aircraft/fmc/rte1/dest-arpt");
			var dest_info = getArpt(dest);

			# LAST
			if ((last_wp != nil) and (last_wp != "-----")) {
			values[0].setText(last_wp).setColor(white).setFontSize(40, 1.2);
			values[6].setText(getFL(last_alt)~"   "~last_info.eta).setColor(white).setFontSize(40, 1.2);
			} else {
				values[0].setText("----").setColor(white);
				values[6].setText("").setColor(white);
			}
			
			# TO
			if ((to != nil) and (to != "-----")) {
			values[1].setText(to).setColor(magenta);
			values[13].setText(to_info.dtg~"  "~to_info.eta~"               ").setColor(magenta);
			} else {
				values[1].setText("----").setColor(magenta);
				values[13].setText("").setColor(white);
			}

			# NEXT
			if ((next != nil) and (next != "-----")) {
			values[2].setText(next).setColor(white);
			values[14].setText(next_info.dtg~"  "~next_info.eta~"               ").setColor(white);
			} else {
				values[2].setText("----").setColor(white);
				values[14].setText("").setColor(white);
			}
			
			# DEST
			if ((dest != nil) and (dest != "----")) {
				values[3].setText(dest).setColor(white);
				values[15].setText(dest_info.dtg~"  "~dest_info.eta~"               ").setColor(white);
			} else {
				values[3].setText("----").setColor(white);
				values[15].setText("").setColor(white);
			}

		}
		
	},
	
	r6: func() {
	
		GoToPage("posref");
	
	}

};
