fmcPages["ident"] = {

	initDisplay: func() {
	
		title.setText("IDENT").setColor(blue);
		
		labels[0].setText("MODEL").setColor(blue);
		labels[1].setText("CO-DATA").setColor(blue);
		labels[2].setText("NAVDATA").setColor(blue);
		labels[3].setText("CALLSIGN").setColor(blue);
		labels[5].setText("-------------------------------------------------------").setColor(blue);
		labels[12].setText("ENGINES").setColor(blue);
		labels[13].setText("CO-DATA").setColor(blue);
		labels[14].setText("NAVDATA").setColor(blue);
		
		values[0].setText(getprop("/sim/aero")).setColor(white);
		values[1].setText(getprop("/aircraft/fmc/company/db-id")).setColor(white);
		values[2].setText(getprop("/aircraft/fmc/navdata/db-id")).setColor(white);
		values[3].setText(getprop("/sim/multiplay/callsign")).setColor(white);
		values[12].setText("PW127F").setColor(white);
		values[13].setText(getprop("/aircraft/fmc/company/db-date")).setColor(white);
		values[14].setText(getprop("/aircraft/fmc/navdata/db-date")).setColor(white);
		values[17].setText("POS REF>").setColor(green);
	
	},
	
	r6: func() {
	
		GoToPage("posref");
	
	}

};
