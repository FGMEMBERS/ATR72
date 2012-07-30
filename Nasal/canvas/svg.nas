# Parse an xml file into a canvas group element
#
# @param group    The canvas.Group instance to append the parsed elements to
# @param path     The path of the svg file (absolute or relative to FG_ROOT)
# @param options  Optional hash of options
var parsesvg = func(group, path, options = nil)
{
  if( !isa(group, Group) )
    die("Invalid argument group (type != Group)");
  
  if( options == nil )
    options = {};
  
  if( typeof(options) != "hash" )
    die("Options need to be of type hash!");

  var custom_font_mapper = options['font-mapper'];
  var font_mapper = func(family, weight)
  {
    if( typeof(custom_font_mapper) == 'func' )
    {
      var font = custom_font_mapper(family, weight);
      if( font != nil )
        return font;
    }
      
    return "LiberationFonts/LiberationMono-Bold.ttf";
  };

  var level = 0;
  var skip  = 0;
  var stack = [group];
  var close_stack = []; # helper for check tag closing
  
  # lookup table for element ids (for <use> element)
  var id_dict = {};
  
  # ----------------------------------------------------------------------------
  # Create a new child an push it onto the stack
  var pushElement = func(type, id = nil)
  {
    append(stack, stack[-1].createChild(type, id));
    append(close_stack, level);

    if( typeof(id) == 'scalar' and size(id) )
      id_dict[ id ] = stack[-1];
  };
  
  # ----------------------------------------------------------------------------
  # Parse a transformation (matrix)
  # http://www.w3.org/TR/SVG/coords.html#TransformAttribute
  var parseTransform = func(tf)
  {
    if( tf == nil )
      return;

    tf = std.string.new(tf);
    
    var end = 0;
    while(1)
    {
      var start_type = tf.find_first_not_of("\t\n ", end);
      if( start_type < 0 )
        break;

      var end_type = tf.find_first_of("(\t\n ", start_type + 1);
      if( end_type < 0 )
        break;

      var start_args = tf.find('(', end_type);
      if( start_args < 0 )
        break;

      var values = [];
      end = start_args;
      while(1)
      {
        var start_num = tf.find_first_not_of(",\t\n ", end + 1);
        if( start_num < 0 )
          break;
        if( tf[start_num] == ')' )
          break;

        end = tf.find_first_of("),\t\n ", start_num + 1);
        if( end < 0 )
          break;
        append(values, tf.substr(start_num, end - start_num));
      }
      
      var type = tf.substr(start_type, end_type - start_type);

      if( type == "translate" )
        # translate(<tx> [<ty>]), which specifies a translation by tx and ty. If
        # <ty> is not provided, it is assumed to be zero.
        stack[-1].createTransform().setTranslation
        (
          values[0],
          size(values) > 1 ? values[1] : 0,
        );
      else if( type == "matrix" )
      {
        if( size(values) == 6 )
          stack[-1].createTransform(values);
        else
          debug.dump('invalid transform', type, values);
      }
      else
        debug.dump(['unknown transform', type, values]);
    }
  };
  
  # ----------------------------------------------------------------------------
  # Parse a path
  # http://www.w3.org/TR/SVG/paths.html#PathData
  
  # map svg commands OpenVG commands
  var cmd_map = {
    z: Path.VG_CLOSE_PATH,
    m: Path.VG_MOVE_TO,
    l: Path.VG_LINE_TO,
    h: Path.VG_HLINE_TO,
    v: Path.VG_VLINE_TO,
    q: Path.VG_QUAD_TO,
    c: Path.VG_CUBIC_TO,
    t: Path.VG_SQUAD_TO,
    s: Path.VG_SCUBIC_TO
  };
  
  var parsePath = func(d)
  {
    if( d == nil )
      return;

    var path_data = std.string.new(d);
    var pos = 0;
    
    var cmds = [];
    var coords = [];

    while(1)
    {
      # skip trailing spaces
      pos = path_data.find_first_not_of("\t\n ", pos);
      if( pos < 0 )
        break;

      # get command
      var cmd = path_data.substr(pos, 1);
      pos += 1;

      # and get all following arguments
      var args = [];
      while(1)
      {
        pos = path_data.find_first_not_of(",\t\n ", pos);
        if( pos < 0 )
          break;

        var start_num = pos;
        pos = path_data.find_first_not_of("e-.0123456789", start_num);
        if( start_num == pos )
          break;

        append(args, path_data.substr(start_num, pos > 0 ? pos - start_num : nil));
      }
      
      # now execute the command
      var rel = string.islower(cmd[0]);
      var cmd = string.lc(cmd);
      if( cmd == 'a' )
      {
        for(var i = 0; i + 7 <= size(args); i += 7)
        {
          # SVG: (rx ry x-axis-rotation large-arc-flag sweep-flag x y)+
          # OpenVG: rh,rv,rot,x0,y0
          if( args[i + 3] )
            var cmd_vg = args[i + 4] ? Path.VG_LCCWARC_TO : Path.VG_LCWARC_TO;
          else
            var cmd_vg = args[i + 4] ? Path.VG_SCCWARC_TO : Path.VG_SCWARC_TO;
          append(cmds, rel ? cmd_vg + 1: cmd_vg);
          append(coords, args[i],
                         args[i + 1],
                         args[i + 2],
                         args[i + 5],
                         args[i + 6] );
        }
        
        if( math.mod(size(args), 7) > 0 )
          debug.dump('too much coords for cmd', cmd, args);
      }
      else
      {
        var cmd_vg = cmd_map[cmd];
        if( cmd_vg == nil )
        {
          debug.dump('command not found', cmd, args);
          continue;
        }

        var num_coords = Path.num_coords[int(cmd_vg)];
        if( num_coords == 0 )
          append(cmds, cmd_vg);
        else
        {
          for(var i = 0; i + num_coords <= size(args); i += num_coords)
          {
            append(cmds, rel ? cmd_vg + 1: cmd_vg);
            for(var j = i; j < i + num_coords; j += 1)
              append(coords, args[j]);

            # If a moveto is followed by multiple pairs of coordinates, the
            # subsequent pairs are treated as implicit lineto commands.            
            if( cmd == 'm' )
              cmd_vg = cmd_map['l'];
          }
          
          if( math.mod(size(args), num_coords) > 0 )
            debug.warn('too much coords for cmd: ' ~ cmd);
        }
      }
    }
    
    stack[-1].setData(cmds, coords);
  };
  
  # ----------------------------------------------------------------------------
  # Parse a css style attribute
  var parseStyle = func(style)
  {
    if( style == nil )
      return {};
    
    var styles = {};
    foreach(var part; split(';', style))
    {
      if( !size(part = string.trim(part)) )
        continue;
      if( size(part = split(':',part)) != 2 )
        continue;

      var key = string.trim(part[0]);
      if( !size(key) )
        continue;
      
      var value = string.trim(part[1]);
      if( !size(value) )
        continue;
        
      styles[key] = value;
    }
    
    return styles;
  }
  
  # ----------------------------------------------------------------------------
  # Parse a css color
  var parseColor = func(s)
  {
    var color = [0, 0, 0];
    if( s == nil )
      return color;

    if( size(s) == 7 and substr(s, 0, 1) == '#' )
    {
      return [ std.stoul(substr(s, 1, 2), 16) / 255,
                std.stoul(substr(s, 3, 2), 16) / 255,
                std.stoul(substr(s, 5, 2), 16) / 255 ];
    }
    
    return color;
  };

  # ----------------------------------------------------------------------------
  # XML parsers element open callback
  var start = func(name, attr)
  {
    level += 1;

    if( skip )
      return;

    if( level == 1 )
    {
      if( name != 'svg' )
        die("Not an svg file (root=" ~ name ~ ")");
      else
        return;
    }
    
    var style = parseStyle(attr['style']);

    if( style['display'] == 'none' )
    {
      skip = level - 1;
      return;
    }
    else if( name == "g" )
    {
      pushElement('group', attr['id']);
    }
    else if( name == "text" )
    {
      pushElement('text', attr['id']);
      stack[-1].setTranslation(attr['x'], attr['y']);
      
      # http://www.w3.org/TR/SVG/text.html#TextAnchorProperty
      var h_align = style["text-anchor"];
      if( h_align == "end" )
        h_align = "right";
      else if( h_align == "middle" )
        h_align = "center";
      else # "start"
        h_align = "left";
      stack[-1].setAlignment(h_align ~ "-baseline");
      # TODO vertical align
      
      stack[-1].setColor(parseColor(style['fill']));
      stack[-1].setFont
      (
        font_mapper(style["font-family"], style["font-weight"])
      );

      var font_size = style["font-size"];
      if( font_size != nil )
        # eg. font-size: 123px
        stack[-1].setFontSize(substr(font_size, 0, size(font_size) - 2));
    }
    else if( name == "path" or name == "rect" )
    {
      pushElement('path', attr['id']);
      var d = attr['d'];

      if( name == "rect" )
      {
        var width = attr['width'];
        var height = attr['height'];
        var x = attr['x'];
        var y = attr['y'];

        d = sprintf("M%f,%f v%f h%f v%fz", x, y, height, width, -height);
      }
      
      parsePath(d);
      
      var w = style['stroke-width'];
      stack[-1].setStrokeLineWidth( w != nil ? w : 1 );
      stack[-1].setColor(parseColor(style['stroke']));
      
      var linecap = style['stroke-linecap'];
      if( linecap != nil )
        stack[-1].setStrokeLineCap(style['stroke-linecap']);
      
      var fill = style['fill'];
      if( fill != nil and fill != "none" )
      {
        stack[-1].setColorFill(parseColor(fill));
        stack[-1].setFill(1);
      }
      
      # http://www.w3.org/TR/SVG/painting.html#StrokeDasharrayProperty
      var dash = style['stroke-dasharray'];
      if( dash and size(dash) > 3 )
        # at least 2 comma separated values...
        stack[-1].setStrokeDashArray(split(',', dash));

      var cx = attr['inkscape:transform-center-x'];
      var cy = attr['inkscape:transform-center-y'];
      if( cx != nil or cy != nil )
        stack[-1].setCenter(cx or 0, -(cy or 0));
    }
    else if( name == "tspan" )
    {
      return;
    }
    else if( name == "use" )
    {
      var ref = attr["xlink:href"];
      if( ref == nil or size(ref) < 2 or ref[0] != `#` )
        return debug.dump("Invalid or missing href", ref);

      var el_src = id_dict[ substr(ref, 1) ];
      if( el_src == nil )
        return print("parsesvg: Reference to unknown element (" ~ ref ~ ")");
      
      # Create new element and copy sub branch from source node
      pushElement(el_src._node.getName(), attr['id']);
      props.copy(el_src._node, stack[-1]._node);

      # copying also overrides the id so we need to set it again
      stack[-1]._node.getNode("id").setValue(attr['id']);
    }
    else
    {
      print("parsesvg: skipping unknown element '" ~ name ~ "'");
      skip = level;
      return;
    }

    parseTransform(attr['transform']);
  };

  # XML parsers element close callback
  var end = func(name)
  {
    level -= 1;
    
    if( skip )
    {
      if( level <= skip )
        skip = 0;
      return;
    }
    
    if( size(close_stack) and (level + 1) == close_stack[-1] )
    {
      pop(stack);
      pop(close_stack);
    }
  };

  # XML parsers element data callback
  var data = func(data)
  {
    if( skip )
      return;
    
    if( size(data) and isa(stack[-1], Text) )
      stack[-1].setText(data);
  };

  if( path[0] != '/' )
    path = getprop("/sim/fg-root") ~ "/" ~ path;

  call(func parsexml(path, start, end, data), nil, var err = []);
  if( size(err) )
  {
    debug.dump(err);
    return 0;
  }
  
  return 1;
}
