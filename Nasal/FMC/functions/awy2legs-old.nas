var awy2legs = func(id) {

	var tree = "/aircraft/fmc/rte"~id~"/rte/";

	var num = getprop(tree~ "num");

	var legs = [];

	for(var n=0; n<num; n+=1) {

		var wp = getprop(tree~ "entry["~n~"]/wp");

		var awy = getprop(tree~ "entry["~(n+1)~"]/awy");

		var next_wp = getprop(tree~ "entry["~(n+1)~"]/wp");

		if ((awy != "DIRECT") and (awy != "----") and (awy != nil)) {

			# This means that there is a valid airway here

			var awyup = [wp]; # Line of Waypoints Up the airway
			var awydn = [wp]; # Line of Waypoints Down the airway

			# Get Starting Points

			for(var m=0; getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/id") != nil; m+=1) {

				if ((getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/id") == awy) and ((getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") == wp) or (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2") == wp))) {

					if (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") == wp) {

						if (size(awyup) == 1) {

							append(awyup, getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2"));

						} else {

							append(awydn, getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2"));

						}

					} else {

						if (size(awyup) == 1) {

							append(awyup, getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1"));

						} else {

							append(awydn, getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1"));

						}

					}

				}

			}

			# Form a loop till the next waypoint if found

			# This one's up the line of waypoints in the airway

			var found = 0;

			var awyup_end = 0;

			while(awyup_end == 0) {

				var active = size(awyup);

				for(var m=0; getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/id") != nil; m+=1) {

					awyup_end = 1;

					if ((getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/id") == awy) and ((getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") == awyup[active-1]) or (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2") == awyup[active-1])) and (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") != awyup[active-2]) and (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2") != awyup[active-2])) {

						awyup_end = 0;

						if (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") == awyup[active-1]) {

							if (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2") == next_wp) {

								foreach(var wp; awyup) {

									append(legs, wp);
									awyup_end = 1;
									found = 1;

								}

							} else {

								append(awyup, getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2"));

							}

						} else {

							if (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") == next_wp) {

								foreach(var wp; awyup) {

									append(legs, wp);
									awyup_end = 1;
									found = 1;

								}

							} else {

								append(awyup, getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1"));

							}

						}

					}

				}

			}

			# And this one's down the line of waypoints in the airway if it exists

			if ((size(awydn) > 1) and (found == 0)) {

				var awydn_end = 0;

				while(awydn_end == 0) {

					var active = size(awydn);

					for(var m=0; getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/id") != nil; m+=1) {

						awydn_end = 1;

						if ((getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/id") == awy) and ((getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") == awydn[active-1]) or (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2") == awydn[active-1])) and (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") != awydn[active-2]) and (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2") != awydn[active-2])) {

							awydn_end = 0;

							if (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") == awydn[active-1]) {

								if (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2") == next_wp) {

									foreach(var wp; awydn) {

										append(legs, wp);
										awydn_end = 1;
										found = 1;

									}

								} else {

									append(awydn, getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp2"));

								}

							} else {

								if (getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1") == next_wp) {

									foreach(var wp; awydn) {

										append(legs, wp);
										awydn_end = 1;
										found = 1;

									}

								} else {

									append(awydn, getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~m~"]/wp1"));

								}

							}

						}

					}

				}

			}

			if (found == 0) {

				append(legs, wp);

			}

		} else {

			append(legs, wp);

		}

	}

	var n = 0;

	for(var m = 0; m < size(awyup); m+=1) {

		setprop("/aircraft/fmc/awyUpChk/wp[" ~m~ "]", awyup[m]);

	}

	for(var m = 0; m < size(awydn); m+=1) {

		setprop("/aircraft/fmc/awyDnChk/wp[" ~m~ "]", awydn[m]);

	}

	foreach(var leg; legs) {

		setprop("/aircraft/fmc/rte"~id~"/legs/wp[" ~n~ "]/wp", leg);
		setprop("/aircraft/fmc/rte"~id~"/legs/wp[" ~n~ "]/alt", "-----");

		n += 1;

	}

	setprop("/aircraft/fmc/rte"~id~"/legs/num", n);

};
