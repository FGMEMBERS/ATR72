var fmc = "/instrumentation/fmc/";

# Clear Input Funciton

var clearInput = func() {

	setprop(fmc~ "input", "");

};

# Set a value to the input

var setInput = func(inp) {

	setprop(fmc~ "input", inp);

};

# Initialize Empty Hashes (pages and Active Page)

var fmcPages = {};
var ActivePage = {};

var GoToPage = func(page) {

	setprop(fmc~ "page", page);
	clearScreen();
	fmcPages[page].initDisplay();
	ActivePage = fmcPages[page];

};

print("Flight Management Computer . Initialized");
