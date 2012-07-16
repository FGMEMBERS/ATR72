var brakes_loop = {
       init : func {
            me.UPDATE_INTERVAL = 0.05;
            me.loopid = 0;
            
            me.reset();
    },
    	update : func {
    	
    	################ BRAKE SYSTEM ################
    	
    	# Manual Brakes Pressure (and Accumulator)
    	
    	brakes.pressurize();
		
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
 brakes_loop.init();
 });
