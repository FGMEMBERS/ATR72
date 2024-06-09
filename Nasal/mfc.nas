var mfc1b_reset_timer = maketimer(2.5, func {
    setprop("/aircraft/mfc_1b/online", 1);
    setprop("/aircraft/mfc_1b/resetting", 0);
});
mfc1b_reset_timer.singleShot = 1;
mfc1b_reset_timer.simulatedTime = 1;
var mfc2b_reset_timer = maketimer(2.5, func {
    setprop("/aircraft/mfc_2b/online", 1);
    setprop("/aircraft/mfc_2b/resetting", 0);
});
mfc2b_reset_timer.singleShot = 1;
mfc2b_reset_timer.simulatedTime = 1;

var mfc1a_reset_timer = maketimer(2.5, func {
    setprop("/aircraft/mfc_1a/online", 1);
    setprop("/aircraft/mfc_1a/resetting", 0);
    setprop("/aircraft/mfc_1b/online", 0);
    setprop("/aircraft/mfc_1b/resetting", 1);
    mfc1b_reset_timer.start();
});
mfc1a_reset_timer.singleShot = 1;
mfc1a_reset_timer.simulatedTime = 1;
var mfc2a_reset_timer = maketimer(2.5, func {
    setprop("/aircraft/mfc_2a/online", 1);
    setprop("/aircraft/mfc_2a/resetting", 0);
    setprop("/aircraft/mfc_2b/online", 0);
    setprop("/aircraft/mfc_2b/resetting", 1);
    mfc2b_reset_timer.start();
});
mfc2a_reset_timer.singleShot = 1;
mfc2a_reset_timer.simulatedTime = 1;

setprop("/aircraft/mfc/blink", 0);
var blink_timer = maketimer(0.25, func {
    var last = getprop("/aircraft/mfc/blink");
    setprop("/aircraft/mfc/blink", !last);
    setprop("/aircraft/mfc_1a/reset_blink", !last and getprop("/aircraft/mfc_1a/resetting"));
    setprop("/aircraft/mfc_1b/reset_blink", !last and getprop("/aircraft/mfc_1b/resetting"));
    setprop("/aircraft/mfc_2a/reset_blink", !last and getprop("/aircraft/mfc_2a/resetting"));
    setprop("/aircraft/mfc_2b/reset_blink", !last and getprop("/aircraft/mfc_2b/resetting"));
});
blink_timer.start();

setprop("/aircraft/mfc_1a/online", 0);
setprop("/aircraft/mfc_1a/resetting", 0);
setprop("/aircraft/mfc_2a/online", 0);
setprop("/aircraft/mfc_2a/resetting", 0);

var last_state = 0;

setlistener("/systems/electric/outputs/avionics", func {
    if (getprop("/systems/electric/outputs/avionics") != last_state) {
        if (getprop("/systems/electric/outputs/avionics") == 1) {
            setprop("/aircraft/mfc_1a/online", 0);
            setprop("/aircraft/mfc_1a/resetting", 1);
            setprop("/aircraft/mfc_2a/online", 0);
            setprop("/aircraft/mfc_2a/resetting", 1);
            mfc1a_reset_timer.start();
            mfc2a_reset_timer.start();
        } else {
            setprop("/aircraft/mfc_1a/online", 0);
            setprop("/aircraft/mfc_1a/resetting", 0);
            setprop("/aircraft/mfc_2a/online", 0);
            setprop("/aircraft/mfc_2a/resetting", 0);
        }
    }
    last_state = getprop("/systems/electric/outputs/avionics");
});
