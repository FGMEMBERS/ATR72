fmcPages["rte1legs"] = {

	initDisplay: func() {

		if (getprop("/aircraft/fmc/rte1/active")) title.setText("ACT RTE 1 LEGS").setColor(blue);
		else title.setText("RTE 1 LEGS").setColor(blue);

		me.num = getprop("/aircraft/fmc/rte1/legs/num");
		me.first = getprop("/aircraft/fmc/rte1/legs/first");
		
		var pages = int(me.num/5) + 1;
		
		if ((me.num+2)/5 > pages) pages += 1;
		
		var cur_page = int(me.first/5) + 1;

		pageNo.setText(cur_page~"/"~pages).setColor(blue);

		labels[5].setText("-------------------------------------------------------").setColor(blue);

		if(me.num == 0) {

			# Convert Airway Format Route to Legs Format Route

			awy2legs(1);

		}

		if (getprop("/aircraft/fmc/rte1/active") == 1) { # Route is already activated

			values[17].setText("PERF INIT>").setColor(green);

		} else { # Route is not activated

			values[17].setText("ACTIVATE>").setColor(green);

		}

		me.updateDisplay();
		
	},

	updateDisplay: func() {
	
		if (getprop("/instrumentation/fmc/mod-mem") == 1) {
			setprop("/instrumentation/fmc/exec-lt", 1);
			modcmd.show();
		} else {
			setprop("/instrumentation/fmc/exec-lt", 0);
			modcmd.hide();
		}

		me.num = getprop("/aircraft/fmc/rte1/legs/num");
		me.first = getprop("/aircraft/fmc/rte1/legs/first");
		
		var pages = int(me.num/5) + 1;
		
		if ((me.num+2)/5 > pages) pages += 1;
		
		var cur_page = int(me.first/5) + 1;

		pageNo.setText(cur_page~"/"~pages).setColor(blue);

		for(var n=0; n<5; n+=1) {

			var wp_id = me.first + n;

			# Now, update the displays

			if (wp_id < me.num) {

				# Calculate Course and Distance from the last waypoint to this one

				if (wp_id == 0) { # This is for the first waypoint

					var gpsresult = gpsSearchAll(getprop("/aircraft/fmc/rte1/legs/wp["~wp_id~"]/wp"));

					labels[n].setText(gpsresult[0].brg~"* / "~gpsresult[0].dist~"NM").setColor(white);

				} else { # NOT the first waypoint

					var gpsresult1 = gpsSearchAll(getprop("/aircraft/fmc/rte1/legs/wp["~(wp_id-1)~"]/wp"));
					var gpsresult2 = gpsSearchAll(getprop("/aircraft/fmc/rte1/legs/wp["~wp_id~"]/wp"));

					var last_wp = geo.Coord.new();
					var this_wp = geo.Coord.new();

					last_wp.set_latlon(gpsresult1[0].lat, gpsresult1[0].lon);
					this_wp.set_latlon(gpsresult2[0].lat, gpsresult2[0].lon);

					var brg = int(last_wp.course_to(this_wp));
					var dist = int(last_wp.distance_to(this_wp) * 0.000539957);

					labels[n].setText(brg~"* / "~dist~"NM").setColor(white);

				}

				values[n].setText(getprop("/aircraft/fmc/rte1/legs/wp["~wp_id~"]/wp")).setColor(white);

				var alt = getprop("/aircraft/fmc/rte1/legs/wp["~wp_id~"]/alt");
				
				if ((alt != "") and (alt != "-----")) {

					if (alt > getprop("/aircraft/fmc/perf/trans-alt")) {

						var fl = int(alt/100);

						values[n+12].setText("/ FL"~fl).setColor(white);

					} else {

						values[n+12].setText("/ "~alt~"FT").setColor(white);

					}

				} else {

					values[n+12].setText("/ -----").setColor(white);

				}

			} elsif (wp_id == me.num) {

				labels[n].setText("THEN").setColor(white);
				values[n].setText("-----").setColor(white);
				values[n+12].setText("/ -----").setColor(white);

			} elsif (wp_id == me.num+1) {

				if (getprop("/aircraft/fmc/rte1/dest-rwy") != "---")
					values[n].setText(getprop("/aircraft/fmc/rte1/dest-arpt") ~ "/RW" ~ getprop("/aircraft/fmc/rte1/dest-rwy")).setColor(magenta);
				else
					values[n].setText(getprop("/aircraft/fmc/rte1/dest-arpt")).setColor(magenta);

				values[n+12].setText("").setColor(magenta);
				labels[n].setText("-- ROUTE DISCONTINUITY --").setColor(white);

			} else {

				values[n].setText("").setColor(white);
				values[n+12].setText("").setColor(white);
				labels[n].setText("").setColor(white);

			}

		}

	},

	l1: func() {

		var input = getprop("/instrumentation/fmc/input");

		if ((input != nil) and (input != "")) {

			fmcPages["srcWP-legs1"].init(1, me.first, input);
			clearInput();

			if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

		} else {

			setprop("/instrumentation/fmc/input", rte1legscmd.getWP(me.first));

		}

	},

	l2: func() {

		var input = getprop("/instrumentation/fmc/input");

		if ((input != nil) and (input != "")) {

			fmcPages["srcWP-legs1"].init(1, me.first + 1, input);
			clearInput();

			if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

		} else {

			setprop("/instrumentation/fmc/input", rte1legscmd.getWP(me.first + 1));

		}

	},

	l3: func() {

		var input = getprop("/instrumentation/fmc/input");

		if ((input != nil) and (input != "")) {

			fmcPages["srcWP-legs1"].init(1, me.first + 2, input);
			clearInput();

			if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

		} else {

			setprop("/instrumentation/fmc/input", rte1legscmd.getWP(me.first + 2));

		}

	},

	l4: func() {

		var input = getprop("/instrumentation/fmc/input");

		if ((input != nil) and (input != "")) {

			fmcPages["srcWP-legs1"].init(1, me.first + 3, input);
			clearInput();

			if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

		} else {

			setprop("/instrumentation/fmc/input", rte1legscmd.getWP(me.first + 3));

		}

	},

	l5: func() {

		var input = getprop("/instrumentation/fmc/input");

		if ((input != nil) and (input != "")) {

			fmcPages["srcWP-legs1"].init(1, me.first + 4, input);
			clearInput();

			if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

		} else {

			setprop("/instrumentation/fmc/input", rte1legscmd.getWP(me.first + 4));

		}

	},

	r1: func() {

		var input = getprop("/instrumentation/fmc/input");

		rte1legscmd.setALT(me.first, input);
		me.updateDisplay();
		clearInput();

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

	},

	r2: func() {

		var input = getprop("/instrumentation/fmc/input");

		rte1legscmd.setALT(me.first + 1, input);
		me.updateDisplay();
		clearInput();

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

	},

	r3: func() {

		var input = getprop("/instrumentation/fmc/input");

		rte1legscmd.setALT(me.first + 2, input);
		me.updateDisplay();
		clearInput();

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

	},

	r4: func() {

		var input = getprop("/instrumentation/fmc/input");

		rte1legscmd.setALT(me.first + 3, input);
		me.updateDisplay();
		clearInput();

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

	},

	r5: func() {

		var input = getprop("/instrumentation/fmc/input");

		rte1legscmd.setALT(me.first + 4, input);
		me.updateDisplay();
		clearInput();

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			modcmd.show();
			values[17].setText("ERASE>").setColor(green);
			
		}

	},

	next: func() {
	
		if(me.first + 3 <= me.num) {
		
			me.first += 5;
			setprop("/aircraft/fmc/rte1/legs/first", me.first);
		
		}
		
		me.updateDisplay();
	
	},

	prev: func() {
	
		if(me.first > 0) {
		
			me.first -= 5;
			setprop("/aircraft/fmc/rte1/legs/first", me.first);
		
		}
		
		me.updateDisplay();
	
	},

	r6: func() {

		if (getprop("/aircraft/fmc/rte1/active") == 1) { # Route is already activated

			if (getprop("/instrumentation/fmc/exec-lt") == 1) {

				revert_mods(1);
				setprop("/instrumentation/fmc/exec-lt", 0);
				setprop("/instrumentation/fmc/mod-mem", 0);
				values[17].setText("PERF INIT>").setColor(green);
				me.updateDisplay();

			} else {

				GoToPage("perfinit");

			}

		} else { # Route is not activated

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			values[17].setText("PERF INIT>").setColor(green);

		}

	},

	exec: func() {

		if (getprop("/instrumentation/fmc/exec-lt") == 1) {

			activate_rte("legs", 1);
			setprop("/instrumentation/fmc/mod-mem", 0);
			modcmd.hide();
			title.setText("ACT RTE 1 LEGS").setColor(blue);
			values[17].setText("PERF INIT>").setColor(green);
			setprop("/instrumentation/fmc/exec-lt", 0);

		}

	}

};
