var load_navdata_info = func() {

	# NAVDATA

	var location = "/aircraft/fmc/navdata/";
	var filename = getprop("/sim/aircraft-dir") ~ "/Database/NavData/base.xml";

	io.read_properties(filename, location);

	# COMPANY

	var location = "/aircraft/fmc/company/";
	var filename = getprop("/sim/aircraft-dir") ~ "/Database/Company/base.xml";

	io.read_properties(filename, location);

}

load_navdata_info();
