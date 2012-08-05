fmcPages["deparrindex"] = {

	initDisplay: func() {
	
		title.setText("DEP/ARR INDEX").setColor(blue);
		
		labels[6].setText("---------- RTE1 ----------").setColor(blue);
		labels[8].setText("---------- RTE2 ----------").setColor(blue);
		labels[11].setText("OTHER").setColor(blue);
		labels[5].setText("<--DEP").setColor(green);
		labels[17].setText("ARR-->").setColor(green);
		values[5].setText("DEP").setColor(green);
		values[17].setText("ARR").setColor(green);
		
		values[0].setText("<DEP").setColor(green);
		values[12].setText("ARR>").setColor(green);
		values[13].setText("ARR>").setColor(green);

		values[6].setText(getprop("/aircraft/fmc/rte1/origin-arpt")).setColor(white);
		values[7].setText(getprop("/aircraft/fmc/rte1/dest-arpt")).setColor(white);
	},

	l1: func() {

		GoToPage("departures");

	},

	r2: func() {

		GoToPage("arrivals");

	}

};
