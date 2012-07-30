var fmc = "/instrumentation/fmc/";

# Define General FMC Display Variables Class (contains value and color)

var fmcDisp = {
	value: "",
	color: "white", # white, green, magenta, yellow, blue
	new: func(arg1, arg2) {
	
		var t = {parents:[supplier]};
		
		t.value = arg1;
		t.color = arg2;
		
		return t;
	
	}
};

# Initialize ATR Specific FMC Display

var fmcDispLayout = {

	title: fmcDisp.new("", "white"),
	
	label: [fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white")],
	
	value: [fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white"), fmcDisp.new("", "white")],
	
	# FMC Display Functions
	
	setTitle: func(value, color) {
	
		me.title.value = value;
		me.title.color = color;
	
	},
	
	setLabel: func(n, value, color) {
	
		me.label[n].value = value;
		me.label[n].color = color;
		
	},
	
	setValue: func(n, value, color) {
	
		me.value[n].value = value;
		me.value[n].color = color;
		
	},
	
	clearPage: func() {
	
		me.title.value = "";
		me.title.color = "white";
		
		for (var n=0; n<18; n+=1) {
		
			me.label[n].value = "";
			me.label[n].color = "white";
			me.value[n].value = "";
			me.value[n].color = "white";
		
		}
	
	}

};

# Function to Update Display from Nasal Hash into the property tree for the CDU

var updateDispProps = func() {

	setprop(fmc~ "disp/title/value", fmcDispLayout.title.value);
	setprop(fmc~ "disp/title/color", fmcDispLayout.title.color);
	
	for(var n = 0; n < 18; n+=1) {
	
		setprop(fmc~ "disp/label[" ~ n ~ "]/value", fmcDispLayout.label[n].value);
		setprop(fmc~ "disp/label[" ~ n ~ "]/color", fmcDispLayout.label[n].color);
		
		setprop(fmc~ "disp/value[" ~ n ~ "]/value", fmcDispLayout.value[n].value);
		setprop(fmc~ "disp/value[" ~ n ~ "]/color", fmcDispLayout.value[n].color);
	
	}
	
}

# ATR FMC Display Test

var runDispTest = func() {

	fmcDispLayout.setTitle("FMC Display Test", "white");
	
	for (var n = 0; n < 18; n+=1) {
	
		fmcDispLayout.setLabel(n, "Label No. " ~ n, "blue");
		fmcDispLayout.setValue(n, "Value No. " ~ n, "blue");
	
	}

}

# Clear Input Funciton

var clearInput = func() {

	setprop(fmc~ "input", "");

};

var fmcPage = {

	pageName: "",
	initDisplay: func() { 
	
		fmcDispLayout.clearPage();
	
	},
	l1: func() { },
	l2: func() { },
	l3: func() { },
	l4: func() { },
	l5: func() { },
	l6: func() { },
	r1: func() { },
	r2: func() { },
	r3: func() { },
	r4: func() { },
	r5: func() { },
	r6: func() { },
	exec: func() { },
	new: func(name, init, l1, l2, l3, l4, l5, l6, r1, r2, r3, r4, r5, r6, exec) {
	
		var t = {parents:[supplier]};
		
		t.pageName = name;
		t.initDisplay = init;
		t.l1 = l1;
		t.l2 = l2;
		t.l3 = l3;
		t.l4 = l4;
		t.l5 = l5;
		t.l6 = l6;
		t.r1 = r1;
		t.r2 = r2;
		t.r3 = r3;
		t.r4 = r4;
		t.r5 = r5;
		t.r6 = r6;
		t.exec = exec;
		
		return t;
	
	}

};
