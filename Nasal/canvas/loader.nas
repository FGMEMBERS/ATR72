# loader.nas:

# sub folder of your aircraft-dir where you store the
# copy of all canvas modules (api.nas, svg.nas and string.nas)
var canvas_subfolder = '/Nasal/canvas/';
# list of modules to be loaded, and destination namespace to be used
var modules = [ ['api.nas','canvas'], ['svg.nas','canvas'], ['gui.nas', 'canvas'], ['string.nas','std'] ];
 
# various helpers to check if the canvas namespace is used already
var has_symbol = func(symbol) contains(globals, symbol);
var is_hash = func(h) typeof(h)=='hash';
var has_module = func(m) has_symbol(m) and is_hash( globals[m] ); 
var has_canvas = func has_module('canvas');
var has_file = func(file) io.stat(file)!=nil;
var success = func(path) print(" SUCCESS:", path);
 
# helper to load all the modules into the right namespace, as defined in the nested modules vector
var load_canvas = func { 
  var errors=0; var err = func errors+=1;
  foreach(var m; modules) { 
   var path=getprop('/sim/aircraft-dir/') ~canvas_subfolder~m[0];    
   has_file(path) and io.load_nasal( path, m[1] ) and
   success(path) or err() and print("  File not found:", path) 
   and continue;
  } return errors;
}
 
# check if the canvas namespace is used or not
if ( !has_canvas() ) {
  # load the modules
  print("No Canvas module found in global namespace!");
  print("Trying to load own canvas/api.nas from sub folder under $FG_AIRCRAFT:"~canvas_subfolder) and
  !load_canvas() and
  print("Okay: Canvas modules successfully loaded!") or
  print("ERROR: While trying to load own canvas/api module from $FG_AIRCRAFT:", canvas_subfolder);
}
else 
  print("Okay: Canvas module already loaded, not loading own copy!");
