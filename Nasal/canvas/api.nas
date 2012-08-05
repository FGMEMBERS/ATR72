# Helper function to create a node with the first available index for the given
# path relative to the given node
#
var _createNodeWithIndex = func(node, path, min_index = 0)
{
  # TODO do we need an upper limit? (50000 seems already seems unreachable)
  for(var i = min_index; i < 50000; i += 1)
  {
    var p = path ~ "[" ~ i ~ "]";
    if( node.getNode(p) == nil )
      return node.getNode(p, 1);
  }
  
  debug.warn("Unable to get child (already 50000 exist)");

  return nil;
};

# Internal helper
var _createColorNodes = func(parent, name)
{
  var node = parent.getNode(name, 1);
  return [ node.getNode("red", 1),
           node.getNode("green", 1),
           node.getNode("blue", 1),
           node.getNode("alpha", 1) ];
};

var _setColorNodes = func(nodes, color)
{
  if( typeof(nodes) != "vector" )
  {
    debug.warn("This element doesn't support setting color");
    return;
  }
  
  if( size(color) == 1 )
    color = color[0];

  if( typeof(color) != "vector" )
    return debug.warn("Wrong type for color");
  
  if( size(color) < 3 or size(color) > 4 )
    return debug.warn("Color needs 3 or 4 values (RGB or RGBA)");

  for(var i = 0; i < size(color); i += 1)
    nodes[i].setDoubleValue( color[i] );

  if( size(color) == 3 )
    # default alpha is 1
    nodes[3].setDoubleValue(1);
};

var _arg2valarray = func
{
  var ret = arg;
  while (    typeof(ret) == "vector"
            and size(ret) == 1 and typeof(ret[0]) == "vector" )
      ret = ret[0];
  return ret;
}

# Transform
# ==============================================================================
# A transformation matrix which is used to transform an #Element on the canvas.
# The dimensions of the matrix are 3x3 where the last row is always 0 0 1:
#
#  a c e
#  b d f
#  0 0 1
#
# See http://www.w3.org/TR/SVG/coords.html#TransformMatrixDefined for details.
#
var Transform = {
  new: func(node, vals = nil)
  {
    var m = {
      parents: [Transform],
      _node: node,
      a: node.getNode("m[0]", 1),
      b: node.getNode("m[1]", 1),
      c: node.getNode("m[2]", 1),
      d: node.getNode("m[3]", 1),
      e: node.getNode("m[4]", 1),
      f: node.getNode("m[5]", 1)
    };
    
    var use_vals = typeof(vals) == 'vector' and size(vals) == 6;
    
    # initialize to identity matrix
    m.a.setDoubleValue(use_vals ? vals[0] : 1);
    m.b.setDoubleValue(use_vals ? vals[1] : 0);
    m.c.setDoubleValue(use_vals ? vals[2] : 0);
    m.d.setDoubleValue(use_vals ? vals[3] : 1);
    m.e.setDoubleValue(use_vals ? vals[4] : 0);
    m.f.setDoubleValue(use_vals ? vals[5] : 0);
    
    return m;
  },
  setTranslation: func
  {
    var trans = _arg2valarray(arg);

    me.e.setDoubleValue(trans[0]);
    me.f.setDoubleValue(trans[1]);
    
    return me;
  },
  # Set rotation (Optionally around a specified point instead of (0,0))
  #
  #  setRotation(rot)
  #  setRotation(rot, cx, cy)
  #
  # @note If using with rotation center different to (0,0) don't use
  #       #setTranslation as it would interfere with the rotation.
  setRotation: func(angle)
  {
    var center = _arg2valarray(arg);

    var s = math.sin(angle);
    var c = math.cos(angle);

    me.a.setDoubleValue(c);
    me.b.setDoubleValue(s);
    me.c.setDoubleValue(-s);
    me.d.setDoubleValue(c);

    if( size(center) == 2 )
    {
      me.e.setDoubleValue( (-center[0] * c) + (center[1] * s) + center[0] );
      me.f.setDoubleValue( (-center[0] * s) - (center[1] * c) + center[1] );
    }
    
    return me;
  },
  # Set scale (either as parameters or array)
  #
  # If only one parameter is given its value is used for both x and y
  #  setScale(x, y)
  #  setScale([x, y])
  setScale: func
  {
    var scale = _arg2valarray(arg);

    me.a.setDoubleValue(scale[0]);
    me.d.setDoubleValue(size(scale) >= 2 ? scale[1] : scale[0]);
    
    return me;
  },
  getScale: func()
  {
    # TODO handle rotation
    return [me.a.getValue(), me.d.getValue()];
  }
};

