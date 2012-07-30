var fmc = "/instrumentation/fmc/";
var fmcPages = [];

# Clear Input Funciton

var clearInput = func() {

	setprop(fmc~ "input", "");

};

# Set a value to the input

var setInput = func(inp) {

	setprop(fmc~ "input", inp);

};


