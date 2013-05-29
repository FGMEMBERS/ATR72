var pos_string = func(lat, lon) {

        var lat_deg = math.abs(int(lat));
        var lon_deg = math.abs(int(lon));

        var lat_minP = int(100 * (lat - lat_deg));
        var lon_minP = int(100 * (lon - lon_deg));

        var lat_secP = int(10000 * (lat - (lat_deg + (lat_minP/100))));
        var lon_secP = int(10000 * (lon - (lon_deg + (lon_minP/100))));

        var lat_min = math.abs(int(lat_minP * 60/100));
        var lon_min = math.abs(int(lon_minP * 60/100));

        var lat_sec = math.abs(int(lat_secP * 60/100));
        var lon_sec = math.abs(int(lon_secP * 60/100));

        var lat_dir = "N";
        var lon_dir = "E";

        if(lat < 0) lat_dir = "S";
        if(lon < 0) lon_dir = "W";

        var lat_string = lat_deg ~ "*" ~ lat_min ~ " " ~ lat_sec ~ " " ~ lat_dir;
        var lon_string = lon_deg ~ "*" ~ lon_min ~ " " ~ lon_sec ~ " " ~ lon_dir;

        return lat_string ~ " " ~ lon_string;

};

fmcPages["srcWP"] = {

        init: func(mode, rte, n, ident) {

                me.addMode = mode;
                me.rteID = rte;
                me.index = n; # Used only if mode is "update"
                me.ident = ident;
        
                clearScreen();
                ActivePage = fmcPages["srcWP"];
        
                var results = gpsSearchAll(ident);
                me.results = results;

                if (size(results) > 1) {
                                
                        setprop("/aircraft/fmc/srcWP/num", size(results));
                        setprop("/aircraft/fmc/srcWP/first", 0);
                        
                        for(var n=0; n<size(results); n+=1) {
                        
                                var tree = "/aircraft/fmc/srcWP/wpDisp[" ~ n ~ "]/";

                                setprop(tree~"Llabel", results[n].name);
                                setprop(tree~"Rlabel", results[n].brg ~ "*   " ~ results[n].dist ~ " NM");
                                setprop(tree~"Rvalue", pos_string(results[n].lat, results[n].lon));
                        
                        }

                        clearInput();

                        me.updateDisplay();

                } else {

                        me.confirmWP(0);

                        clearInput();

                }
        
        },

        updateDisplay: func() {
        
        		setprop("/instrumentation/fmc/exec-lt", 0);
				modcmd.hide();

                title.setText("SELECT DESIRED WPT").setColor(blue);

                values[5].setText("<CANCEL").setColor(green);

                var pages = int(getprop("/aircraft/fmc/srcWP/num") / 5);
                if (getprop("/aircraft/fmc/srcWP/num") > pages) pages += 1;

                var cur_page = int((getprop("/aircraft/fmc/srcWP/first")/5) + 1);

                me.first = getprop("/aircraft/fmc/srcWP/first");
                me.num = getprop("/aircraft/fmc/srcWP/num");

                pageNo.setText(cur_page~"/"~pages).setColor(blue);

                for(var n=0; n<5; n+=1) {
                
                        var result_id = me.first + n;
                        var tree = "/aircraft/fmc/srcWP/wpDisp[" ~ result_id ~ "]/";
                        
                        if (result_id < me.num) {
                        
                                labels[n].setText(getprop(tree~"Llabel")).setColor(white);
                                labels[12 + n].setText(getprop(tree~"Rlabel")).setColor(white);
                                values[12 + n].setText(getprop(tree~"Rvalue")).setColor(white);
                        
                        } else {

                                labels[n].setText("").setColor(white);
                                labels[12 + n].setText("").setColor(white);
                                values[12 + n].setText("").setColor(white);
                        
                        }
                
                }

        },

        confirmWP: func(n) {

                if(size(me.results) > 0) {

                        var ident = me.results[n].ident;

                        if (me.addMode == "add") { # ADD WP

                                var num = getprop("/aircraft/fmc/rte"~me.rteID~"/rte/num");

                                setprop("/aircraft/fmc/rte"~me.rteID~"/rte/entry["~num~"]/wp", ident);
                                setprop("/aircraft/fmc/rte"~me.rteID~"/rte/num", getprop("/aircraft/fmc/rte"~me.rteID~"/rte/num") + 1);

                                if (getprop("/aircraft/fmc/rte"~me.rteID~"/rte/entry["~num~"]/awy") == "----") {

                                        setprop("/aircraft/fmc/rte"~me.rteID~"/rte/entry["~num~"]/awy", "DIRECT");

                                }

                                setprop("/aircraft/fmc/rte"~me.rteID~"/rte/entry["~(num+1)~"]/wp", "-----");
                                setprop("/aircraft/fmc/rte"~me.rteID~"/rte/entry["~(num+1)~"]/awy", "----");

                        } else { # UPDATE WP

                                var ident = me.results[n].ident;

                                setprop("/aircraft/fmc/rte"~me.rteID~"/rte/entry["~me.index~"]/wp", ident);

                        }

                } else {

                        setInput("ERROR: NOT IN DATABASE");

                }

                GoToPage("rte"~me.rteID);

        },

        l1: func() {

                me.confirmWP(me.first);

        },

        l2: func() {

                me.confirmWP(me.first + 1);

        },

        l3: func() {

                me.confirmWP(me.first + 2);

        },

        l4: func() {

                me.confirmWP(me.first + 3);

        },

        l5: func() {

                me.confirmWP(me.first + 4);

        },

        l6: func() {

                GoToPage("rte"~me.rteID);

        },

        next: func() {

                if(me.first + 5 < me.num) {
                
                        me.first += 5;
                        setprop("/aircraft/fmc/srcWP/first", me.first);
                        me.updateDisplay();
                
                }

        },

        prev: func() {

                if (me.first > 0) {
                
                        me.first -= 5;
                        setprop("/aircraft/fmc/srcWP/first", me.first);
                        me.updateDisplay();
                
                }

        }       

};

