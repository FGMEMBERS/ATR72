# AFCS NAV MODE CONTROLLER LOOP
## Important - the AFCS uses GPS[1] for navigation | This will be replaced by a direct course to system in the near future to support multiple wpts with same ID but different locations
## Note that these functions manage both the normal waypoint transition AND Terminal Procedures

var transit = func(lat, lon, accur) {

	var pos_lat = getprop("/position/latitude-deg");
	var pos_lon = getprop("/position/longitude-deg");

	if ((math.abs(lat - pos_lat) <= accur) and (math.abs(lon - pos_lon) <= accur)) return 1;
	else return 0;

};

var limit2 = func (value, limitup, limitdn) {

	if (value >= 0) {
	
		if (value <= limitup)
			return value;
		else
			return limitup;
	
	} elsif (value < 0) {
	
		if (value >= limitdn)
			return value;
		else
			return limitdn;
	
	} else
		return 0;

}

var defl = func(bug = 0, limit = 0) {
      ##var heading = getprop("orientation/heading-magnetic-deg");
      var heading = getprop("orientation/heading-deg");
      var bugDeg = 0;
	  
      while (bug < 0)
       {
       bug += 360;
       }
      while (bug > 360)
       {
       bug -= 360;
       }
      if (bug < limit)
       {
       bug += 360;
       }
      if (heading < limit)
       {
       heading += 360;
       }
      # bug is adjusted normally
      if (math.abs(heading - bug) < limit)
       {
       bugDeg = heading - bug;
       }
      elsif (heading - bug < 0)
       {
       # bug is on the far right
       if (math.abs(heading - bug + 360 >= 180))
        {
        bugDeg = -limit;
        }
       # bug is on the far left
       elsif (math.abs(heading - bug + 360 < 180))
        {
        bugDeg = limit;
        }
       }
      else
       {
       # bug is on the far right
       if (math.abs(heading - bug >= 180))
        {
        bugDeg = -limit;
        }
       # bug is on the far left
       elsif (math.abs(heading - bug < 180))
        {
        bugDeg = limit;
        }
       }

      return bugDeg;
    }

