var depView = {

	first: 0,
	dispSIDs: [],
	dispRWYs: [],
	selectedSID: 0,
	loadData: func(icao) {

		me.DepARPT = procedures.fmsDB.new(icao);

		me.dispRWYs = [];

		# Get a list of all available runways on the departure airport
		
		var arpt = airportinfo(icao);

		var rwy_match = 0;

		foreach(var i; keys(arpt.runways)) {
		
			append(me.dispRWYs, arpt.runways[i].id);
			
			if (arpt.runways[i].id == getprop("/aircraft/fmc/rte1/dest-rwy")) rwy_match = 1;
		
		}

		# If departure runway isn't already selected, select the first option

		if (rwy_match == 0) {

			setprop("/aircraft/fmc/rte1/origin-rwy", me.dispRWYs[0]);

			me.SIDsByRWY(0);

		} else {

			# Find selected runway and get the list of SIDs for it

			for(var n=0; n<size(me.dispRWYs); n+=1) {

				if (me.dispRWYs[n] == getprop("/aircraft/fmc/rte1/origin-rwy")) me.SIDsByRWY(n);

			}

		}

	},
	SIDsByRWY: func(id) {

		# Refresh SID Data

		me.dispSIDs = [];

		me.selectedSID = 0;

		setprop("/aircraft/fmc/rte1/origin-rwy", me.dispRWYs[id]);

		me.SIDList = me.DepARPT.getSIDList(me.dispRWYs[id]);

		foreach(var SID; me.SIDList) {

			append(me.dispSIDs, SID.wp_name);

		}

	},
	selectSID: func(id) {

		me.selectedSID = id;

	},
	confirmSID: func() {

		var SIDname = me.SIDList[me.selectedSID].wp_name;

		var num = size(me.SIDList[me.selectedSID].wpts);

		for(var n=0; n<num; n+=1) {

			var id = me.SIDList[me.selectedSID].wpts[n].wp_name;
			var lat = me.SIDList[me.selectedSID].wpts[n].wp_lat;
			var lon = me.SIDList[me.selectedSID].wpts[n].wp_lon;
			var alt = me.SIDList[me.selectedSID].wpts[n].alt_cstr;

			setprop("/aircraft/fmc/rte1/dep/wpts/wp["~n~"]/id", id);
			setprop("/aircraft/fmc/rte1/dep/wpts/wp["~n~"]/lat-deg", lat);
			setprop("/aircraft/fmc/rte1/dep/wpts/wp["~n~"]/lon-deg", lon);
			setprop("/aircraft/fmc/rte1/dep/wpts/wp["~n~"]/alt-res", alt);

		}

		setprop("/aircraft/fmc/rte1/dep/sid", SIDname);

		setprop("/aircraft/fmc/rte1/dep/wpts/num", num);

		fplnDisp.update();

	}

};

fmcPages["departures"] = {

	initDisplay: func() {
	
		title.setText(getprop("/aircraft/fmc/rte1/origin-arpt")~" DEPARTURES").setColor(blue);
		
		var pages = int(size(depView.dispSIDs)/5) + 1;
		
		if (size(depView.dispSIDs)/5 > pages) pages += 1;
		
		var cur_page = int(depView.first/5) + 1;

		pageNo.setText(cur_page~"/"~pages).setColor(blue);
		
		labels[0].setText("SIDS").setColor(blue);
		labels[6].setText("RTE1").setColor(blue);
		labels[12].setText("RUNWAYS").setColor(blue);
		labels[5].setText("-------------------------------------------------------").setColor(blue);
		values[5].setText("<INDEX").setColor(green);
		values[17].setText("ROUTE>").setColor(green);

		depView.loadData(getprop("/aircraft/fmc/rte1/origin-arpt"));

		me.updateDisplay();
		
	},

	updateDisplay: func() {

		var pages = int(size(depView.dispSIDs)/5) + 1;
		
		if (size(depView.dispSIDs)/5 > pages) pages += 1;
		
		var cur_page = int(depView.first/5) + 1;

		pageNo.setText(cur_page~"/"~pages).setColor(blue);

		var num = size(depView.dispSIDs);

		# DISPLAY SIDs

		for(var n=0; n<5; n+=1) {

			var id = depView.first + n;

			if (id < num) { # SID EXISTS

				if (depView.selectedSID == id)

					values[n].setText(depView.dispSIDs[id] ~ " <SEL>").setColor(magenta);

				else

					values[n].setText(depView.dispSIDs[id]).setColor(white);

			} else { # SID DOESN'T EXIST

				values[n].setText("").setColor(white);

			}

		}

		# DISPLAY RWYs

		var rwy_num = size(depView.dispRWYs);

		for(var n=0; n<5; n+=1) {

			var id = depView.first + n;

			if (rwy_num <= 5) id = n;

			if (id < rwy_num) { # RWY EXISTS

				var dep_rwy = getprop("/aircraft/fmc/rte1/origin-rwy");

				if(dep_rwy == depView.dispRWYs[id]) {

					values[12 + n].setText("<SEL> "~depView.dispRWYs[id]).setColor(magenta);

				} else {

					values[12 + n].setText(depView.dispRWYs[id]).setColor(white);

				}

			} else { # RWY DOESN'T EXIST

				values[12 + n].setText("").setColor(white);

			}

		}

	},

	l1: func() {

		depView.selectSID(depView.first);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	l2: func() {

		depView.selectSID(depView.first + 1);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	l3: func() {

		depView.selectSID(depView.first + 2);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	l4: func() {

		depView.selectSID(depView.first + 3);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	l5: func() {

		depView.selectSID(depView.first + 4);
		setprop("/instrumentation/fmc/exec-lt", 1);
		me.updateDisplay();

	},

	r1: func() {

		var rwy_num = size(depView.dispRWYs);

		if (rwy_num <= 5)
			depView.SIDsByRWY(0);
		else
			depView.SIDsByRWY(depView.first);


		me.updateDisplay();

	},

	r2: func() {

		var rwy_num = size(depView.dispRWYs);

		if (rwy_num <= 5)
			depView.SIDsByRWY(1);
		else
			depView.SIDsByRWY(depView.first + 1);


		me.updateDisplay();

	},

	r3: func() {

		var rwy_num = size(depView.dispRWYs);

		if (rwy_num <= 5)
			depView.SIDsByRWY(2);
		else
			depView.SIDsByRWY(depView.first + 2);


		me.updateDisplay();

	},

	r4: func() {

		var rwy_num = size(depView.dispRWYs);

		if (rwy_num <= 5)
			depView.SIDsByRWY(3);
		else
			depView.SIDsByRWY(depView.first + 3);


		me.updateDisplay();

	},

	r5: func() {

		var rwy_num = size(depView.dispRWYs);

		if (rwy_num <= 5)
			depView.SIDsByRWY(4);
		else
			depView.SIDsByRWY(depView.first + 4);


		me.updateDisplay();

	},

	l6: func() {

		GoToPage("deparrindex");

	},

	r6: func() {

		GoToPage("rte1init");

	},

	next: func() {

		if(depView.first + 5 <= size(depView.dispSIDs)) {

			depView.first += 5;
		
		}
		
		me.updateDisplay();

	},

	prev: func() {

		if(depView.first > 0) {

			depView.first -= 5;
		
		}
		
		me.updateDisplay();

	},

	exec: func() {

		if (getprop("/instrumentation/fmc/exec-lt") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 0);

			depView.confirmSID();

		} else {

			setInput("ERROR: NO CHANGES TO EXEC");

		}

	}

};