# Route Management System Class

var rte = {

        n: 0,
        loadAwys: func(index) {
        
                var location = "/database/navdata/awys/_" ~ index ~ "/";
                var filename = getprop("/sim/aircraft-dir") ~ "/Database/NavData/Airways/" ~ index ~ ".xml";

                io.read_properties(filename, location);
        
        },
        addAwy: func(name) {
        
                # First check if the airway exists
                
                var index = substr(name, 0, 2);
                
                me.loadAwys(index);
                
                var found = 0;
                var start = 0;
                
                var rte_num = getprop("/aircraft/fmc/rte"~me.n~"/rte/num");
                var prev_wp = "---";
                
                if (rte_num > 0)
                        var prev_wp = getprop("/aircraft/fmc/rte"~me.n~"/rte/entry[" ~ (rte_num - 1) ~ "]/wp");
                        
                
                for (var n=0; getprop("/database/navdata/awys/_" ~ index ~ "/awy[" ~ n ~ "]/id") != nil; n+=1) {
                
                        if (getprop("/database/navdata/awys/_" ~ index ~ "/awy[" ~ n ~ "]/id") == name) {
                        
                                found = 1;
                                
                                if ((getprop("/database/navdata/awys/_" ~ index ~ "/awy[" ~ n ~ "]/wp1") == prev_wp) or (getprop("/database/navdata/awys/_" ~ index ~ "/awy[" ~ n ~ "]/wp2") == prev_wp)) {
                                
                                        start = 1;
                                
                                }
                        
                        }
                
                }
                
                if ((found == 1) and (start == 1)) {
                
                        # Accept Airway Entry and add it if Found
                        var rte_num = getprop("/aircraft/fmc/rte"~me.n~"/rte/num");
                        setprop("/aircraft/fmc/rte"~me.n~"/rte/entry["~rte_num~"]/awy", name);
                        setprop("/aircraft/fmc/rte"~me.n~"/rte/entry["~rte_num~"]/wp", "-----");
                        clearInput();
                        
                
                } elsif (found == 1) {
                
                        setInput("ERROR: WRONG INIT WAYPOINT");
                        print("[FMC] Airway "~name~" does not start or fly through " ~prev_wp~ ". Make sure you've entered the correct Airway or your flightplan is correct.");
                
                } else {
                
                        # This means the airway doesn't exist in the database
                        
                        setInput("ERROR: NOT IN DATABASE");
                        print("[FMC] Airway "~name~" Not found in database, please load a valid database if you have not done so already. We recommend you use the latest version of 'OmegaDat' from theomegahangar.yolasite.com");
                
                }               
        
        },
        updateAwy: func(id, name) {
        
                var index = substr(name, 0, 2);
                
                me.loadAwys(index);
                
                var found = 0;
                var start = 0;
                
                var prev_wp = getprop("/aircraft/fmc/rte"~me.n~"/rte/entry[" ~ (id - 1) ~ "]/wp");
                
                for (var n=0; getprop("/database/navdata/awys/_" ~ index ~ "/awy[" ~ n ~ "]/id") != nil; n+=1) {
                
                        if (getprop("/database/navdata/awys/_" ~ index ~ "/awy[" ~ n ~ "]/id") == name) {
                        
                                found = 1;
                                
                                if ((getprop("/database/navdata/awys/_" ~ index ~ "/awy[" ~ n ~ "]/wp1") == prev_wp) or (getprop("/database/navdata/awys/_" ~ index ~ "/awy[" ~ n ~ "]/wp2") == prev_wp)) {
                                
                                        start = 1;
                                
                                }
                        
                        }
                
                }
                
                if ((found == 1) and (start == 1)) {
                
                        # Accept Airway Entry and update if Found
                        setprop("/aircraft/fmc/rte"~me.n~"/rte/entry["~id~"]/awy", name);
                        clearInput();
                        
                
                } elsif (found == 1) {
                
                        setInput("ERROR: WRONG INIT WAYPOINT");
                        print("[FMC] Airway "~name~" does not start or fly through " ~prev_wp~ ". Make sure you've entered the correct Airway or your flightplan is correct.");
                
                } else {
                
                        # This means the airway doesn't exist in the database
                        
                        setInput("ERROR: NOT IN DATABASE");
                        print("[FMC] Airway "~name~" Not found in database, please load a valid database if you have not done so already. We recommend you use the latest version of 'OmegaDat' from theomegahangar.yolasite.com");
                
                }       
        
        },
        addWP: func(name) {
        
                fmcPages["srcWP"].init("add", me.n, 0, name);
        
        },
        updateWP: func(id, name) {
        
                fmcPages["srcWP"].init("update", me.n, id, name);
        
        },
        new: func(index) {
        
                var m = {parents:[rte]};
                
                m.n = index;
                
                return m;
        
        }

};

