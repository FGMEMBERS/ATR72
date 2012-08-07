var awy2legs = func(id) {

	var tree = "/aircraft/fmc/rte"~id~"/";

	var legs = [];

	var num = getprop(tree~"rte/num");

	if (num > 0) {

		# Go through every single entry in the route

		print("Started AWY conversion");

		for(var n=0; n<(num-1); n+=1) {

			var wp = getprop(tree~"rte/entry["~n~"]/wp"); # Current WP

			var awy = getprop(tree~"rte/entry["~(n+1)~"]/awy"); # Airway from the current WP to the next

			var next_wp = getprop(tree~"rte/entry["~(n+1)~"]/wp"); # Next WP

			print("Checking Waypoint-> "~wp~" with next Airway ("~awy~") pointing to "~next_wp);

			# This section has proper airways and the waypoints must be taken out of the airway and appended to the legs

			if ((awy != nil) and (awy != "") and (awy != "----") and (awy != "DIRECT")) {

				# Here's the really tricky and annoying part- (took me hours to figure it out) we have to start at the wp and look for airway entries from the database that go both ways. Then, we go along both loops separately till 1 of them reaches the next_wp. If none of them reaches the next waypoint, we will ignore the airway altogether and simply use go directly to the next waypoint.

				var awyup = [wp]; # Vector of airways going up from the starting waypoint
				var awydn = [wp]; # Vector of airways going down from the starting waypoint

				var found = 0; # Whether next waypoint is found in either vectors

				var awyup_end = 0; # Whether the line of waypoints up the airway has ended

				var awydn_end = 1; # Whether the line of waypoints down the airway has ended, it can also be used to check if a line of waypoints down the airway exists

				print("Looking for first waypoint up the airway");

				for(var k=0; getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/id") != nil; k+=1) { # Find the waypoint up the airway line

					var db_awy = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/id"); # Airway ID
					var db_wp1 = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/wp1"); # Init Waypoint
					var db_wp2 = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/wp2"); # Final Waypoint

					if (db_awy == awy) {

						if (db_wp1 == wp) { # Check if the waypoint has a match

							append(awyup, db_wp2); # Append the OTHER waypoint to the airway line

							print("Found first waypoint up the airway ->"~db_wp2);

							k = 10000; # To get out of the loop

						}

						if (db_wp2 == wp) { # Check if the other waypoint has a match

							append(awyup, db_wp1); # Append the initial one to the airway line

							print("Found first waypoint up the airway ->"~db_wp1);

							k = 10000; # To get out of the loop

						}

					}

				} # End of Waypoints for loop

				print("Looking for first waypoint down the airway");

				for(var k=0; getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/id") != nil; k+=1) { # Find the waypoint down the airway line

					var db_awy = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/id"); # Airway ID
					var db_wp1 = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/wp1"); # Init Waypoint
					var db_wp2 = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/wp2"); # Final Waypoint

					if (db_awy == awy) {

						if ((db_wp1 == wp) and (db_wp2 != awyup[1])) { # Check if the waypoint has a match

							append(awydn, db_wp2); # Append the OTHER waypoint to the airway line

							awydn_end = 0; # Means that there is a line of waypoints down the airway

							print("Found first waypoint down the airway ->"~db_wp2);

							k = 10000; # To get out of the loop

						}

						if ((db_wp2 == wp) and (db_wp1 != awyup[1])) { # Check if the other waypoint has a match

							append(awydn, db_wp1); # Append the initial one to the airway line

							awydn_end = 0; # Means that there is a line of waypoints down the airway

							print("Found first waypoint down the airway ->"~db_wp1);

							k = 10000; # To get out of the loop

						}

					}

				} # End of waypoints for loop

				print("Starting to look for a line of waypoints UP till the next WP");

				# Airway Up Vector

				var up=0;

				while((found == 0) and (awyup_end == 0)) { # Keep Checking until either the line ends or the waypoint is found

					for(var k=0; getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/id") != nil; k+=1) {

						var db_awy = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/id"); # Airway ID
						var db_wp1 = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/wp1"); # Init Waypoint
						var db_wp2 = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/wp2"); # Final Waypoint

						if (db_awy == awy) { # Look into the airway we've got from the route

							var active = size(awyup);

							# If Waypoint 1 is the previous waypoint in the awyup line

							if ((db_wp1 == awyup[active-1]) and (db_wp2 != awyup[active-2])) { # This forces the loop to check in a straight line and not go back

								# Now check whether we've reached the last waypoint or not

								if (db_wp2 == next_wp) { # This means we've reached the last waypoint

									found = 1; # Set the waypoint found flag

									foreach(var element; awyup) {

										append(legs, element);

									}

									print("Found the next waypoint up the airway!");

									k = 10000; # Escape the for loop

								} else {

									append(awyup, db_wp2);

									print("Added "~db_wp2~" to the Airway List");

								}

							}

							# If Waypoint 2 is the previous waypoint in the awyup line

							if ((db_wp2 == awyup[active-1]) and (db_wp1 != awyup[active-2])) { # This forces the loop to check in a straight line and not go back

								# Now check whether we've reached the last waypoint or not

								if (db_wp1 == next_wp) { # This means we've reached the last waypoint

									found = 1; # Set the waypoint found flag

									foreach(var element; awyup) {

										append(legs, element);

									}

									print("Found the next waypoint up the airway!");

									k = 10000; # Escape the for loop

								} else {

									append(awyup, db_wp1);

									print("Added "~db_wp1~" to the Airway List");

								}

							}

						} # End of airway check

					} # End of DB Airways check for loop

					up+=1;

					if (up>30)	awyup_end = 1; # LOOP COUNTER TO ESC
					
				} # End of Airway Up Check While Loop

				print("Starting to look for a line of waypoints DOWN till the next WP");

				# Airway Down Vector

				var down = 0;

				while((found == 0) and (awydn_end == 0)) { # Keep Checking until either the line ends or the waypoint is found

					for(var k=0; getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/id") != nil; k+=1) {

						var db_awy = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/id"); # Airway ID
						var db_wp1 = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/wp1"); # Init Waypoint
						var db_wp2 = getprop("/database/navdata/awys/_"~substr(awy,0,2)~"/awy["~k~"]/wp2"); # Final Waypoint

						if (db_awy == awy) { # Look into the airway we've got from the route

							var active = size(awydn);

							# If Waypoint 1 is the previous waypoint in the awydn line

							if ((db_wp1 == awydn[active-1]) and (db_wp2 != awydn[active-2])) { # This forces the loop to check in a straight line and not go back

								# Now check whether we've reached the last waypoint or not

								if (db_wp2 == next_wp) { # This means we've reached the last waypoint

									found = 1; # Set the waypoint found flag

									foreach(var element; awydn) {

										append(legs, element);

									}

									print("Found the next waypoint down the airway!");

									k = 10000; # Escape the for loop

								} else {

									append(awydn, db_wp2);

									print("Added "~db_wp1~" to the Airway List");

								}

							}

							# If Waypoint 2 is the previous waypoint in the awydn line

							if ((db_wp2 == awydn[active-1]) and (db_wp1 != awydn[active-2])) { # This forces the loop to check in a straight line and not go back

								# Now check whether we've reached the last waypoint or not

								if (db_wp1 == next_wp) { # This means we've reached the last waypoint

									found = 1; # Set the waypoint found flag

									foreach(var element; awydn) {

										append(legs, element);

									}

									print("Found the next waypoint down the airway!");

									k = 10000; # Escape the for loop

								} else {

									append(awydn, db_wp1);

									print("Added "~db_wp2~" to the Airway List");

								}

							}

						} # End of airway check

					} # End of DB Airways check for loop

					down+=1;

					if(down>30) awydn_end = 1; # LOOP COUNTER TO ESC
					
				} # End of Airway Down Check While Loop

				# Check if the airway is found, if it ISN'T found, then assume direct transition

				if (found == 0) {

					append(legs, wp);

					print("Set Direct");

				}

			} # End of NOT-DIRECT if clause

			# This section means that the transition to next waypoint is DIRECT

			else {

				append(legs, wp);

				print("Set Direct");

			} # End of NOT-DIRECT else clause
			
		} # End of rte entries for loop

		append(legs, getprop(tree~"rte/entry["~(num-1)~"]/wp")); # Append Last waypoint to legs

		for(var m=0; m<size(legs); m+=1) {

			setprop(tree~"legs/wp["~m~"]/wp", legs[m]);
			setprop(tree~"legs/wp["~m~"]/alt", "-----");

		}

		print("Copied Legs to Property Tree");

		setprop(tree~"legs/num", size(legs));

	}

};
