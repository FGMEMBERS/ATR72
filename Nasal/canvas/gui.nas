var Dialog = {
  # Constructor
  #
  # @param parent   Parent node (In the property tree)
  # @param type     Type string (Used as node name)
  # @param id       ID/Name (Should be unique)
  new: func(size_dlg)
  {
    var m = {
      parents: [Dialog],
      _node: _createNodeWithIndex(props.globals.getNode("/sim/gui/canvas", 1), "window"),
    };
    m._node.getNode("size[0]", 1).setIntValue(size_dlg[0]);
    m._node.getNode("size[1]", 1).setIntValue(size_dlg[1]);

    return m;
  },
  # Destructor (has to be called manually!)
  del: func()
  {
    me._node.remove();
  },
  createCanvas: func()
  {
    var size_dlg = [
      me._node.getNode("size[0]").getValue(),
      me._node.getNode("size[1]").getValue()
    ];
    me._canvas = new({
      size: [2 * size_dlg[0], 2 * size_dlg[1]],
      view: size_dlg,
      placement: {
        type: "window",
        index: me._node.getIndex()
      }
    });
  },
  setPosition: func(x, y)
  {
    me._node.getNode("x", 1).setIntValue(x);
    me._node.getNode("y", 1).setIntValue(y);
  },
  setCanvas: func(canvas_)
  {
    if( !isa(canvas_, canvas.Canvas) )
      return debug.warn("Not a canvas.Canvas");
      
    canvas_.addPlacement({type: "window", index: me._node.getIndex()});
  },
  move: func(x, y)
  {
    me._node.getNode("x", 1).setIntValue(me._node.getNode("x", 1).getValue() + x);
    me._node.getNode("y", 1).setIntValue(me._node.getNode("y", 1).getValue() + y);
  }
};
