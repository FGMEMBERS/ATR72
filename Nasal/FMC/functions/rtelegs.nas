fmcPages["srcWP-legs1"] = {

	init: func(rte, n, ident) {

		me.rteID = rte;
		me.index = n;
		me.ident = ident;
	
		clearScreen();
		ActivePage = fmcPages["srcWP-legs1"];
	
		var results = gpsSearchAll(ident);
		me.results = results;

		if (size(results) > 1) {
				
			setprop("/aircraft/fmc/srcWP/num", size(results));
			setprop("/aircraft/fmc/srcWP/first", 0);
			
			for(var n=0; n<size(results); n+=1) {
			
				var tree = "/aircraft/fmc/srcWP/wpDisp[" ~ n ~ "]/";

				setprop(tree~"Llabel", results[n].name);
				setprop(tree~"Rlabel", results[n].brg ~ "*   " ~ results[n].dist ~ " NM");
				setprop(tree~"Rvalue", pos_string(results[n].lat, results[n].lon));
			
			}

			clearInput();

			me.updateDisplay();

		} else {

			me.confirmWP(0);

			clearInput();

		}
	
	},

	updateDisplay: func() {

		title.setText("SELECT DESIRED WPT").setColor(blue);

		values[5].setText("<CANCEL").setColor(green);

		var pages = int(getprop("/aircraft/fmc/srcWP/num") / 5);
		if (getprop("/aircraft/fmc/srcWP/num") > pages) pages += 1;

		var cur_page = int((getprop("/aircraft/fmc/srcWP/first")/5) + 1);

		me.first = getprop("/aircraft/fmc/srcWP/first");
		me.num = getprop("/aircraft/fmc/srcWP/num");

		pageNo.setText(cur_page~"/"~pages).setColor(blue);

		for(var n=0; n<5; n+=1) {
		
			var result_id = me.first + n;
			var tree = "/aircraft/fmc/srcWP/wpDisp[" ~ result_id ~ "]/";
			
			if (result_id < me.num) {
			
				labels[n].setText(getprop(tree~"Llabel")).setColor(white);
				labels[12 + n].setText(getprop(tree~"Rlabel")).setColor(white);
				values[12 + n].setText(getprop(tree~"Rvalue")).setColor(white);
			
			} else {

				labels[n].setText("").setColor(white);
				labels[12 + n].setText("").setColor(white);
				values[12 + n].setText("").setColor(white);
			
			}
		
		}

	},

	confirmWP: func(n) {

		if(size(me.results) > 0) {

			var ident = me.results[n].ident;

				rte1legscmd.setWP(me.index, ident);

		} else {

			setInput("ERROR: NOT IN DATABASE");

		}

		GoToPage("rte1legs");

	},

	l1: func() {

		me.confirmWP(me.first);

	},

	l2: func() {

		me.confirmWP(me.first + 1);

	},

	l3: func() {

		me.confirmWP(me.first + 2);

	},

	l4: func() {

		me.confirmWP(me.first + 3);

	},

	l5: func() {

		me.confirmWP(me.first + 4);

	},

	l6: func() {

		GoToPage("rte1legs");

	},

	next: func() {

		if(me.first + 5 < me.num) {
		
			me.first += 5;
			setprop("/aircraft/fmc/srcWP/first", me.first);
			me.updateDisplay();
		
		}

	},

	prev: func() {

		if (me.first > 0) {
		
			me.first -= 5;
			setprop("/aircraft/fmc/srcWP/first", me.first);
			me.updateDisplay();
		
		}

	}	

};

var rtelegs = {

	n:0,
	
	getWP: func(index) {

		var wp = getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/wp");

		if (wp != nil) return wp;
		else return "";

	},

	setALT: func(index, alt) {

		setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/alt", alt);

	},

	setWP: func(index, input) {

		if ((input != nil) and (input != " ")) {

			var wp = getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/wp");

			var elements = split("/",input);

			# Add Waypoint

			if ((wp == "-----") or (wp == nil) or (wp == "")) {

				if (size(elements) == 2) { # Pilot Entered WP/ADV-ALT

					setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/wp", elements[0]);
					setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/alt", elements[1]);

				} else { # Pilot Entered only WP

					setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/wp", input);
					setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/alt", "-----");

				}

				setprop("/aircraft/fmc/rte"~me.n~"/legs/num", getprop("/aircraft/fmc/rte"~me.n~"/legs/num") + 1);


			} else {

				# Insert Waypoint before Indexed waypoint

				var next_wp = getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(index+1)~ "]/wp");

				var num = getprop("/aircraft/fmc/rte"~me.n~"/legs/num");

				if (next_wp != elements[0]) {

					# First move all the waypoints from the index point forward
					for (var n=num; n>index; n=n-1) {
						setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~n~ "]/wp", getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n-1)~ "]/wp"));
						setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~n~ "]/alt", getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n-1)~ "]/alt"));
					}

					setprop("/aircraft/fmc/rte"~me.n~"/legs/num", getprop("/aircraft/fmc/rte"~me.n~"/legs/num") + 1);

					# Now, add the waypoint into index position

					if (size(elements) == 2) { # Pilot Entered WP/ADV-ALT

						setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/wp", elements[0]);
						setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/alt", elements[1]);

					} else { # Pilot Entered only WP

						setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/wp", input);
						setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~index~ "]/alt", "-----");

					}

				}

				# Remove Waypoint At Index

				else {

					# Move all the elements after index point back => discard the elements at index point

					for(var n=index;n<(num-1);n+=1) {

						if (getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n+1)~ "]/wp") != nil)
							setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~n~ "]/wp", getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n+1)~ "]/wp"));

						if (getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n+1)~ "]/alt") != nil)
							setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~n~ "]/alt", getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n+1)~ "]/alt"));

					}

					setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(num-1)~ "]/wp", "");
					setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(num-1)~ "]/alt", "");

					setprop("/aircraft/fmc/rte"~me.n~"/legs/num", getprop("/aircraft/fmc/rte"~me.n~"/legs/num") - 1);

				}

			}

		} else {

			# Remove Waypoint at Index

			for(var n=index; n<(num-1); n+=1) {

				if (getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n+1)~ "]/wp") != nil)
					setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~n~ "]/wp", getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n+1)~ "]/wp"));

				if (getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n+1)~ "]/alt") != nil)
					setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~n~ "]/alt", getprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(n+1)~ "]/alt"));

			}

			setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(num-1)~ "]/wp", "");
			setprop("/aircraft/fmc/rte"~me.n~"/legs/wp[" ~(num-1)~ "]/alt", "");

			setprop("/aircraft/fmc/rte"~me.n~"/legs/num", getprop("/aircraft/fmc/rte"~me.n~"/legs/num") - 1);

		}

	},
	
	new: func(index) {
	
		var m = {parents:[rtelegs]};
		
		m.n = index;
		
		return m;
	
	}

};

var rte1legscmd = rtelegs.new(1);
var rte2legscmd = rtelegs.new(2);
