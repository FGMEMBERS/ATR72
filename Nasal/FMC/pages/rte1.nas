fmcPages["rte1init"] = {

	initDisplay: func() {
	
		title.setText("RTE 1").setColor(blue);
		pageNo.setText("1/2").setColor(blue);
		
		labels[0].setText("ORIGIN").setColor(blue);
		labels[1].setText("RUNWAY").setColor(blue);
		labels[5].setText("-------------------------------------------------------").setColor(blue);
		labels[12].setText("DEST").setColor(blue);
		labels[13].setText("FLT NO").setColor(blue);
		labels[14].setText("CO ROUTE").setColor(blue);
		
		values[5].setText("<RTE 2").setColor(green);
		values[16].setText("CLEAR>").setColor(green);
		
		values[0].setText(getprop("/aircraft/fmc/rte1/origin-arpt")).setColor(white);
		values[1].setText(getprop("/aircraft/fmc/rte1/origin-rwy")).setColor(white);
		values[12].setText(getprop("/aircraft/fmc/rte1/dest-arpt")).setColor(white);
		values[13].setText(getprop("/aircraft/fmc/rte1/flt-no")).setColor(white);
		values[14].setText(getprop("/aircraft/fmc/rte1/co-rte")).setColor(white);

		if ((getprop("/aircraft/fmc/rte1/origin-arpt") != "----") and (getprop("/aircraft/fmc/rte1/dest-arpt") != "----")) {

			if (getprop("/aircraft/fmc/rte1/active") == 1) { # Route is already activated

				values[17].setText("PERF INIT>").setColor(green);

			} else { # Route is not activated

				values[17].setText("ACTIVATE>").setColor(green);

			}

		} else {

			values[17].setText("").setColor(green);

		}
		
	},
	
	l1: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		setprop("/aircraft/fmc/rte1/origin-arpt", input);
		values[0].setText(input);
		
		clearInput();

		if ((getprop("/aircraft/fmc/rte1/origin-arpt") != "----") and (getprop("/aircraft/fmc/rte1/dest-arpt") != "----")) {

			if (getprop("/aircraft/fmc/rte1/active") == 1) { # Route is already activated

				values[17].setText("PERF INIT>").setColor(green);
				setprop("/instrumentation/fmc/exec-lt", 1);

			} else { # Route is not activated

				values[17].setText("ACTIVATE>").setColor(green);

			}

		} else {

			values[17].setText("").setColor(green);

		}
	
	},
	
	l2: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		setprop("/aircraft/fmc/rte1/origin-rwy", input);
		values[1].setText(input);
		
		clearInput();
	
	},
	
	r1: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		setprop("/aircraft/fmc/rte1/dest-arpt", input);
		values[12].setText(input);
		
		clearInput();

		if ((getprop("/aircraft/fmc/rte1/origin-arpt") != "----") and (getprop("/aircraft/fmc/rte1/dest-arpt") != "----")) {

			if (getprop("/aircraft/fmc/rte1/active") == 1) { # Route is already activated

				values[17].setText("PERF INIT>").setColor(green);
				setprop("/instrumentation/fmc/exec-lt", 1);

			} else { # Route is not activated

				values[17].setText("ACTIVATE>").setColor(green);

			}

		} else {

			values[17].setText("").setColor(green);

		}
	
	},
	
	r2: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		setprop("/aircraft/fmc/rte1/flt-no", input);
		values[13].setText(input);
		
		clearInput();
	
	},
	
	r3: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		setprop("/aircraft/fmc/rte1/co-rte", input);
		values[14].setText(input);
		
		# rte1.loadCoRte(input);
		
		clearInput();
	
	},
	
	l6: func() {
	
		GoToPage("rte2init");
	
	},
	
	next: func() {
	
		GoToPage("rte1");
	
	},

	r5: func() {

		clearRte(1);

	},

	r6: func() {

		if (getprop("/aircraft/fmc/rte1/active") == 1) { # Route is already activated

			GoToPage("perfinit");

		} else { # Route is not activated

			setprop("/instrumentation/fmc/exec-lt", 1);
			values[17].setText("").setColor(green);

		}

	},

	exec: func() {

		if (getprop("/instrumentation/fmc/exec-lt") == 1) {

			activate_rte("direct", 1);
			setprop("/instrumentation/fmc/exec-lt", 0);

		}

	}

};