# Element
# ==============================================================================
# Baseclass for all elements on a canvas
#
var Element = {
  # Constructor
  #
  # @param parent   Parent node (In the property tree)
  # @param type     Type string (Used as node name)
  # @param id       ID/Name (Should be unique)
  new: func(parent, type, id)
  {
    # arg can contain the node to be used instead of creating a new one
    var args = _arg2valarray(arg);
    if( size(args) == 1 )
    {
      var node = args[0];
      if( !isa(node, props.Node) )
        return debug.warn("Not a props.Node!");
    }
    else
      var node = _createNodeWithIndex(parent, type);

    var m = {
      parents: [Element],
      _node: node,
      _center: [
        node.getNode("center[0]"),
        node.getNode("center[1]")
      ]
    };
    
    if( id != nil )
      m._node.getNode("id", 1).setValue(id);

    return m;
  },
  # Destructor (has to be called manually!)
  del: func()
  {
    me._node.remove();
  },
  set: func(key, value)
  {
    me._node.getNode(key, 1).setValue(value);
    return me;
  },
  setBool: func(key, value)
  {
    me._node.getNode(key, 1).setBoolValue(value);
    return me;
  },
  setDouble: func(key, value)
  {
    me._node.getNode(key, 1).setDoubleValue(value);
    return me;
  },
  setInt: func(key, value)
  {
    me._node.getNode(key, 1).setIntValue(value);
    return me;
  },
  # Trigger an update of the element
  # 
  # Elements are automatically updated once a frame, with a delay of one frame.
  # If you wan't to get an element updated in the current frame you have to use
  # this method.
  update: func()
  {
    me.setInt("update", 1);
  },
  # Hide/Show element
  #
  # @param visible  Whether the element should be visible
  setVisible: func(visible = 1)
  {
    me.setBool("visible", visible);
  },
  # Hide element (Shortcut for setVisible(0))
  hide: func me.setVisible(0),
  # Show element (Shortcut for setVisible(1))
  show: func me.setVisible(1),
  #
  setGeoPosition: func(lat, lon)
  {
    me._getTf()._node.getNode("m-geo[4]", 1).setValue("N" ~ lat);
    me._getTf()._node.getNode("m-geo[5]", 1).setValue("E" ~ lon);
    return me;
  },
  # Create a new transformation matrix
  #
  # @param vals Default values (Vector of 6 elements)
  createTransform: func(vals = nil)
  {
    var node = _createNodeWithIndex(me._node, "tf", 1); # tf[0] is reserved for
                                                        # setRotation
    return Transform.new(node, vals);
  },
  # Shortcut for setting translation
  setTranslation: func { me._getTf().setTranslation(arg); return me; },
  # Set rotation around transformation center (see #setCenter).
  #
  # @note This replaces the the existing transformation. For additional scale or
  #       translation use additional transforms (see #createTransform).
  setRotation: func(rot)
  {
    if( me['_tf_rot'] == nil )
      # always use the first matrix slot to ensure correct rotation
      # around transformation center.
      me['_tf_rot'] = Transform.new(me._node.getNode("tf[0]", 1));

    me._tf_rot.setRotation(rot, me.getCenter());
    return me;
  },
  # Shortcut for setting scale
  setScale: func { me._getTf().setScale(arg); return me; },
  # Shortcut for getting scale
  getScale: func me._getTf().getScale(),
  # Set the line/text color
  #
  # @param color  Vector of 3 or 4 values in [0, 1]
  setColor: func { _setColorNodes(me.color, arg); return me; },
  # Set the fill/background/boundingbox color
  #
  # @param color  Vector of 3 or 4 values in [0, 1]
  setColorFill: func { _setColorNodes(me.color_fill, arg); return me; },
  #
  getBoundingBox: func()
  {
    var bb = me._node.getNode("bounding-box");
    var min_x = bb.getNode("min-x").getValue();
    
    if( min_x != nil )
      return [ min_x,
                bb.getNode("min-y").getValue(),
                bb.getNode("max-x").getValue(),
                bb.getNode("max-y").getValue() ];
    else
      return [0, 0, 0, 0];
  },
  # Set transformation center (currently only used for rotation)
  setCenter: func()
  {
    var center = _arg2valarray(arg);
    if( size(center) != 2 )
      return debug.warn("invalid arg");
      
    if( me._center[0] == nil )
      me._center[0] = me._node.getNode("center[0]", 1);
    if( me._center[1] == nil )
      me._center[1] = me._node.getNode("center[1]", 1);

    me._center[0].setDoubleValue(center[0] or 0);
    me._center[1].setDoubleValue(center[1] or 0);
    
    return me;
  },
  # Get transformation center
  getCenter: func()
  {
    var bb = me.getBoundingBox();
    var center = [0, 0];
    
    if( me._center[0] != nil )
      center[0] = me._center[0].getValue() or 0;
    if( me._center[1] != nil )
      center[1] = me._center[1].getValue() or 0;

    if( bb[0] >= bb[2] or bb[1] >= bb[3] )
      return center;
    
    return [ 0.5 * (bb[0] + bb[2]) + center[0],
              0.5 * (bb[1] + bb[3]) + center[1] ];
  },
  # Internal Transform for convenience transform functions
  _getTf: func
  {
    if( me['_tf'] == nil )
      me['_tf'] = me.createTransform();
    return me._tf;
  }
};