var rte1 = rte.new(1);
var rte2 = rte.new(2);

var clearRte = func(id) {

        var tree = "/aircraft/fmc/rte"~id~"/";

        setprop(tree~"origin-arpt", "----");
        setprop(tree~"origin-rwy", "---");
        setprop(tree~"dest-arpt", "----");
        setprop(tree~"dest-rwy", "---");
        setprop(tree~"flt-no", "-------");
        setprop(tree~"co-rte", "----------");

        for(var n=0; n<getprop(tree~"rte/num"); n+=1) {

                setprop(tree~"rte/entry["~n~"]/wp", "-----");
                setprop(tree~"rte/entry["~n~"]/awy", "----");

        }

        setprop(tree~"rte/num", 0);
        setprop(tree~"rte/first", 0);

        for(var n=0; n<getprop(tree~"legs/num"); n+=1) {

                setprop(tree~"legs/wp["~n~"]/wp", "-----");
                setprop(tree~"legs/wp["~n~"]/alt", "-----");

        }

        setprop(tree~"legs/num", 0);
        setprop(tree~"legs/first", 0);

        for(var n=0; n<getprop(tree~"legs/num"); n+=1) {

                setprop(tree~"legs/wp["~n~"]/wp", "-----");
                setprop(tree~"legs/wp["~n~"]/alt", "-----");

        }
        

};
