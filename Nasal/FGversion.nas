# FlightGear Multiple Version Compatibility Management

var legacy = ["2.8.0","2.9.0","2.10.0"];

# Returns true if using upcoming FG version, false if using one of the legacy versions.

var versionCheck = func() {
	var FGversion = getprop("/sim/version/flightgear");
	foreach(var version; legacy) {
		if(FGversion == version) {
			return 0;
		}
	}
	return 1;
}