# Group
# ==============================================================================
# Class for a group element on a canvas
#
var Group = {
  new: func(parent, id, type = "group")
  {
    # special case: if called from #getElementById the third argument is the
    # existing node so we need to rearange the variables a bit.
    if( typeof(type) != "scalar" )
    {
      var arg = [type];
      var type = "group";
    }

    return { parents: [Group, Element.new(parent, type, id, arg)] };
  },
  # Create a child of given type with specified id.
  # type can be group, text
  createChild: func(type, id = nil)
  {
    var factory = me._element_factories[type];
    
    if( factory == nil )
    {
      debug.dump("canvas.Group.createChild(): unknown type (" ~ type ~ ")");
      return nil;
    }
    
    return factory(me._node, id);
  },
  # Get first child with given id (breadth-first search)
  #
  # @note Use with care as it can take several miliseconds (for me eg. ~2ms).
  getElementById: func(id)
  {
    # TODO can we improve the queue or better port this to C++ or use some kind
    # of lookup hash? Searching is really slow now...
    var stack = [me._node];
    var index = 0;
    
    while( index < size(stack) )
    {
      var node = stack[index];
      index += 1;

      if( node != me._node )
      {
        var node_id = node.getNode("id");
        if( node_id != nil and node_id.getValue() == id )
          return me._element_factories[ node.getName() ]
          (
            nil,
            nil,
            # use the existing node
            node
          );
      }
        
      foreach(var c; node.getChildren())
        # element nodes have type NONE and valid element names (those in the the
        # factor list)
        if(     c.getType() == "NONE"
            and me._element_factories[ c.getName() ] != nil )
          append(stack, c);
    }
  },
  # Remove all children
  removeAllChildren: func()
  {
    foreach(var type; keys(me._element_factories))
      me._node.removeChildren(type, 0);
    return me;
  }
};

# Map
# ==============================================================================
# Class for a group element on a canvas with possibly geopgraphic positions
# which automatically get projected according to the specified projection.
#
var Map = {
  new: func(parent, id)
  {
    return { parents: [Map, Group.new(parent, id, "map", arg)] };
  }
  # TODO
};

