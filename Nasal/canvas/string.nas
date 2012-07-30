# ------------------------------------------------------------------------------
# A C++ like string class (http://en.cppreference.com/w/cpp/string/basic_string)
# ------------------------------------------------------------------------------

# capture global string
var _string = string;

var string = {
# public:
  new: func(str)
  {
    return { parents: [string], _str: str };
  },
  find_first_of: func(s, pos = 0)
  {
    return me._find(pos, size(me._str), s, 1);
  },
  find: func(s, pos = 0)
  {
    return me.find_first_of(s, pos);
  },
  find_first_not_of: func(s, pos = 0)
  {
    return me._find(pos, size(me._str), s, 0);
  },
  substr: func(pos, len = nil)
  {
    return substr(me._str, pos, len);
  },
  size: func()
  {
    return size(me._str);
  },
# private:
  _eq: func(pos, s)
  {
    for(var i = 0; i < size(s); i += 1)
      if( me._str[pos] == s[i] )
        return 1;
    return 0;
  },
  _find: func(first, last, s, eq)
  {
    var sign = first <= last ? 1 : -1;
    for(var i = first; sign * i < last; i += sign)
      if( me._eq(i, s) == eq )
        return i;
    return -1;
  }
};

# converts a string to an unsigned integer
var stoul = func(str, base = 10)
{
  var val = 0;
  for(var pos = 0; pos < size(str); pos += 1)
  {
    var c = str[pos];

    if( _string.isdigit(c) )
      var digval = c - `0`;
    else if( _string.isalpha(c) )
      var digval = _string.toupper(c) - `A` + 10;
    else
      break;
      
    if( digval >= base )
      break;
    
    val = val * base + digval;
  }
  
  return val;
};
