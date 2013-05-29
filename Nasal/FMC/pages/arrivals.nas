var arrView = {

	first: 0,
	dispSTARs: [],
	dispRWYs: [],
	selectedSTAR: 0,
	loadData: func(icao) {

		me.ArrARPT = procedures.fmsDB.new(icao);

		me.dispRWYs = [];

		# Get a list of all available runways on the departure airport
		
		var arpt = airportinfo(icao);

		var rwy_match = 0;
		
		foreach(var i; keys(arpt.runways)) {
		
			append(me.dispRWYs, arpt.runways[i].id);
			
			if (arpt.runways[i].id == getprop("/aircraft/fmc/rte1/dest-rwy")) rwy_match = 1;
		
		}

		# If arrival runway isn't already selected, select the first option

		if (rwy_match == 0) {

			setprop("/aircraft/fmc/rte1/dest-rwy", me.dispRWYs[0]);

			me.STARsByRWY(0);

		} else {

			# Find selected runway and get the list of STARs for it

			for(var n=0; n<size(me.dispRWYs); n+=1) {

				if (me.dispRWYs[n] == getprop("/aircraft/fmc/rte1/dest-rwy")) me.STARsByRWY(n);

			}

		}

	},
	STARsByRWY: func(id) {

		# Refresh STAR Data

		me.dispSTARs = [];

		me.selectedSTAR = 0;

		setprop("/aircraft/fmc/rte1/dest-rwy", me.dispRWYs[id]);

		me.STARList = me.ArrARPT.getSTARList(me.dispRWYs[id]);

		foreach(var STAR; me.STARList) {

			append(me.dispSTARs, STAR.wp_name);

		}

	},
	selectSTAR: func(id) {

		me.selectedSTAR = id;

	},
	confirmSTAR: func() {

		var STARname = me.STARList[me.selectedSTAR].wp_name;

		var num = size(me.STARList[me.selectedSTAR].wpts);

		for(var n=0; n<num; n+=1) {

			var id = me.STARList[me.selectedSTAR].wpts[n].wp_name;
			var lat = me.STARList[me.selectedSTAR].wpts[n].wp_lat;
			var lon = me.STARList[me.selectedSTAR].wpts[n].wp_lon;
			var alt = me.STARList[me.selectedSTAR].wpts[n].alt_cstr;

			setprop("/aircraft/fmc/rte1/arr/wpts/wp["~n~"]/id", id);
			setprop("/aircraft/fmc/rte1/arr/wpts/wp["~n~"]/lat-deg", lat);
			setprop("/aircraft/fmc/rte1/arr/wpts/wp["~n~"]/lon-deg", lon);
			setprop("/aircraft/fmc/rte1/arr/wpts/wp["~n~"]/alt-res", alt);

		}

		setprop("/aircraft/fmc/rte1/arr/star", STARname);

		setprop("/aircraft/fmc/rte1/arr/wpts/num", num);

		fplnDisp.update();

	}

};