# Text
# ==============================================================================
# Class for a text element on a canvas
#
var Text = {
  new: func(parent, id)
  {
    var m = {
      parents: [Text, Element.new(parent, "text", id, arg)]
    };
    m.color = _createColorNodes(m._node, "color");
    m.color_fill = _createColorNodes(m._node, "color-fill");
    return m;
  },
  # Set the text
  setText: func(text)
  {
    # add space because osg seems to remove last character if its a space
    me.set("text", typeof(text) == 'scalar' ? text ~ ' ' : "");
  },
  # Set alignment
  #
  #  @param algin String, one of:
  #   left-top
  #   left-center
  #   left-bottom
  #   center-top
  #   center-center
  #   center-bottom
  #   right-top
  #   right-center
  #   right-bottom
  #   left-baseline
  #   center-baseline
  #   right-baseline
  #   left-bottom-baseline
  #   center-bottom-baseline
  #   right-bottom-baseline
  #
  setAlignment: func(align)
  {
    me.set("alignment", align);
  },
  # Set the font size
  setFontSize: func(size, aspect = 1)
  {
    me.setDouble("character-size", size);
    me.setDouble("character-aspect-ratio", aspect);
  },
  # Set font (by name of font file)
  setFont: func(name)
  {
    me.set("font", name);
  },
  # Enumeration of values for drawing mode:
  TEXT:               1, # The text itself
  BOUNDINGBOX:        2, # A bounding box (only lines)
  FILLEDBOUNDINGBOX:  4, # A filled bounding box
  ALIGNMENT:          8, # Draw a marker (cross) at the position of the text
  # Set draw mode. Binary combination of the values above. Since I haven't found
  # a bitwise or we have to use a + instead.
  #
  #  eg. my_text.setDrawMode(Text.TEXT + Text.BOUNDINGBOX);
  setDrawMode: func(mode)
  {
    me.setInt("draw-mode", mode);
  },
  # Set bounding box padding
  setPadding: func(pad)
  {
    me.setDouble("padding", pad);
  },
  setMaxWidth: func(w)
  {
    me.setDouble("max-width", w);
  }
};

