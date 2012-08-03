fmcPages["refnavdata"] = {

	initDisplay: func() {
	
		var magvar = getprop("/orientation/heading-magnetic-deg") - getprop("/orientation/heading-deg");
		
		var magvar_rnd = (int(magvar * 100))/100;
	
		title.setText("REF NAV DATA").setColor(blue);
		
		labels[0].setText("IDENT").setColor(blue);
		labels[1].setText("LATITUDE").setColor(blue);
		labels[2].setText("MAG VAR").setColor(blue);
		labels[3].setText("NAVDATA").setColor(blue);
		labels[12].setText("FREQ").setColor(blue);
		labels[13].setText("LONGITUDE").setColor(blue);
		labels[14].setText("ELEVATION").setColor(blue);
		
		values[0].setText(getprop("/sim/aero")).setColor(white);
		values[1].setText(getprop("/position/latitude-string")).setColor(white);
		values[2].setText(magvar_rnd).setColor(white).setFontSize(36, 1.2);
		values[3].setText(getprop("/aircrat/fmc/navdata/db-id")).setColor(green);
		values[12].setText("311.00").setColor(white);
		values[13].setText(getprop("/position/longitude-string")).setColor(green);
		values[14].setText("N/A").setColor(green);
		
	}

};