fmcPages["arrivals"] = {

	initDisplay: func() {
	
		title.setText(getprop("/aircraft/fmc/rte1/dest-arpt")~" ARRIVALS").setColor(blue);
		
		var pages = int(size(arrView.dispSTARs)/5) + 1;
		
		if (size(arrView.dispSTARs)/5 > pages) pages += 1;
		
		var cur_page = int(arrView.first/5) + 1;

		pageNo.setText(cur_page~"/"~pages).setColor(blue);
		
		labels[0].setText("STARS").setColor(blue);
		labels[6].setText("RTE1").setColor(blue);
		labels[12].setText("RUNWAYS").setColor(blue);
		labels[5].setText("-------------------------------------------------------").setColor(blue);
		values[5].setText("<INDEX").setColor(green);
		values[17].setText("ROUTE>").setColor(green);

		arrView.loadData(getprop("/aircraft/fmc/rte1/dest-arpt"));

		me.updateDisplay();
		
	},

	updateDisplay: func() {

		var pages = int(size(arrView.dispSTARs)/5) + 1;
		
		if (size(arrView.dispSTARs)/5 > pages) pages += 1;
		
		var cur_page = int(arrView.first/5) + 1;

		pageNo.setText(cur_page~"/"~pages).setColor(blue);

		var num = size(arrView.dispSTARs);

		# DISPLAY STARs

		for(var n=0; n<5; n+=1) {

			var id = arrView.first + n;

			if (id < num) { # STAR EXISTS

				if (arrView.selectedSTAR == id)

					values[n].setText(arrView.dispSTARs[id] ~ " <SEL>").setColor(magenta);

				else

					values[n].setText(arrView.dispSTARs[id]).setColor(white);

			} else { # STAR DOESN'T EXIST

				values[n].setText("").setColor(white);

			}

		}

		# DISPLAY RWYs

		var rwy_num = size(arrView.dispRWYs);

		for(var n=0; n<5; n+=1) {

			var id = arrView.first + n;

			if (rwy_num <= 5) id = n;

			if (id < rwy_num) { # RWY EXISTS

				var dep_rwy = getprop("/aircraft/fmc/rte1/dest-rwy");

				if(dep_rwy == arrView.dispRWYs[id]) {

					values[12 + n].setText("<SEL> "~arrView.dispRWYs[id]).setColor(magenta);

				} else {

					values[12 + n].setText(arrView.dispRWYs[id]).setColor(white);

				}

			} else { # RWY DOESN'T EXIST

				values[12 + n].setText("").setColor(white);

			}

		}

	},

	l1: func() {

		arrView.selectSTAR(arrView.first);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	l2: func() {

		arrView.selectSTAR(arrView.first + 1);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	l3: func() {

		arrView.selectSTAR(arrView.first + 2);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	l4: func() {

		arrView.selectSTAR(arrView.first + 3);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	l5: func() {

		arrView.selectSTAR(arrView.first + 4);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	r1: func() {

		var rwy_num = size(arrView.dispRWYs);

		if (rwy_num <= 5)
			arrView.STARsByRWY(0);
		else
			arrView.STARsByRWY(arrView.first);


		me.updateDisplay();

	},

	r2: func() {

		var rwy_num = size(arrView.dispRWYs);

		if (rwy_num <= 5)
			arrView.STARsByRWY(1);
		else
			arrView.STARsByRWY(arrView.first + 1);


		me.updateDisplay();

	},

	r3: func() {

		var rwy_num = size(arrView.dispRWYs);

		if (rwy_num <= 5)
			arrView.STARsByRWY(2);
		else
			arrView.STARsByRWY(arrView.first + 2);


		me.updateDisplay();

	},

	r4: func() {

		var rwy_num = size(arrView.dispRWYs);

		if (rwy_num <= 5)
			arrView.STARsByRWY(3);
		else
			arrView.STARsByRWY(arrView.first + 3);


		me.updateDisplay();

	},

	r5: func() {

		var rwy_num = size(arrView.dispRWYs);

		if (rwy_num <= 5)
			arrView.STARsByRWY(4);
		else
			arrView.STARsByRWY(arrView.first + 4);


		me.updateDisplay();

	},

	l6: func() {

		GoToPage("deparrindex");

	},

	r6: func() {

		GoToPage("rte1init");

	},

	next: func() {

		if(arrView.first + 5 <= size(arrView.dispSTARs)) {

			arrView.first += 5;
		
		}
		
		me.updateDisplay();

	},

	prev: func() {

		if(arrView.first > 0) {

			arrView.first -= 5;
		
		}
		
		me.updateDisplay();

	},

	exec: func() {

		if (getprop("/instrumentation/fmc/exec-lt") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 0);

			arrView.confirmSTAR();

		} else {

			setInput("ERROR: NO CHANGES TO EXEC");

		}

	}

};