# Path
# ==============================================================================
# Class for an (OpenVG) path element on a canvas
#
var Path = {
  # Path segment commands (VGPathCommand)
  VG_CLOSE_PATH:     0,
  VG_MOVE_TO:        2,
  VG_MOVE_TO_ABS:    2,
  VG_MOVE_TO_REL:    3,
  VG_LINE_TO:        4,
  VG_LINE_TO_ABS:    4,
  VG_LINE_TO_REL:    5,
  VG_HLINE_TO:       6,
  VG_HLINE_TO_ABS:   6,
  VG_HLINE_TO_REL:   7,
  VG_VLINE_TO:       8,
  VG_VLINE_TO_ABS:   8,
  VG_VLINE_TO_REL:   9,
  VG_QUAD_TO:       10,
  VG_QUAD_TO_ABS:   10,
  VG_QUAD_TO_REL:   11,
  VG_CUBIC_TO:      12,
  VG_CUBIC_TO_ABS:  12,
  VG_CUBIC_TO_REL:  13,
  VG_SQUAD_TO:      14,
  VG_SQUAD_TO_ABS:  14,
  VG_SQUAD_TO_REL:  15,
  VG_SCUBIC_TO:     16,
  VG_SCUBIC_TO_ABS: 16,
  VG_SCUBIC_TO_REL: 17,
  VG_SCCWARC_TO:    20, # Note that CC and CCW commands are swapped. This is
  VG_SCCWARC_TO_ABS:20, # needed  due to the different coordinate systems used.
  VG_SCCWARC_TO_REL:21, # In OpenVG values along the y-axis increase from bottom
  VG_SCWARC_TO:     18, # to top, whereas in the Canvas system it is flipped.
  VG_SCWARC_TO_ABS: 18,
  VG_SCWARC_TO_REL: 19,
  VG_LCCWARC_TO:    24,
  VG_LCCWARC_TO_ABS:24,
  VG_LCCWARC_TO_REL:25,
  VG_LCWARC_TO:     22,
  VG_LCWARC_TO_ABS: 22,
  VG_LCWARC_TO_REL: 23,

  # Number of coordinates per command
  num_coords: [
    0, 0, # VG_CLOSE_PATH
    2, 2, # VG_MOVE_TO
    2, 2, # VG_LINE_TO
    1, 1, # VG_HLINE_TO
    1, 1, # VG_VLINE_TO
    4, 4, # VG_QUAD_TO
    6, 6, # VG_CUBIC_TO
    2, 2, # VG_SQUAD_TO
    4, 4, # VG_SCUBIC_TO
    5, 5, # VG_SCCWARC_TO
    5, 5, # VG_SCWARC_TO
    5, 5, # VG_LCCWARC_TO
    5, 5  # VG_LCWARC_TO
  ],

  #
  new: func(parent, id)
  {
    var m = {
      parents: [Path, Element.new(parent, "path", id, arg)],
      _num_cmds: 0,
      _num_coords: 0
    };
    m.color = _createColorNodes(m._node, "color");
    m.color_fill = _createColorNodes(m._node, "color-fill");
    return m;
  },
  # Remove all existing path data
  reset: func
  {
    me._node.removeChildren('cmd', 0);
    me._node.removeChildren('coord', 0);
    me._node.removeChildren('coord-geo', 0);
    me._num_cmds = 0;
    me._num_coords = 0;
    return me;
  },
  # Set the path data (commands and coordinates)
  setData: func(cmds, coords)
  {
    me.reset();
    me._node.setValues({cmd: cmds, coord: coords});
    me._num_cmds = size(cmds);
    me._num_coords = size(coords);
    return me;
  },
  setDataGeo: func(cmds, coords)
  {
    me.reset();
    me._node.setValues({cmd: cmds, 'coord-geo': coords});
    me._num_cmds = size(cmds);
    me._num_coords = size(coords);
    return me;
  },
  # Add a path segment
  addSegment: func(cmd, coords...)
  {
    var coords = _arg2valarray(coords);
    var num_coords = me.num_coords[cmd];
    if( size(coords) != num_coords )
      debug.warn
      (
        "Invalid number of arguments (expected " ~ (num_coords + 1) ~ ")"
      );
    else
    {
      me.setInt("cmd[" ~ (me._num_cmds += 1) ~ "]", cmd);
      for(var i = 0; i < num_coords; i += 1)
        me.setDouble("coord[" ~ (me._num_coords += 1) ~ "]", coords[i]);
    }
    
    return me;
  },
  # Move path cursor
  moveTo: func me.addSegment(me.VG_MOVE_TO_ABS, arg),
  move:   func me.addSegment(me.VG_MOVE_TO_REL, arg),
  # Add a line
  lineTo: func me.addSegment(me.VG_LINE_TO_ABS, arg),
  line:   func me.addSegment(me.VG_LINE_TO_REL, arg),
  # Add a horizontal line
  horizTo: func me.addSegment(me.VG_HLINE_TO_ABS, arg),
  horiz:   func me.addSegment(me.VG_HLINE_TO_REL, arg),
  # Add a vertical line
  vertTo: func me.addSegment(me.VG_VLINE_TO_ABS, arg),
  vert:   func me.addSegment(me.VG_VLINE_TO_REL, arg),
  # Add a quadratic Bézier curve
  quadTo: func me.addSegment(me.VG_QUAD_TO_ABS, arg),
  quad:   func me.addSegment(me.VG_QUAD_TO_REL, arg),
  # Add a cubic Bézier curve
  cubicTo: func me.addSegment(me.VG_CUBIC_TO_ABS, arg),
  cubic:   func me.addSegment(me.VG_CUBIC_TO_REL, arg),
  # Add a smooth quadratic Bézier curve
  quadTo: func me.addSegment(me.VG_SQUAD_TO_ABS, arg),
  quad:   func me.addSegment(me.VG_SQUAD_TO_REL, arg),
  # Add a smooth cubic Bézier curve
  cubicTo: func me.addSegment(me.VG_SCUBIC_TO_ABS, arg),
  cubic:   func me.addSegment(me.VG_SCUBIC_TO_REL, arg),
  # Draw an elliptical arc (shorter counter-clockwise arc)
  arcSmallCCWTo: func me.addSegment(me.VG_SCCWARC_TO_ABS, arg),
  arcSmallCCW:   func me.addSegment(me.VG_SCCWARC_TO_REL, arg),
  # Draw an elliptical arc (shorter clockwise arc)
  arcSmallCWTo: func me.addSegment(me.VG_SCWARC_TO_ABS, arg),
  arcSmallCW:   func me.addSegment(me.VG_SCWARC_TO_REL, arg),
  # Draw an elliptical arc (longer counter-clockwise arc)
  arcLargeCCWTo: func me.addSegment(me.VG_LCCWARC_TO_ABS, arg),
  arcLargeCCW:   func me.addSegment(me.VG_LCCWARC_TO_REL, arg),
  # Draw an elliptical arc (shorter clockwise arc)
  arcLargeCWTo: func me.addSegment(me.VG_LCWARC_TO_ABS, arg),
  arcLargeCW:   func me.addSegment(me.VG_LCWARC_TO_REL, arg),
  # Close the path (implicit lineTo to first point of path)
  close: func me.addSegment(me.VG_CLOSE_PATH),

  setStrokeLineWidth: func(width)
  {
    me.setDouble('stroke-width', width);
  },
  # Set stroke linecap
  #
  # @param linecap String, "butt", "round" or "square"
  #
  # See http://www.w3.org/TR/SVG/painting.html#StrokeLinecapProperty for details
  setStrokeLineCap: func(linecap)
  {
    me.set('stroke-linecap', linecap);
  },
  # Set stroke dasharray
  #
  # @param pattern Vector, Vector of alternating dash and gap lengths
  #  [on1, off1, on2, ...]
  setStrokeDashArray: func(pattern)
  {
    me._node.removeChildren('stroke-dasharray');

    if( typeof(pattern) == 'vector' )
      me._node.setValues({'stroke-dasharray': pattern});
    else
      debug.warn("setStrokeDashArray: vector expected!");

    return me;
  },
  # Set the fill color and enable filling this path
  #
  # @param color  Vector of 3 or 4 values in [0, 1]
  setColorFill: func { _setColorNodes(me.color_fill, arg); me.setFill(1); },
  # Enable/disable filling this path
  setFill: func(fill)
  {
    me.setBool("fill", fill);
  }
};