var afcs_nav = {
       init : func {
            me.UPDATE_INTERVAL = 0.1;
            me.loopid = 0;

            me.rtes = [1,2]; # Add on more if necessary
            
            me.reset();
    },
    	update : func {

    	foreach(var rte; me.rtes) {

			var sid = "/aircraft/fmc/rte"~rte~"/dep/";
			var star = "/aircraft/fmc/rte"~rte~"/arr/";

			# Run this loop only if the lateral navigation mode is set and the route is active

			if (getprop("/aircraft/afcs/logic/lat-nav") and getprop("/aircraft/fmc/rte"~rte~"/active")) {

				var curr_wp = getprop("/aircraft/fmc/active-rte/current-wp");

				# Fly Standard Instrument Departure (SID)

				if ((curr_wp == 0) and (getprop(sid~"wpts/num") > 0) and (getprop(sid~"current-wp") < getprop(sid~"wpts/num"))) {

					var curr_sidWP = getprop(sid~"current-wp");

					if((getprop(sid~"wpts/wp["~curr_sidWP~"]/lat-deg") == 0) and (getprop(sid~"wpts/wp["~curr_sidWP~"]/lat-deg") == 0)) {

						curr_sidWP += 1;
						setprop("/aircraft/fmc/active-rte/current-wp", curr_sidWP);

					} else {

						var wp = geo.Coord.new();

						wp.set_latlon(getprop(sid~"wpts/wp["~curr_sidWP~"]/lat-deg"), getprop(sid~"wpts/wp["~curr_sidWP~"]/lon-deg"));

						var pos = geo.aircraft_position();

						var brg = pos.course_to(wp);

						var deflection = -1 * defl(brg, 180);

						setprop("aircraft/afcs/nav-error-deg", deflection);

						var accur_str = getprop("/aircraft/fmc/gps/accur");

						var accur = 0.02;

						if (accur_str == "HI") accur = 0.005;

						if ((getprop(sid~"wpts/wp["~curr_sidWP~"]/lat-deg") != nil) and (getprop(sid~"wpts/wp["~curr_sidWP~"]/lon-deg") != nil)) {

							if (transit(getprop(sid~"wpts/wp["~curr_sidWP~"]/lat-deg"), getprop(sid~"wpts/wp["~curr_sidWP~"]/lon-deg"), accur)) {

								setprop(sid~"current-wp", getprop(sid~"current-wp") + 1);

							}

						}

					}

				}

				# Fly Active Route

				elsif (curr_wp <= getprop("/aircraft/fmc/active-rte/num")) {

					var curr_wp_id = getprop("/aircraft/fmc/active-rte/wp["~curr_wp~"]/id");

					# Get Waypoint Data
					
					var wpt = gpsSearchAll(curr_wp_id)[0];

					var deflection = -1 * defl(wpt.brg, 60);

					setprop("aircraft/afcs/nav-error-deg", deflection);

					# Waypoint Transition

					var accur_str = getprop("/aircraft/fmc/gps/accur");

					var accur = 0.02;

					if (accur_str == "HI") accur = 0.005;

					if ((wpt.lat != nil) and (wpt.lon != nil)) {

						if (transit(wpt.lat, wpt.lon, accur)) {

							setprop("/aircraft/fmc/active-rte/current-wp", getprop("/aircraft/fmc/active-rte/current-wp") + 1);

						}

					}

				}

				# Fly Standard Arrival (STAR)

				elsif ((curr_wp == getprop("/aircraft/fmc/active-rte/num")) and (getprop(star~"wpts/num") > 0) and (getprop(star~"current-wp") < getprop(star~"wpts/num"))) {

					var curr_starWP = getprop(star~"current-wp");

					if((getprop(star~"wpts/wp["~curr_starWP~"]/lat-deg") == 0) and (getprop(star~"wpts/wp["~curr_starWP~"]/lat-deg") == 0)) {

						curr_starWP += 1;
						setprop(star~"current-wp", curr_starWP);

					} else {

						var wp = geo.Coord.new();

						wp.set_latlon(getprop(star~"wpts/wp["~curr_starWP~"]/lat-deg"), getprop(star~"wpts/wp["~curr_starWP~"]/lon-deg"));

						var pos = geo.aircraft_position();

						var brg = pos.course_to(wp);

						var deflection = -1 * defl(brg, 180);

						setprop("aircraft/afcs/nav-error-deg", deflection);

						var accur_str = getprop("/aircraft/fmc/gps/accur");

						var accur = 0.02;

						if (accur_str == "HI") accur = 0.005;

						if ((getprop(star~"wpts/wp["~curr_starWP~"]/lat-deg") != nil) and (getprop(star~"wpts/wp["~curr_starWP~"]/lon-deg") != nil)) {

							if (transit(getprop(star~"wpts/wp["~curr_starWP~"]/lat-deg"), getprop(star~"wpts/wp["~curr_starWP~"]/lon-deg"), accur)) {

								setprop(star~"current-wp", getprop(star~"current-wp") + 1);

							}

						}

					}

				} else {

					setprop("/aircraft/fmc/rte"~rte~"/active", 0); # De-activate the route
					setprop("/aircraft/fmc/active-rte/current-wp", 0);

				}
				
			}

    	}

    	# Temporary nasal controller for Altitude

    	# if (getprop("/aircraft/afcs/logic/ver-alt")) {

			if (getprop("/aircraft/afcs/alt-vs-up") != nil) {

				var diff = getprop("/aircraft/afcs/alt-setting") - getprop("/instrumentation/altimeter/indicated-altitude-ft"); # Target - Indicated

				var vs = limit2(diff /10, getprop("/aircraft/afcs/alt-vs-up"), -25);

				setprop("/autopilot/internal/target-climb-rate-fps", vs);

			} else {

				setprop("/autopilot/internal/target-climb-rate-fps", 0);

			}

    	# }

	},

        reset : func {
            me.loopid += 1;
            me._loop_(me.loopid);
    },
        _loop_ : func(id) {
            id == me.loopid or return;
            me.update();
            settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }

};

setlistener("sim/signals/fdm-initialized", func
 {
 afcs_nav.init();
 print("ATR72 Navigation System .... Initialized");
 });
