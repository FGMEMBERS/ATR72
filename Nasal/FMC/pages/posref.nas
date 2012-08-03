fmcPages["posref"] = {

	initDisplay: func() {
	
		title.setText("POS REF").setColor(blue);
		
		labels[0].setText("POS (GPS)").setColor(blue);
		labels[1].setText("UTC (GPS)").setColor(blue);
		labels[2].setText("RNP/ACTUAL").setColor(blue);
		labels[13].setText("GS").setColor(blue);
		labels[10].setText("INTEGRITY PREDICTION").setColor(blue);
		
		values[0].setText(getprop("/instrumentation/fmc/pos-string")).setColor(white);
		values[1].setText(substr(getprop("/aircraft/fmc/time/utc"), 0, 4)~"z").setColor(white);
		values[2].setText("1.00/0.07").setColor(white).setFontSize(36, 1.2);
		values[3].setText("HDG/TAS OVERRIDE").setColor(green);
		values[4].setText("<ACT RTE").setColor(green);
		values[13].setText(int(getprop("/velocities/airspeed-kt")) ~ " KT").setColor(white);
		values[14].setText("SV DATA>").setColor(green);
		values[16].setText("DEST RAIM>").setColor(green);
		values[17].setText("ROUTE>").setColor(green);
		
	},

	l2: func() {

		var input = getprop("/instrumentation/fmc/input");

		if (input != nil) {

			setprop("/aircraft/fmc/time/utc-set", substr(input, 0, 4));
			setprop("/aircraft/fmc/time/start-sec", getprop("/sim/time/elapsed-sec"));
			me.initDisplay();
			clearInput();

		}

	},
	
	l5: func() {
	
		GoToPage("activerte");
	
	},
	
	r6: func() {
	
		GoToPage("rte1init");
	
	}

};
