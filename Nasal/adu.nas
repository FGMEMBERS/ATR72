var adu = {
       init : func {
            me.UPDATE_INTERVAL = 0.02;
            me.loopid = 0;
            
            me.reset();
    },
    	update : func {

		# Left ARMED Mode
		
		var hdg = getprop("/aircraft/afcs/hdg-setting");
		
		var hdg_str = "";
		
		if (hdg > 99) {
		
			hdg_str = hdg;
		
		} elsif (hdg > 9) {
		
			hdg_str = "0" ~ hdg;
		
		} else {
		
			hdg_str = "00" ~ hdg;
		
		}
		
		setprop("/instrumentation/adu/left-armed", "HDG " ~ hdg_str);
		
		# Right ARMED Mode
		
		if (getprop("/aircraft/afcs/ver-mode") == "alt") {
		
			setprop("/instrumentation/adu/right-armed", "IAS SEL " ~ getprop("/aircraft/afcs/ias-setting") ~ " KT");
		
		} else {
		
			setprop("/instrumentation/adu/right-armed", "ALT SEL " ~ getprop("/aircraft/afcs/alt-setting") ~ " FT");
		
		}
		
		# Left CAP Mode
		
		if (getprop("/aircraft/afcs/lat-mode") == "hdg") {
		
			if (getprop("aircraft/afcs/bank-limit") == 15) {
			
				setprop("/instrumentation/adu/left-cap", "HDG SEL LO");
			
			} else {
			
				setprop("/instrumentation/adu/left-cap", "HDG SEL HI");
			
			}
		
		} elsif (getprop("/aircraft/afcs/lat-mode") == "nav") {
		
			var current_wp = getprop("/aircraft/fmc/active-rte/current-wp");
			var current_wp_id = getprop("/aircraft/fmc/active-rte/wp[" ~ (current_wp) ~ "]/id");
			
			if (current_wp_id != nil) {
		
				setprop("/instrumentation/adu/left-cap", "NAV -> " ~ current_wp_id);
				
			} else {
			
				setprop("/instrumentation/adu/left-cap", "NAV");
			
			}
		
		} else {
		
			setprop("/instrumentation/adu/left-cap", "APP LOC*");
		
		}
		
		# Right CAP Mode
		
		if (getprop("/aircraft/afcs/lat-mode") != "APP") {
		
			if (getprop("/aircraft/afcs/ver-mode") == "ias") {
		
				setprop("/instrumentation/adu/right-cap", "IAS " ~ getprop("/aircraft/afcs/ias-setting") ~ " KT");
		
			} elsif (getprop("/aircraft/afcs/ver-mode") == "vs") {
		
				setprop("/instrumentation/adu/right-cap", "VS " ~ getprop("/aircraft/afcs/vs-setting") ~ " FPM");
		
			} else {
			
				setprop("/instrumentation/adu/right-cap", "ALT " ~ getprop("/aircraft/afcs/alt-setting") ~ " FT");
			
			}
		
		} else {
		
			setprop("/instrumentation/adu/left-cap", "APP GS*");
		
		}

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
 adu.init();
 print("Advisory Display Unit ...... Initialized");
 });
