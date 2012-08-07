var fplnDisp = {

	clear: func() {

		setprop("/autopilot/route-manager/input", "@CLEAR");

	},

	update: func() {

		me.clear();

		var sids = getprop("/aircraft/fmc/rte1/dep/wpts/num");

		for(var n=0; n<sids; n+=1) {

			if((getprop("/aircraft/fmc/rte1/dep/wpts/wp["~n~"]/lon-deg") > 0) and (getprop("/aircraft/fmc/rte1/dep/wpts/wp["~n~"]/lat-deg") > 0)) {

				setprop("/autopilot/route-manager/input", "@INSERT99:"~getprop("/aircraft/fmc/rte1/dep/wpts/wp["~n~"]/lon-deg")~","~getprop("/aircraft/fmc/rte1/dep/wpts/wp["~n~"]/lat-deg"));

			}

		}

		var num = getprop("/aircraft/fmc/active-rte/num");

		for(var n=0; n<num; n+=1) {

			setprop("/autopilot/route-manager/input", "@INSERT99:"~getprop("/aircraft/fmc/active-rte/wp["~n~"]/id"));

		}

		var stars = getprop("/aircraft/fmc/rte1/arr/wpts/num");

		for(var n=0; n<stars; n+=1) {

			if((getprop("/aircraft/fmc/rte1/arr/wpts/wp["~n~"]/lon-deg") > 0) and (getprop("/aircraft/fmc/rte1/arr/wpts/wp["~n~"]/lat-deg") > 0)) {

				setprop("/autopilot/route-manager/input", "@INSERT99:"~getprop("/aircraft/fmc/rte1/arr/wpts/wp["~n~"]/lon-deg")~","~getprop("/aircraft/fmc/rte1/arr/wpts/wp["~n~"]/lat-deg"));

			}

		}

	},

};

var clear_active = func() {

	var num = getprop("/aircraft/fmc/active-rte/num");

	for(var n=0; n<num; n+=1) {

		setprop("/aircraft/fmc/active-rte/wp["~n~"]/id", "-----");
		setprop("/aircraft/fmc/active-rte/wp["~n~"]/alt", "-----");

	}

	setprop("/aircraft/fmc/active-rte/num", 0);

};

var activate_rte = func(src, id) { # Activation source can be direct, rte and legs

	clear_active();

	if (id == 1) {

		setprop("/aircraft/fmc/rte2/active", 0);

	} else {

		setprop("/aircraft/fmc/rte1/active", 0);

	}

	if (src == "direct") { # Set a direct path to the arrival airport

		var dest = getprop("/aircraft/fmc/rte"~id~"/dest-arpt");

		setprop("/aircraft/fmc/active-rte/wp[0]/id", dest);
		setprop("/aircraft/fmc/active-rte/wp[0]/alt", "-----");

		setprop("/aircraft/fmc/rte"~id~"/active", 1);

		setprop("/aircraft/fmc/active-rte/current-wp", 0);

		setprop("/aircraft/fmc/active-rte/num", 1);

	} elsif (src == "rte") { # Set RTE Waypoints (ignore VIA) to Active RTE

		var num = getprop("/aircraft/fmc/rte"~id~"/rte/num");

		for(var n=0; n<num; n+=1) {

			setprop("/aircraft/fmc/active-rte/wp["~n~"]/id", getprop("/aircraft/fmc/rte"~id~"/rte/entry["~n~"]/wp"));
			setprop("/aircraft/fmc/active-rte/wp["~n~"]/alt", "-----");

		}

		setprop("/aircraft/fmc/rte"~id~"/active", 1);

		setprop("/aircraft/fmc/active-rte/num", num);

	} else { # Set the route legs to Active RTE

		var num = getprop("/aircraft/fmc/rte"~id~"/legs/num");

		for(var n=0; n<num; n+=1) {

			setprop("/aircraft/fmc/active-rte/wp["~n~"]/id", getprop("/aircraft/fmc/rte"~id~"/legs/wp["~n~"]/wp"));
			setprop("/aircraft/fmc/active-rte/wp["~n~"]/alt", getprop("/aircraft/fmc/rte"~id~"/legs/wp["~n~"]/alt"));

		}

		setprop("/aircraft/fmc/rte"~id~"/active", 1);

		setprop("/aircraft/fmc/active-rte/num", num);

	}

	setprop("/autopilot/route-manager/departure/airport", getprop("/aircraft/fmc/rte"~id~"/origin-arpt"));
	if (getprop("/aircraft/fmc/rte"~id~"/origin-rwy") != "---")
		setprop("/autopilot/route-manager/departure/runway", getprop("/aircraft/fmc/rte"~id~"/origin-rwy"));

	fplnDisp.update();

};

var revert_mods = func(id) { # Erase/Revert Modifications for RTE LEGS CHANGES

	var num = getprop("/aircraft/fmc/active-rte/num");

	for(var n=0; n<num; n+=1) {

		setprop("/aircraft/fmc/rte"~id~"/legs/wp["~n~"]/wp", getprop("/aircraft/fmc/active-rte/wp["~n~"]/id"));
		setprop("/aircraft/fmc/rte"~id~"/legs/wp["~n~"]/alt", getprop("/aircraft/fmc/active-rte/wp["~n~"]/alt"));

	}

	setprop("/aircraft/fmc/rte"~id~"/legs/num", num);

};