# Element factories used by #Group elements to create children
Group._element_factories = {
  "group": Group.new,
  "map": Map.new,
  "text": Text.new,
  "path": Path.new
};

# Canvas
# ==============================================================================
# Class for a canvas
#
var Canvas = {
  # Place this canvas somewhere onto the object. Pass criterions for placement
  # as a hash, eg:
  #
  #  my_canvas.addPlacement({
  #    "texture": "EICAS.png",
  #    "node": "PFD-Screen",
  #    "parent": "Some parent name"
  #  });
  # 
  # Note that we can choose whichever of the three filter criterions we use for
  # matching the target object for our placement. If none of the three fields is
  # given every texture of the model will be replaced.
  addPlacement: func(vals)
  {
    var placement = _createNodeWithIndex(me.texture, "placement");
    placement.setValues(vals);
    return placement;
  },
  # Create a new group with the given name
  #
  # @param id Optional id/name for the group
  createGroup: func(id = nil)
  {
    return Group.new(me.texture, id);
  },
  # Set the background color
  #
  # @param color  Vector of 3 or 4 values in [0, 1]
  setColorBackground: func { _setColorNodes(me.color, arg); return me; }
};

# Create a new canvas. Pass parameters as hash, eg:
#
#  var my_canvas = canvas.new({
#    "name": "PFD-Test",
#    "size": [512, 512],
#    "view": [768, 1024],
#    "mipmapping": 1
#  });
var new = func(vals)
{
  var m = { parents: [Canvas] };

  m.texture = _createNodeWithIndex
  (
    props.globals.getNode("canvas", 1),
    "texture"
  );
  m.color = _createColorNodes(m.texture, "color-background");
  m.texture.setValues(vals);

  return m;
};

# Get the first existing canvas with the given name
#
# @param name Name of the canvas
# @return #Canvas, if canvas with #name exists
#         nil, otherwise
var get = func(name)
{
  var node_canvas = nil;
  if( isa(name, props.Node) )
    node_canvas = name;
  else if( typeof(name) == 'scalar' )
  {
    var canvas_root = props.globals.getNode("canvas");
    if( canvas_root == nil )
      return nil;

    foreach(var c; canvas_root.getChildren("texture"))
    {
      if( c.getValue("name") == name )
        node_canvas = c;
    }
  }
  
  if( node_canvas == nil )
  {
    debug.warn("Canvas not found: " ~ name);
    return nil;
  }
  
  return {
    parents: [Canvas],
    texture: node_canvas,
    color: _createColorNodes(node_canvas, "color-background")
  };
};

# ------------------------------------------------------------------------------
# Show warnings if API used with too old version of FlightGear without Canvas
# support (Wrapped in anonymous function do not polute the canvas namespace)

(func {
var version_str = getprop("/sim/version/flightgear");
if( string.scanf(version_str, "%u.%u.%u", var fg_version = []) < 1 )
  debug.warn("Canvas: Error parsing flightgear version (" ~ version_str ~ ")");
else
{
  if(     fg_version[0] < 2
      or (fg_version[0] == 2 and fg_version[1] < 8) )
  {
    debug.warn("Canvas: FlightGear version too old (" ~ version_str ~ ")");
    gui.popupTip
    (
      "FlightGear v2.8.0 or newer needed for Canvas support!",
      600,
      {button: {legend: "Ok", binding: {command: "dialog-close"}}}
    );
  }
} })();
