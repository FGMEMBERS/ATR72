var electrical = {
    init : func {
        me.UPDATE_INTERVAL = 0.02;
        me.loopid = 0;

        me.reset();
    },
    update : func {
        var ext_pwr = getprop("/controls/elec_panel/ext-pwr");
        var dc_gen_1_ok = getprop("/engines/engine/n1") > 61.5 and getprop("/controls/elec_panel/DCgen1") and !ext_pwr;
        var dc_gen_2_ok = getprop("/engines/engine[1]/n1") > 61.5 and getprop("/controls/elec_panel/DCgen2") and !ext_pwr;

        # DC BUS 1
        if (dc_gen_1_ok) {
            setprop("/systems/electric/elec-buses/dc-bus1/volts", 28);
            setprop("/systems/electric/elec-buses/dc-bus1/amps", 600);
        } elsif (ext_pwr) {
            setprop("/systems/electric/elec-buses/dc-bus1/volts", 28);
            setprop("/systems/electric/elec-buses/dc-bus1/amps", 600);
        } elsif (getprop("/controls/elec_panel/dc-btc") and getprop("/systems/electric/elec-buses/dc-bus2/volts") >= getprop("/systems/electric/elec-buses/dc-bus1/volts")) {
            setprop("/systems/electric/elec-buses/dc-bus1/volts", getprop("/systems/electric/elec-buses/dc-bus2/volts"));
            setprop("/systems/electric/elec-buses/dc-bus1/amps", getprop("/systems/electric/elec-buses/dc-bus2/amps"));
        } else {
            setprop("/systems/electric/elec-buses/dc-bus1/volts", 0);
            setprop("/systems/electric/elec-buses/dc-bus1/amps", 0);
        }

        # DC BUS 2
        if (dc_gen_2_ok) {
            setprop("/systems/electric/elec-buses/dc-bus2/volts", 28);
            setprop("/systems/electric/elec-buses/dc-bus2/amps", 600);
        } elsif (getprop("/controls/elec_panel/dc-btc") and getprop("/systems/electric/elec-buses/dc-bus1/volts") >= getprop("/systems/electric/elec-buses/dc-bus2/volts")) {
            setprop("/systems/electric/elec-buses/dc-bus2/volts", getprop("/systems/electric/elec-buses/dc-bus1/volts"));
            setprop("/systems/electric/elec-buses/dc-bus2/amps", getprop("/systems/electric/elec-buses/dc-bus1/amps"));
        } else {
            setprop("/systems/electric/elec-buses/dc-bus2/volts", 0);
            setprop("/systems/electric/elec-buses/dc-bus2/amps", 0);
        }

        # AC BUS 1
        if (getprop("/systems/electric/elec-buses/dc-bus1/volts") > 24) {
            setprop("/systems/electric/elec-buses/ac-bus1/volts", getprop("/systems/electric/elec-buses/dc-bus1/volts"));
            setprop("/systems/electric/elec-buses/ac-bus1/amps", getprop("/systems/electric/elec-buses/dc-bus1/amps"));
        } else {
            setprop("/systems/electric/elec-buses/ac-bus1/volts", 0);
            setprop("/systems/electric/elec-buses/ac-bus1/amps", 0);
        }

        # AC BUS 2
        if (getprop("/systems/electric/elec-buses/dc-bus2/volts") > 24) {
            setprop("/systems/electric/elec-buses/ac-bus2/volts", getprop("/systems/electric/elec-buses/dc-bus2/volts"));
            setprop("/systems/electric/elec-buses/ac-bus2/amps", getprop("/systems/electric/elec-buses/dc-bus2/amps"));
        } else {
            setprop("/systems/electric/elec-buses/ac-bus2/volts", 0);
            setprop("/systems/electric/elec-buses/ac-bus2/amps", 0);
        }

        # ACW BUS 1
        if (getprop("/engines/engine/thruster/prop_rpm") > 350 and getprop("/controls/elec_panel/ACWgen1")) {
            setprop("/systems/electric/elec-buses/acw-bus1/volts", 115);
            setprop("/systems/electric/elec-buses/acw-bus1/amps", 400);
        } else {
            setprop("/systems/electric/elec-buses/acw-bus1/volts", 0);
            setprop("/systems/electric/elec-buses/acw-bus1/amps", 0);
        }

        # ACW BUS 2
        if (getprop("/engines/engine[1]/thruster/prop_rpm") > 350 and getprop("/controls/elec_panel/ACWgen2")) {
            setprop("/systems/electric/elec-buses/acw-bus2/volts", 115);
            setprop("/systems/electric/elec-buses/acw-bus2/amps", 400);
        } else {
            setprop("/systems/electric/elec-buses/acw-bus2/volts", 0);
            setprop("/systems/electric/elec-buses/acw-bus2/amps", 0);
        }

        # HOT MAIN BAT BUS
        if (getprop("/systems/electric/elec-buses/dc-bus1/volts") > 24) {
            setprop("/systems/electric/elec-buses/hot-main-bat-bus/volts", getprop("/systems/electric/elec-buses/dc-bus1/volts"));
            setprop("/systems/electric/elec-buses/hot-main-bat-bus/amps", getprop("/systems/electric/elec-buses/dc-bus1/amps"));
        } elsif (getprop("/controls/elec_panel/battery") == 1) {
            setprop("/systems/electric/elec-buses/hot-main-bat-bus/volts", 24);
            setprop("/systems/electric/elec-buses/hot-main-bat-bus/amps", 43);
        } else {
            setprop("/systems/electric/elec-buses/hot-main-bat-bus/volts", 0);
            setprop("/systems/electric/elec-buses/hot-main-bat-bus/amps", 0);
        }

        # DC ESS BUS
        if (getprop("/systems/electric/elec-buses/hot-main-bat-bus/volts") > 12) {
            setprop("/systems/electric/outputs/avionics", 1);
            setprop("/systems/electrical/outputs/avionics", getprop("/systems/electric/elec-buses/hot-main-bat-bus/volts"));
        } else {
            setprop("/systems/electric/outputs/avionics", 0);
            setprop("/systems/electrical/outputs/avionics", 0);
        }

        # UTLY BUS 1
        setprop("/systems/electric/util-volts", 0);
        setprop("/systems/electric/util-amps", 0);

        # DC BUS TIE CONNECTOR
        if (ext_pwr or (dc_gen_1_ok and !dc_gen_2_ok) or (!dc_gen_1_ok and dc_gen_2_ok))
            setprop("/controls/elec_panel/dc-btc", 1);
        else
            setprop("/controls/elec_panel/dc-btc", 0);
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

setlistener("sim/signals/fdm-initialized", func {
    electrical.init();
    print("ATR72 Electrical System ..... Initialized");
});
