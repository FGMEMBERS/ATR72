var fmcScreen = canvas.new({
  "name": "fmcScreen",  # The name is optional but allow for easier identification
  "size": [1024, 1024], # Size of the underlying texture (should be a power of 2, required)
  "view": [1024, 1024],  # Virtual resolution (Defines the coordinate system of the canvas
                        # which will be stretched the size of the texture, required)
  "mipmapping": 0       # Enable mipmapping (optional)
});

fmcScreen.addPlacement({"node": "fmcScreen"});

var group = fmcScreen.createGroup();

var title = group.createChild("text")
                .setTranslation(512, 90)      # The origin is in the top left corner
                .setAlignment("center-center") # All values from osgText are supported
                .setFont("helvetica_medium.txf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
                .setFontSize(60, 1.2)        # Set fontsize and optionally character aspect ratio
                .setColor(0,0.4,0.86,0.6)             # Text color
                .setText("TITLE TEST");

var labels = [];

var values = [];

var createTextNode = func(g) g.createChild("text");

for(var i=0; i<80; i+=1) {
  append(labels, createTextNode(group));
  append(values, createTextNode(group));
}

# Left Labels and Values

for (var n=0; n<6; n+=1) {

	labels[n].setTranslation(30, 150 + (135 * n))      # The origin is in the top left corner
			.setAlignment("left-center") # All values from osgText are supported
			.setFont("helvetica_medium.txf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
			.setFontSize(36, 1.2)        # Set fontsize and optionally character aspect ratio
			.setColor(0,0.4,0.86,0.6)             # Text color
			.setText("LABEL L"~(n+1));
			
	values[n].setTranslation(50, 207 + (135 * n))      # The origin is in the top left corner
			.setAlignment("left-center") # All values from osgText are supported
			.setFont("helvetica_medium.txf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
			.setFontSize(60, 1.2)        # Set fontsize and optionally character aspect ratio
			.setColor(1,1,1)             # Text color
			.setText("VALUE L"~(n+1));

}

# Center Labels and Values

for (var n=6; n<12; n+=1) {

	labels[n].setTranslation(512, 150 + (135 * (n-6)))     # The origin is in the top left corner
			.setAlignment("center-center") # All values from osgText are supported
			.setFont("helvetica_medium.txf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
			.setFontSize(36, 1.2)        # Set fontsize and optionally character aspect ratio
			.setColor(0,0.4,0.86,0.6)             # Text color
			.setText("LABEL C"~(n-5));
			
	values[n].setTranslation(512, 207 + (135 * (n-6)))      # The origin is in the top left corner
			.setAlignment("center-center") # All values from osgText are supported
			.setFont("helvetica_medium.txf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
			.setFontSize(60, 1.2)        # Set fontsize and optionally character aspect ratio
			.setColor(1,1,1)             # Text color
			.setText("VALUE C"~(n-5));

}

# Right Labels and Values

for (var n=12; n<18; n+=1) {

	labels[n].setTranslation(994, 150 + (135 * (n-12)))     # The origin is in the top left corner
			.setAlignment("right-center") # All values from osgText are supported
			.setFont("helvetica_medium.txf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
			.setFontSize(36, 1.2)        # Set fontsize and optionally character aspect ratio
			.setColor(0,0.4,0.86,0.6)             # Text color
			.setText("LABEL R"~(n-11));
			
	values[n].setTranslation(974, 207 + (135 * (n-12)))      # The origin is in the top left corner
			.setAlignment("right-center") # All values from osgText are supported
			.setFont("helvetica_medium.txf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
			.setFontSize(60, 1.2)        # Set fontsize and optionally character aspect ratio
			.setColor(1,1,1)             # Text color
			.setText("VALUE R"~(n-11));

}

var clearScreen = func() {

	title.setText("");
	
	foreach(var label; labels) {
		label.setText("");
	}
	
	foreach(var value; values) {
		value.setText("");
	}


};

# FMC Text Colors

var green = [0,0.35, 0.06, 0.7];
var white = [1,1,1,1];
var blue = [0,0.4,0.86,0.7];
var magenta = [0.83,0,0.83,0.7];