fmcPages["rte1"] = {

	initDisplay: func() {
	
		if(getprop("/instrumentation/fmc/mod-mem")==1) {
			setprop("/aircraft/fmc/rte1/rte-mod", 1);
			setprop("/instrumentation/fmc/exec-lt", 1);
		} else {
			setprop("/aircraft/fmc/rte1/rte-mod", 0);
		}
	
		me.rte_num = getprop("/aircraft/fmc/rte1/rte/num");
		me.rte_first = getprop("/aircraft/fmc/rte1/rte/first");
		
		var pages = int(me.rte_num/5) + 1;
		
		if (me.rte_num/5 > pages) pages += 1;
		
		var cur_page = int(me.rte_first/5) + 1;
	
		title.setText("RTE 1").setColor(blue);
		pageNo.setText((cur_page+1)~"/"~(pages+1)).setColor(blue);
		
		labels[0].setText("VIA").setColor(blue);
		labels[12].setText("TO").setColor(blue);
		labels[5].setText("-------------------------------------------------------").setColor(blue);
		values[5].setText("<RTE 2").setColor(green);
		
		me.updateDisplay();

		if (getprop("/aircraft/fmc/rte1/active") == 1) { # Route is already activated

			values[17].setText("PERF INIT>").setColor(green);

		} else { # Route is not activated

			values[17].setText("ACTIVATE>").setColor(green);

		}
		
	},
	
	updateDisplay: func() {
	
		for(var n=0; n<5; n+=1) {
		
			var rte_id = me.rte_first + n;
			var tree = "/aircraft/fmc/rte1/rte/entry[" ~ rte_id ~ "]/";
			
			if (rte_id <= me.rte_num) {
			
				if (getprop(tree~ "awy") != nil) {
				
					values[n].setText(getprop(tree~ "awy")).setColor(white);
				
				} else {
				
					values[n].setText("----").setColor(white);
				
				}
				
				if (getprop(tree~ "wp") != nil) {
				
					values[12 + n].setText(getprop(tree~ "wp")).setColor(white);
				
				} else {
				
					values[12 + n].setText("-----").setColor(white);
				
				}
			
			} else {
			
				values[n].setText("").setColor(white);
				values[12 + n].setText("").setColor(white);
			
			}
		
		}
	
	},
	
	l6: func() {
	
		GoToPage("rte2init");
	
	},
	
	l1: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		if (me.rte_first < me.rte_num) {
		
			rte1.updateAwy(me.rte_first, input);
		
		} else {
		
			rte1.addAwy(input);
		
		}
		
		me.updateDisplay();
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
	
	},
	
	l2: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		if (me.rte_first + 1 < me.rte_num) {
		
			rte1.updateAwy(me.rte_first + 1, input);
		
		} else {
		
			rte1.addAwy(input);
		
		}
		
		me.updateDisplay();
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
	
	},
	
	l3: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		if (me.rte_first + 2 < me.rte_num) {
		
			rte1.updateAwy(me.rte_first + 2, input);
		
		} else {
		
			rte1.addAwy(input);
		
		}
		
		me.updateDisplay();
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
	
	},
	
	l4: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		if (me.rte_first + 3 < me.rte_num) {
		
			rte1.updateAwy(me.rte_first + 3, input);
		
		} else {
		
			rte1.addAwy(input);
		
		}
		
		me.updateDisplay();
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
	
	},
	
	l5: func() {
	
		var input = getprop("/instrumentation/fmc/input");
	
		if (me.rte_first + 4 < me.rte_num) {
		
			rte1.updateAwy(me.rte_first + 4, input);
		
		} else {
		
			rte1.addAwy(input);
		
		}
		
		me.updateDisplay();
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
	
	},
	
	r1: func() {
	
		var input = getprop("/instrumentation/fmc/input");
		
		if (me.rte_first < me.rte_num) {
		
			rte1.updateWP(me.rte_first, input);
		
		} else {
		
			rte1.addWP(input);
		
		}

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
	
	},
	
	r2: func() {
	
		var input = getprop("/instrumentation/fmc/input");
		
		if (me.rte_first + 1 < me.rte_num) {
		
			rte1.updateWP(me.rte_first + 1, input);

		} else {
		
			rte1.addWP(input);
		
		}

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}

		setprop("/aircraft/fmc/rte1/rte-mod", 1);
	
	},
	
	r3: func() {
	
		var input = getprop("/instrumentation/fmc/input");
		
		if (me.rte_first + 2 < me.rte_num) {
		
			rte1.updateWP(me.rte_first + 2, input)
		
		} else {
		
			rte1.addWP(input);
		
		}

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
	
	},
	
	r4: func() {
	
		var input = getprop("/instrumentation/fmc/input");
		
		if (me.rte_first + 3 < me.rte_num) {
		
			rte1.updateWP(me.rte_first + 3, input)
		
		} else {
		
			rte1.addWP(input);
		
		}

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
	
	},
	
	r5: func() {
	
		var input = getprop("/instrumentation/fmc/input");
		
		if (me.rte_first + 4 < me.rte_num) {
		
			rte1.updateWP(me.rte_first + 4, input)
		
		} else {
		
			rte1.addWP(input);
		
		}

		if (getprop("/aircraft/fmc/rte1/active") == 1) {

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			
		}
		
		setprop("/aircraft/fmc/rte1/rte-mod", 1);
	
	},
	
	next: func() {
	
		if(me.rte_first + 5 <= me.rte_num) {
		
			me.rte_first += 5;
			setprop("/aircraft/fmc/rte1/rte/first", me.rte_first);
		
		}
		
		me.updateDisplay();
	
	},
	
	prev: func() {
	
		if (me.rte_first > 0) {
		
			me.rte_first -= 5;
			setprop("/aircraft/fmc/rte1/rte/first", me.rte_first);
			me.updateDisplay();
		
		} else {
		
			GoToPage("rte1init");
		
		}
	
	},

	r6: func() {

		if (getprop("/aircraft/fmc/rte1/active") == 1) { # Route is already activated

			GoToPage("perfinit");

		} else { # Route is not activated

			setprop("/instrumentation/fmc/exec-lt", 1);
			setprop("/instrumentation/fmc/mod-mem", 1);
			values[17].setText("PERF INIT>").setColor(green);

		}

	},

	exec: func() {

		if (getprop("/instrumentation/fmc/exec-lt") == 1) {

			activate_rte("rte", 1);
			values[17].setText("PERF INIT>").setColor(green);
			setprop("/instrumentation/fmc/exec-lt", 0);
			setprop("/instrumentation/fmc/mod-mem", 0);

		}

	}

};
