var dlg = canvas.Dialog.new([400,300]);
var my_canvas = dlg.createCanvas()
				   .setColorBackground(0,0,0,0);
var root = my_canvas.createGroup();
var x = 0;
var y = 0;
var rx = 8;
var ry = 8;
var w = 400;
var h = 20;
root.createChild("path")
	.moveTo(x + w - rx, y)
	.arcSmallCWTo(rx, ry, 0, x + w, y + ry)
	.vertTo(y + h)
		.horizTo(x)
		.vertTo(y + ry)
		.arcSmallCWTo(rx, ry, 0, x + rx, y)
		.close()
		.setColorFill(0.25,0.24,0.22).setFill(1)
		.setStrokeLineWidth(0);
	y = 20;
	h = 280;
	root.createChild("path")
		.moveTo(x + w, y)
		.vertTo(y + h)
		.horizTo(x)
		.vertTo(y)
		.setColorFill(1,1,1).setFill(1)
		.setColor(0,0,0);
	x = 8;
	y = 5;
	w = 10;
	h = 10;
	root.createChild("path", "icon-close")
		.moveTo(x, y)
		.lineTo(x + w, y + h)
		.moveTo(x + w, y)
		.lineTo(x, y + h)
		.setColor(1,0,0)
		.setStrokeLineWidth(3);
	root.createChild("text", "dialog-caption")
		.setText("Canvas Demo Dialog")
		.setTranslation(x + w + 8, 4)
		.setAlignment("left-top")
		.setFontSize(14)
		.setFont("LiberationFonts/LiberationSans-Bold.ttf")
		.setColor(1,1,1);
	root.createChild("text")
		.setText("Canvas is cool!")
		.setTranslation(200, 150)
		.setAlignment("center-center")
		.setFontSize(32)
		.setFont("LiberationFonts/LiberationSans-Regular.ttf")
		.setColor(0,0,0);
	var last_pos = [0,0];
	setlistener(my_canvas.texture.getPath() ~ '/mouse/event', func(p) {
	  var type = p.getValue();
	  var mouse = p.getParent();
	  var dx = mouse.getNode("dx").getValue();
	  var dy = mouse.getNode("dy").getValue();
				  if( type == 8 )
		dlg.move(dx, dy);
	});
