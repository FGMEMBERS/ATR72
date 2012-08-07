# AWY.DAT Parser (convert to Properties)
# Author: Narendran Muraleedharan
# This file is used to parse the Airways data from FlightGear's awy.dat data file. It then puts the airways into properties. Once all the airways are into properties, the rest can be done during runtime.

var awy_hash = {};
var awy_vect = [];

var parse_awys = func() {

	var root = getprop("/sim/aircraft-dir");

	var awy_dat = io.open(root~ "/Devel/awy.dat", mode="r");
	
	var n = 0;
	
	while(var line = io.readln(awy_dat)) {
	
		var data = split(" ", line);
		
		var wp1 = data[0];
		var wp2 = data[3];
		var awy0 = split("-", data[9]);
		var awy = awy0[0];
		
		var index = substr(awy, 0, 2);
		
		if (awy_hash[index] == nil) {
		
			awy_hash[index] = 0;
			append(awy_vect, index);
			n+=1;
		
		} else {
		
			awy_hash[index] += 1;
		
		}
		
		var tree = "/database/navdata/awys/_" ~ index ~ "/awy[" ~ awy_hash[index] ~ "]/";
		
		setprop(tree~ "id", awy);
		setprop(tree~ "wp1", wp1);
		setprop(tree~ "wp2", wp2);
		
	}

}

var write_dat = func(index) {

	var location = "/database/navdata/awys/_" ~ index ~ "/";
	var filename = getprop("/sim/aircraft-dir") ~ "/Database/NavData/Airways/" ~ index ~ ".xml";

	io.write_properties(filename, location);

}

var awys2xml = func() {

	foreach(var index; awy_vect) {
	
		write_dat(index);
	
	}

}
