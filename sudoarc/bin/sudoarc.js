environment = [{}];
target = "js";
nil63 = function (x) {
  return(x === undefined || x === null);
};
is63 = function (x) {
  return(! nil63(x));
};
_35 = function (x) {
  return(x.length || 0);
};
none63 = function (x) {
  return(_35(x) === 0);
};
some63 = function (x) {
  return(_35(x) > 0);
};
one63 = function (x) {
  return(_35(x) === 1);
};
two63 = function (x) {
  return(_35(x) === 2);
};
hd = function (l) {
  return(l[0]);
};
type = function (x) {
  return(typeof(x));
};
string63 = function (x) {
  return(type(x) === "string");
};
number63 = function (x) {
  return(type(x) === "number");
};
boolean63 = function (x) {
  return(type(x) === "boolean");
};
function63 = function (x) {
  return(type(x) === "function");
};
obj63 = function (x) {
  return(is63(x) && type(x) === "object");
};
atom63 = function (x) {
  return(nil63(x) || string63(x) || number63(x) || boolean63(x) || function63(x));
};
nan = 0 / 0;
inf = 1 / 0;
nan63 = function (n) {
  return(!( n === n));
};
inf63 = function (n) {
  return(n === inf || n === -inf);
};
clip = function (s, from, upto) {
  return(s.substring(from, upto));
};
cut = function (x, from, upto) {
  var l = [];
  var j = 0;
  var _e;
  if (nil63(from) || from < 0) {
    _e = 0;
  } else {
    _e = from;
  }
  var i = _e;
  var n = _35(x);
  var _e1;
  if (nil63(upto) || upto > n) {
    _e1 = n;
  } else {
    _e1 = upto;
  }
  var _upto = _e1;
  while (i < _upto) {
    l[j] = x[i];
    i = i + 1;
    j = j + 1;
  }
  var _o = x;
  var k = undefined;
  for (k in _o) {
    var v = _o[k];
    var _e2;
    if (numeric63(k)) {
      _e2 = parseInt(k);
    } else {
      _e2 = k;
    }
    var _k = _e2;
    if (! number63(_k)) {
      l[_k] = v;
    }
  }
  return(l);
};
keys = function (x) {
  var t = [];
  var _o1 = x;
  var k = undefined;
  for (k in _o1) {
    var v = _o1[k];
    var _e3;
    if (numeric63(k)) {
      _e3 = parseInt(k);
    } else {
      _e3 = k;
    }
    var _k1 = _e3;
    if (! number63(_k1)) {
      t[_k1] = v;
    }
  }
  return(t);
};
edge = function (x) {
  return(_35(x) - 1);
};
inner = function (x) {
  return(clip(x, 1, edge(x)));
};
tl = function (l) {
  return(cut(l, 1));
};
char = function (s, n) {
  return(s.charAt(n));
};
code = function (s, n) {
  return(s.charCodeAt(n));
};
string_literal63 = function (x) {
  return(string63(x) && char(x, 0) === "\"");
};
id_literal63 = function (x) {
  return(string63(x) && char(x, 0) === "|");
};
add = function (l, x) {
  l.push(x);
  return(undefined);
};
drop = function (l) {
  return(l.pop());
};
last = function (l) {
  return(l[edge(l)]);
};
almost = function (l) {
  return(cut(l, 0, edge(l)));
};
reverse = function (l) {
  var l1 = keys(l);
  var i = edge(l);
  while (i >= 0) {
    add(l1, l[i]);
    i = i - 1;
  }
  return(l1);
};
reduce = function (f, x) {
  if (none63(x)) {
    return(x);
  } else {
    if (one63(x)) {
      return(hd(x));
    } else {
      return(f(hd(x), reduce(f, tl(x))));
    }
  }
};
join = function () {
  var ls = unstash(Array.prototype.slice.call(arguments, 0));
  if (two63(ls)) {
    var _id = ls;
    var a = _id[0];
    var b = _id[1];
    if (a && b) {
      var c = [];
      var o = _35(a);
      var _o2 = a;
      var k = undefined;
      for (k in _o2) {
        var v = _o2[k];
        var _e4;
        if (numeric63(k)) {
          _e4 = parseInt(k);
        } else {
          _e4 = k;
        }
        var _k2 = _e4;
        c[_k2] = v;
      }
      var _o3 = b;
      var k = undefined;
      for (k in _o3) {
        var v = _o3[k];
        var _e5;
        if (numeric63(k)) {
          _e5 = parseInt(k);
        } else {
          _e5 = k;
        }
        var _k3 = _e5;
        if (number63(_k3)) {
          _k3 = _k3 + o;
        }
        c[_k3] = v;
      }
      return(c);
    } else {
      return(a || b || []);
    }
  } else {
    return(reduce(join, ls));
  }
};
find = function (f, t) {
  var _o4 = t;
  var _i4 = undefined;
  for (_i4 in _o4) {
    var x = _o4[_i4];
    var _e6;
    if (numeric63(_i4)) {
      _e6 = parseInt(_i4);
    } else {
      _e6 = _i4;
    }
    var __i4 = _e6;
    var y = f(x);
    if (y) {
      return(y);
    }
  }
};
first = function (f, l) {
  var _x1 = l;
  var _n5 = _35(_x1);
  var _i5 = 0;
  while (_i5 < _n5) {
    var x = _x1[_i5];
    var y = f(x);
    if (y) {
      return(y);
    }
    _i5 = _i5 + 1;
  }
};
in63 = function (x, t) {
  return(find(function (y) {
    return(x === y);
  }, t));
};
pair = function (l) {
  var l1 = [];
  var i = 0;
  while (i < _35(l)) {
    add(l1, [l[i], l[i + 1]]);
    i = i + 1;
    i = i + 1;
  }
  return(l1);
};
tuple = function (lst, n) {
  if (nil63(n)) {
    n = 2;
  }
  var l1 = [];
  var i = 0;
  while (i < _35(lst)) {
    var l2 = [];
    var j = 0;
    while (j < n) {
      add(l2, lst[i + j]);
      j = j + 1;
    }
    add(l1, l2);
    i = i + (n - 1);
    i = i + 1;
  }
  return(l1);
};
vals = function (lst) {
  var r = [];
  var _x3 = lst;
  var _n6 = _35(_x3);
  var _i6 = 0;
  while (_i6 < _n6) {
    var x = _x3[_i6];
    add(r, x);
    _i6 = _i6 + 1;
  }
  return(r);
};
sort = function (l, f) {
  var _e7;
  if (f) {
    _e7 = function (a, b) {
      if (f(a, b)) {
        return(-1);
      } else {
        return(1);
      }
    };
  }
  return(l.sort(_e7));
};
map = function (f, x) {
  var t = [];
  var _x4 = x;
  var _n7 = _35(_x4);
  var _i7 = 0;
  while (_i7 < _n7) {
    var v = _x4[_i7];
    var y = f(v);
    if (is63(y)) {
      add(t, y);
    }
    _i7 = _i7 + 1;
  }
  var _o5 = x;
  var k = undefined;
  for (k in _o5) {
    var v = _o5[k];
    var _e8;
    if (numeric63(k)) {
      _e8 = parseInt(k);
    } else {
      _e8 = k;
    }
    var _k4 = _e8;
    if (! number63(_k4)) {
      var y = f(v);
      if (is63(y)) {
        t[_k4] = y;
      }
    }
  }
  return(t);
};
keep = function (f, x) {
  return(map(function (v) {
    if (f(v)) {
      return(v);
    }
  }, x));
};
keys63 = function (t) {
  var _o6 = t;
  var k = undefined;
  for (k in _o6) {
    var v = _o6[k];
    var _e9;
    if (numeric63(k)) {
      _e9 = parseInt(k);
    } else {
      _e9 = k;
    }
    var _k5 = _e9;
    if (! number63(_k5)) {
      return(true);
    }
  }
  return(false);
};
empty63 = function (t) {
  var _o7 = t;
  var _i10 = undefined;
  for (_i10 in _o7) {
    var x = _o7[_i10];
    var _e10;
    if (numeric63(_i10)) {
      _e10 = parseInt(_i10);
    } else {
      _e10 = _i10;
    }
    var __i10 = _e10;
    return(false);
  }
  return(true);
};
stash = function (args) {
  if (keys63(args)) {
    var p = [];
    var _o8 = args;
    var k = undefined;
    for (k in _o8) {
      var v = _o8[k];
      var _e11;
      if (numeric63(k)) {
        _e11 = parseInt(k);
      } else {
        _e11 = k;
      }
      var _k6 = _e11;
      if (! number63(_k6)) {
        p[_k6] = v;
      }
    }
    p._stash = true;
    add(args, p);
  }
  return(args);
};
unstash = function (args) {
  if (none63(args)) {
    return([]);
  } else {
    var l = last(args);
    if (! atom63(l) && l._stash) {
      var args1 = almost(args);
      var _o9 = l;
      var k = undefined;
      for (k in _o9) {
        var v = _o9[k];
        var _e12;
        if (numeric63(k)) {
          _e12 = parseInt(k);
        } else {
          _e12 = k;
        }
        var _k7 = _e12;
        if (!( _k7 === "_stash")) {
          args1[_k7] = v;
        }
      }
      return(args1);
    } else {
      return(args);
    }
  }
};
search = function (s, pattern, start) {
  var i = s.indexOf(pattern, start);
  if (i >= 0) {
    return(i);
  }
};
split = function (s, sep) {
  if (s === "" || sep === "") {
    return([]);
  } else {
    var l = [];
    var n = _35(sep);
    while (true) {
      var i = search(s, sep);
      if (nil63(i)) {
        break;
      } else {
        add(l, clip(s, 0, i));
        s = clip(s, i + n);
      }
    }
    add(l, s);
    return(l);
  }
};
cat = function () {
  var xs = unstash(Array.prototype.slice.call(arguments, 0));
  if (none63(xs)) {
    return("");
  } else {
    return(reduce(function (a, b) {
      return(a + b);
    }, xs));
  }
};
_43 = function () {
  var xs = unstash(Array.prototype.slice.call(arguments, 0));
  return(reduce(function (a, b) {
    return(a + b);
  }, xs));
};
_ = function () {
  var xs = unstash(Array.prototype.slice.call(arguments, 0));
  return(reduce(function (b, a) {
    return(a - b);
  }, reverse(xs)));
};
_42 = function () {
  var xs = unstash(Array.prototype.slice.call(arguments, 0));
  return(reduce(function (a, b) {
    return(a * b);
  }, xs));
};
_47 = function () {
  var xs = unstash(Array.prototype.slice.call(arguments, 0));
  return(reduce(function (b, a) {
    return(a / b);
  }, reverse(xs)));
};
_37 = function () {
  var xs = unstash(Array.prototype.slice.call(arguments, 0));
  return(reduce(function (b, a) {
    return(a % b);
  }, reverse(xs)));
};
_62 = function (a, b) {
  return(a > b);
};
_60 = function (a, b) {
  return(a < b);
};
_61 = function (a, b) {
  return(a === b);
};
_6261 = function (a, b) {
  return(a >= b);
};
_6061 = function (a, b) {
  return(a <= b);
};
number = function (s) {
  var n = parseFloat(s);
  if (! isNaN(n)) {
    return(n);
  }
};
number_code63 = function (n) {
  return(n > 47 && n < 58);
};
numeric63 = function (s) {
  var n = _35(s);
  var i = 0;
  while (i < n) {
    if (! number_code63(code(s, i))) {
      return(false);
    }
    i = i + 1;
  }
  return(true);
};
var tostring = function (x) {
  return(x.toString());
};
escape = function (s) {
  var s1 = "\"";
  var i = 0;
  while (i < _35(s)) {
    var c = char(s, i);
    var _e13;
    if (c === "\n") {
      _e13 = "\\n";
    } else {
      var _e14;
      if (c === "\"") {
        _e14 = "\\\"";
      } else {
        var _e15;
        if (c === "\\") {
          _e15 = "\\\\";
        } else {
          _e15 = c;
        }
        _e14 = _e15;
      }
      _e13 = _e14;
    }
    var c1 = _e13;
    s1 = s1 + c1;
    i = i + 1;
  }
  return(s1 + "\"");
};
str = function (x, depth, ancestors) {
  if (nil63(x)) {
    return("nil");
  } else {
    if (nan63(x)) {
      return("nan");
    } else {
      if (x === inf) {
        return("inf");
      } else {
        if (x === -inf) {
          return("-inf");
        } else {
          if (boolean63(x)) {
            if (x) {
              return("true");
            } else {
              return("false");
            }
          } else {
            if (string63(x)) {
              return(escape(x));
            } else {
              if (atom63(x)) {
                return(tostring(x));
              } else {
                if (function63(x)) {
                  return("fn");
                } else {
                  if (! obj63(x)) {
                    return("|" + type(x) + "|");
                  } else {
                    var s = "(";
                    var sp = "";
                    var xs = [];
                    var ks = [];
                    var d = (depth || 0) + 1;
                    var ans = join([x], ancestors || []);
                    if (in63(x, ancestors || [])) {
                      return("circular");
                    }
                    var _o10 = x;
                    var k = undefined;
                    for (k in _o10) {
                      var v = _o10[k];
                      var _e16;
                      if (numeric63(k)) {
                        _e16 = parseInt(k);
                      } else {
                        _e16 = k;
                      }
                      var _k8 = _e16;
                      if (number63(_k8)) {
                        xs[_k8] = str(v, d, ans);
                      } else {
                        add(ks, _k8 + ":");
                        add(ks, str(v, d, ans));
                      }
                    }
                    var _o11 = join(xs, ks);
                    var _i14 = undefined;
                    for (_i14 in _o11) {
                      var v = _o11[_i14];
                      var _e17;
                      if (numeric63(_i14)) {
                        _e17 = parseInt(_i14);
                      } else {
                        _e17 = _i14;
                      }
                      var __i14 = _e17;
                      s = s + sp + v;
                      sp = " ";
                    }
                    return(s + ")");
                  }
                }
              }
            }
          }
        }
      }
    }
  }
};
apply = function (f, args) {
  var _args = stash(args);
  return(f.apply(f, _args));
};
call = function (f) {
  return(f());
};
toplevel63 = function () {
  return(one63(environment));
};
setenv = function (k) {
  var _r71 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id1 = _r71;
  var _keys = cut(_id1, 0);
  if (string63(k)) {
    var _e18;
    if (_keys.toplevel) {
      _e18 = hd(environment);
    } else {
      _e18 = last(environment);
    }
    var frame = _e18;
    var entry = frame[k] || {};
    var _o12 = _keys;
    var _k9 = undefined;
    for (_k9 in _o12) {
      var v = _o12[_k9];
      var _e19;
      if (numeric63(_k9)) {
        _e19 = parseInt(_k9);
      } else {
        _e19 = _k9;
      }
      var _k10 = _e19;
      entry[_k10] = v;
    }
    frame[k] = entry;
    return(frame[k]);
  }
};
print = function (x) {
  return(console.log(x));
};
var math = Math;
abs = math.abs;
acos = math.acos;
asin = math.asin;
atan = math.atan;
atan2 = math.atan2;
ceil = math.ceil;
cos = math.cos;
floor = math.floor;
log = math.log;
log10 = math.log10;
max = math.max;
min = math.min;
pow = math.pow;
random = math.random;
sin = math.sin;
sinh = math.sinh;
sqrt = math.sqrt;
tan = math.tan;
tanh = math.tanh;
setenv("quote", {_stash: true, macro: function (form) {
  return(quoted(form));
}});
setenv("quasiquote", {_stash: true, macro: function (form) {
  return(quasiexpand(form, 1));
}});
setenv("at", {_stash: true, macro: function (l, i) {
  if (target === "lua" && number63(i)) {
    i = i + 1;
  } else {
    if (target === "lua") {
      i = ["+", i, 1];
    }
  }
  return(["get", l, i]);
}});
setenv("wipe", {_stash: true, macro: function (place) {
  if (target === "lua") {
    return(["set", place, "nil"]);
  } else {
    return(["%delete", place]);
  }
}});
setenv("list", {_stash: true, macro: function () {
  var body = unstash(Array.prototype.slice.call(arguments, 0));
  var x = unique("x");
  var l = [];
  var forms = [];
  var _o1 = body;
  var k = undefined;
  for (k in _o1) {
    var v = _o1[k];
    var _e3;
    if (numeric63(k)) {
      _e3 = parseInt(k);
    } else {
      _e3 = k;
    }
    var _k = _e3;
    if (number63(_k)) {
      l[_k] = v;
    } else {
      add(forms, ["set", ["get", x, ["quote", _k]], v]);
    }
  }
  if (some63(forms)) {
    return(join(["let", x, join(["%array"], l)], forms, [x]));
  } else {
    return(join(["%array"], l));
  }
}});
setenv("if", {_stash: true, macro: function () {
  var branches = unstash(Array.prototype.slice.call(arguments, 0));
  return(hd(expand_if(branches)));
}});
setenv("case", {_stash: true, macro: function (x) {
  var _r10 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id2 = _r10;
  var clauses = cut(_id2, 0);
  var bs = map(function (_x31) {
    var _id3 = _x31;
    var a = _id3[0];
    var b = _id3[1];
    if (nil63(b)) {
      return([a]);
    } else {
      return([["=", ["quote", a], x], b]);
    }
  }, pair(clauses));
  return(join(["if"], apply(join, bs)));
}});
setenv("when", {_stash: true, macro: function (cond) {
  var _r13 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id5 = _r13;
  var body = cut(_id5, 0);
  return(["if", cond, join(["do"], body)]);
}});
setenv("unless", {_stash: true, macro: function (cond) {
  var _r15 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id7 = _r15;
  var body = cut(_id7, 0);
  return(["if", ["not", cond], join(["do"], body)]);
}});
setenv("obj", {_stash: true, macro: function () {
  var body = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["%object"], mapo(function (x) {
    return(x);
  }, body)));
}});
setenv("let", {_stash: true, macro: function (bs) {
  var _r19 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id11 = _r19;
  var body = cut(_id11, 0);
  if (atom63(bs)) {
    return(join(["let", [bs, hd(body)]], tl(body)));
  } else {
    if (none63(bs)) {
      return(join(["do"], body));
    } else {
      var _id12 = bs;
      var lh = _id12[0];
      var rh = _id12[1];
      var bs2 = cut(_id12, 2);
      var _id13 = bind(lh, rh);
      var id = _id13[0];
      var val = _id13[1];
      var bs1 = cut(_id13, 2);
      var renames = [];
      if (bound63(id) || toplevel63()) {
        var id1 = unique(id);
        renames = [id, id1];
        id = id1;
      } else {
        setenv(id, {_stash: true, variable: true});
      }
      return(["do", ["%local", id, val], ["let-symbol", renames, join(["let", join(bs1, bs2)], body)]]);
    }
  }
}});
setenv("with", {_stash: true, macro: function (x, v) {
  var _r21 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id15 = _r21;
  var body = cut(_id15, 0);
  return(join(["let", [x, v]], body, [x]));
}});
setenv("let-when", {_stash: true, macro: function (x, v) {
  var _r23 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id17 = _r23;
  var body = cut(_id17, 0);
  var y = unique("y");
  return(["let", y, v, ["when", y, join(["let", [x, y]], body)]]);
}});
setenv("define-macro", {_stash: true, macro: function (name, args) {
  var _r25 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id19 = _r25;
  var body = cut(_id19, 0);
  var _x89 = ["setenv", ["quote", name]];
  _x89.macro = join(["fn", args], body);
  var form = _x89;
  eval(form);
  return(form);
}});
setenv("define-special", {_stash: true, macro: function (name, args) {
  var _r27 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id21 = _r27;
  var body = cut(_id21, 0);
  var _x96 = ["setenv", ["quote", name]];
  _x96.special = join(["fn", args], body);
  var form = join(_x96, keys(body));
  eval(form);
  return(form);
}});
setenv("define-symbol", {_stash: true, macro: function (name, expansion) {
  setenv(name, {_stash: true, symbol: expansion});
  var _x102 = ["setenv", ["quote", name]];
  _x102.symbol = ["quote", expansion];
  return(_x102);
}});
setenv("define-reader", {_stash: true, macro: function (_x111) {
  var _id24 = _x111;
  var char = _id24[0];
  var s = _id24[1];
  var _r31 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id25 = _r31;
  var body = cut(_id25, 0);
  return(["set", ["get", "read-table", char], join(["fn", [s]], body)]);
}});
setenv("define", {_stash: true, macro: function (name, x) {
  var _r33 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id27 = _r33;
  var body = cut(_id27, 0);
  setenv(name, {_stash: true, variable: true});
  if (some63(body)) {
    return(join(["%local-function", name], bind42(x, body)));
  } else {
    return(["%local", name, x]);
  }
}});
setenv("define-global", {_stash: true, macro: function (name, x) {
  var _r35 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id29 = _r35;
  var body = cut(_id29, 0);
  setenv(name, {_stash: true, toplevel: true, variable: true});
  if (some63(body)) {
    return(join(["%global-function", name], bind42(x, body)));
  } else {
    return(["set", name, x]);
  }
}});
setenv("with-frame", {_stash: true, macro: function () {
  var body = unstash(Array.prototype.slice.call(arguments, 0));
  var x = unique("x");
  return(["do", ["add", "environment", ["obj"]], ["with", x, join(["do"], body), ["drop", "environment"]]]);
}});
setenv("with-bindings", {_stash: true, macro: function (_x144) {
  var _id32 = _x144;
  var names = _id32[0];
  var _r37 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id33 = _r37;
  var body = cut(_id33, 0);
  var x = unique("x");
  var _x147 = ["setenv", x];
  _x147.variable = true;
  return(join(["with-frame", ["each", x, names, _x147]], body));
}});
setenv("let-macro", {_stash: true, macro: function (definitions) {
  var _r40 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id35 = _r40;
  var body = cut(_id35, 0);
  add(environment, {});
  map(function (m) {
    return(macroexpand(join(["define-macro"], m)));
  }, definitions);
  var _x152 = join(["do"], macroexpand(body));
  drop(environment);
  return(_x152);
}});
setenv("let-symbol", {_stash: true, macro: function (expansions) {
  var _r44 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id38 = _r44;
  var body = cut(_id38, 0);
  add(environment, {});
  map(function (_x161) {
    var _id39 = _x161;
    var name = _id39[0];
    var exp = _id39[1];
    return(macroexpand(["define-symbol", name, exp]));
  }, pair(expansions));
  var _x160 = join(["do"], macroexpand(body));
  drop(environment);
  return(_x160);
}});
setenv("let-unique", {_stash: true, macro: function (names) {
  var _r48 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id41 = _r48;
  var body = cut(_id41, 0);
  var bs = map(function (n) {
    return([n, ["unique", ["quote", n]]]);
  }, names);
  return(join(["let", apply(join, bs)], body));
}});
setenv("fn", {_stash: true, macro: function (args) {
  var _r51 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id43 = _r51;
  var body = cut(_id43, 0);
  return(join(["%function"], bind42(args, body)));
}});
setenv("guard", {_stash: true, macro: function (expr) {
  if (target === "js") {
    return([["fn", join(), ["%try", ["list", true, expr]]]]);
  } else {
    var x = unique("x");
    var msg = unique("msg");
    var trace = unique("trace");
    return(["let", [x, "nil", msg, "nil", trace, "nil"], ["if", ["xpcall", ["fn", join(), ["set", x, expr]], ["fn", ["m"], ["set", msg, ["clip", "m", ["+", ["search", "m", "\": \""], 2]]], ["set", trace, [["get", "debug", ["quote", "traceback"]]]]]], ["list", true, x], ["list", false, msg, trace]]]);
  }
}});
setenv("each", {_stash: true, macro: function (x, t) {
  var _r55 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id46 = _r55;
  var body = cut(_id46, 0);
  var o = unique("o");
  var n = unique("n");
  var i = unique("i");
  var _e4;
  if (atom63(x)) {
    _e4 = [i, x];
  } else {
    var _e5;
    if (_35(x) > 1) {
      _e5 = x;
    } else {
      _e5 = [i, hd(x)];
    }
    _e4 = _e5;
  }
  var _id47 = _e4;
  var k = _id47[0];
  var v = _id47[1];
  var _e6;
  if (target === "lua") {
    _e6 = body;
  } else {
    _e6 = [join(["let", k, ["if", ["numeric?", k], ["parseInt", k], k]], body)];
  }
  return(["let", [o, t, k, "nil"], ["%for", o, k, join(["let", [v, ["get", o, k]]], _e6)]]);
}});
setenv("for", {_stash: true, macro: function (i, to) {
  var _r57 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id49 = _r57;
  var body = cut(_id49, 0);
  return(["let", i, 0, join(["while", ["<", i, to]], body, [["inc", i]])]);
}});
setenv("step", {_stash: true, macro: function (v, t) {
  var _r59 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id51 = _r59;
  var body = cut(_id51, 0);
  var x = unique("x");
  var n = unique("n");
  var i = unique("i");
  return(["let", [x, t, n, ["#", x]], ["for", i, n, join(["let", [v, ["at", x, i]]], body)]]);
}});
setenv("set-of", {_stash: true, macro: function () {
  var xs = unstash(Array.prototype.slice.call(arguments, 0));
  var l = [];
  var _o3 = xs;
  var _i3 = undefined;
  for (_i3 in _o3) {
    var x = _o3[_i3];
    var _e7;
    if (numeric63(_i3)) {
      _e7 = parseInt(_i3);
    } else {
      _e7 = _i3;
    }
    var __i3 = _e7;
    l[x] = true;
  }
  return(join(["obj"], l));
}});
setenv("language", {_stash: true, macro: function () {
  return(["quote", target]);
}});
setenv("target", {_stash: true, macro: function () {
  var clauses = unstash(Array.prototype.slice.call(arguments, 0));
  return(clauses[target]);
}});
setenv("join!", {_stash: true, macro: function (a) {
  var _r63 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id53 = _r63;
  var bs = cut(_id53, 0);
  return(["set", a, join(["join", a], bs)]);
}});
setenv("cat!", {_stash: true, macro: function (a) {
  var _r65 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id55 = _r65;
  var bs = cut(_id55, 0);
  return(["set", a, join(["cat", a], bs)]);
}});
setenv("inc", {_stash: true, macro: function (n, by) {
  return(["set", n, ["+", n, by || 1]]);
}});
setenv("dec", {_stash: true, macro: function (n, by) {
  return(["set", n, ["-", n, by || 1]]);
}});
setenv("with-indent", {_stash: true, macro: function (form) {
  var x = unique("x");
  return(["do", ["inc", "indent-level"], ["with", x, form, ["dec", "indent-level"]]]);
}});
setenv("export", {_stash: true, macro: function () {
  var names = unstash(Array.prototype.slice.call(arguments, 0));
  if (target === "js") {
    return(join(["do"], map(function (k) {
      return(["set", ["get", "exports", ["quote", k]], k]);
    }, names)));
  } else {
    var x = {};
    var _o5 = names;
    var _i5 = undefined;
    for (_i5 in _o5) {
      var k = _o5[_i5];
      var _e8;
      if (numeric63(_i5)) {
        _e8 = parseInt(_i5);
      } else {
        _e8 = _i5;
      }
      var __i5 = _e8;
      x[k] = k;
    }
    return(["return", join(["obj"], x)]);
  }
}});
var reader = require("reader");
var compiler = require("compiler");
var system = require("system");
pretty_print = function (x) {
  return(print(str(x)));
};
eval_print = function (form) {
  var _id = (function () {
    try {
      return([true, compiler.eval(form)]);
    }
    catch (_e) {
      return([false, _e.message, _e.stack]);
    }
  })();
  var ok = _id[0];
  var x = _id[1];
  var trace = _id[2];
  if (! ok) {
    return(print(trace));
  } else {
    if (is63(x)) {
      return(pretty_print(x));
    }
  }
};
var rep = function (s) {
  return(eval_print(reader["read-string"](s)));
};
repl = function () {
  var buf = "";
  var rep1 = function (s) {
    buf = buf + s;
    var more = [];
    var form = reader["read-string"](buf, more);
    if (!( form === more)) {
      eval_print(form);
      buf = "";
      return(system.write("> "));
    }
  };
  system.write("> ");
  var _in = process.stdin;
  _in.removeAllListeners();
  _in.setEncoding("utf8");
  return(_in.on("data", rep1));
};
compile_file = function (path) {
  var s = reader.stream(system["read-file"](path));
  var body = reader["read-all"](s);
  var form = compiler.expand(join(["do"], body));
  return(compiler.compile(form, {_stash: true, stmt: true}));
};
load = function (path) {
  return(compiler.run(compile_file(path)));
};
var run_file = function (path) {
  return(compiler.run(system["read-file"](path)));
};
var usage = function () {
  print("usage: lumen [options] <object files>");
  print("options:");
  print("  -c <input>\tCompile input file");
  print("  -o <output>\tOutput file");
  print("  -t <target>\tTarget language (default: lua)");
  print("  -e <expr>\tExpression to evaluate");
  return(system.exit());
};
var main = function () {
  var arg = hd(system.argv);
  if (arg === "-h" || arg === "--help") {
    usage();
  }
  var pre = [];
  var input = undefined;
  var output = undefined;
  var target1 = undefined;
  var expr = undefined;
  var argv = system.argv;
  var n = _35(argv);
  var i = 0;
  while (i < n) {
    var a = argv[i];
    if (a === "-c" || a === "-o" || a === "-t" || a === "-e") {
      if (i === n - 1) {
        print("missing argument for " + a);
      } else {
        i = i + 1;
        var val = argv[i];
        if (a === "-c") {
          input = val;
        } else {
          if (a === "-o") {
            output = val;
          } else {
            if (a === "-t") {
              target1 = val;
            } else {
              if (a === "-e") {
                expr = val;
              }
            }
          }
        }
      }
    } else {
      if (!( "-" === char(a, 0))) {
        add(pre, a);
      }
    }
    i = i + 1;
  }
  var _x2 = pre;
  var _n = _35(_x2);
  var _i = 0;
  while (_i < _n) {
    var file = _x2[_i];
    run_file(file);
    _i = _i + 1;
  }
  if (nil63(input)) {
    if (expr) {
      return(rep(expr));
    } else {
      return(repl());
    }
  } else {
    if (target1) {
      target = target1;
    }
    var code = compile_file(input);
    if (nil63(output) || output === "-") {
      return(print(code));
    } else {
      return(system["write-file"](output, code));
    }
  }
};
setenv("void", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["do"], l, ["nil"]));
}});
setenv("alias", {_stash: true, macro: function (newname, oldname) {
  return(["define-macro", newname, "l", ["quasiquote", [["unquote", ["quote", oldname]], ["unquote-splicing", "l"]]]]);
}});
setenv("var", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["define"], l));
}});
setenv("def", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["define-global"], l));
}});
setenv("sym", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["define-symbol"], l));
}});
setenv("mac", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["define-macro"], l));
}});
setenv("special", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["define-special"], l));
}});
setenv("curly", {_stash: true, macro: function (module, func) {
  return(["get", module, ["quote", func]]);
}});
setenv("multi", {_stash: true, macro: function (name, val, argc) {
  if (nil63(argc)) {
    argc = 2;
  }
  if (atom63(val)) {
    var _x65 = ["x"];
    _x65.rest = "ys";
    return(["mac", name, "l", ["with", "e", ["quote", ["do"]], ["step", _x65, ["tuple", "l", argc], ["add", "e", ["quasiquote", [["unquote", ["quote", val]], ["unquote", "x"], ["unquote-splicing", "ys"]]]]]]]);
  } else {
    var _x82 = ["x"];
    _x82.rest = "ys";
    return(["mac", name, "l", ["with", "e", ["quote", ["do"]], ["step", "it", ["tuple", "l", argc], ["let", [_x82, "it"], ["add", "e", val]]]]]);
  }
}});
setenv("vars", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["do"];
  var _x89 = tuple(l, 2);
  var _n1 = _35(_x89);
  var _i1 = 0;
  while (_i1 < _n1) {
    var _id1 = _x89[_i1];
    var x = _id1[0];
    var ys = cut(_id1, 1);
    add(e, join(["var", x], ys));
    _i1 = _i1 + 1;
  }
  return(e);
}});
setenv("defs", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["do"];
  var _x96 = tuple(l, 2);
  var _n3 = _35(_x96);
  var _i3 = 0;
  while (_i3 < _n3) {
    var _id3 = _x96[_i3];
    var x = _id3[0];
    var ys = cut(_id3, 1);
    add(e, join(["def", x], ys));
    _i3 = _i3 + 1;
  }
  return(e);
}});
setenv("syms", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["do"];
  var _x103 = tuple(l, 2);
  var _n5 = _35(_x103);
  var _i5 = 0;
  while (_i5 < _n5) {
    var _id5 = _x103[_i5];
    var x = _id5[0];
    var ys = cut(_id5, 1);
    add(e, join(["sym", x], ys));
    _i5 = _i5 + 1;
  }
  return(e);
}});
setenv("macs", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["do"];
  var _x110 = tuple(l, 3);
  var _n7 = _35(_x110);
  var _i7 = 0;
  while (_i7 < _n7) {
    var _id7 = _x110[_i7];
    var x = _id7[0];
    var ys = cut(_id7, 1);
    add(e, join(["mac", x], ys));
    _i7 = _i7 + 1;
  }
  return(e);
}});
setenv("specials", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["do"];
  var _x117 = tuple(l, 3);
  var _n9 = _35(_x117);
  var _i9 = 0;
  while (_i9 < _n9) {
    var _id9 = _x117[_i9];
    var x = _id9[0];
    var ys = cut(_id9, 1);
    add(e, join(["special", x], ys));
    _i9 = _i9 + 1;
  }
  return(e);
}});
setenv("lib", {_stash: true, macro: function (name) {
  return(["def", name, ["require", ["quote", name]]]);
}});
setenv("use", {_stash: true, macro: function (name) {
  return(["var", name, ["require", ["quote", name]]]);
}});
setenv("libs", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["do"];
  var _x136 = tuple(l, 1);
  var _n11 = _35(_x136);
  var _i11 = 0;
  while (_i11 < _n11) {
    var _id11 = _x136[_i11];
    var x = _id11[0];
    var ys = cut(_id11, 1);
    add(e, join(["lib", x], ys));
    _i11 = _i11 + 1;
  }
  return(e);
}});
setenv("uses", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["do"];
  var _x143 = tuple(l, 1);
  var _n13 = _35(_x143);
  var _i13 = 0;
  while (_i13 < _n13) {
    var _id13 = _x143[_i13];
    var x = _id13[0];
    var ys = cut(_id13, 1);
    add(e, join(["use", x], ys));
    _i13 = _i13 + 1;
  }
  return(e);
}});
var compiler = require("compiler");
var reader = require("reader");
var system = require("system");
var stream = reader.stream;
var read_all = reader["read-all"];
var read_file = system["read-file"];
var write_file = system["write-file"];
env = system["get-environment-variable"];
macex = compiler.expand;
comp = function (_) {
  return(print(compile(macex(_))));
};
write1 = system.write;
write = function (_) {
  write1(tostr(_));
  return(undefined);
};
setenv("t", {_stash: true, symbol: true});
err = function (msg) {
  var _r12 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id14 = _r12;
  var l = cut(_id14, 0);
  if (nil63(msg)) {
    msg = "fatal";
  }
  var _e3;
  if (none63(l)) {
    _e3 = tostr(msg);
  } else {
    _e3 = apply(cat, join([tostr(msg), ": "], map(str, l)));
  }
  var x = _e3;
  throw new Error(x);
};
setenv("cmp", {_stash: true, macro: function (x, y) {
  return(["=", ["do", x], ["do", y]]);
}});
setenv("def?", {_stash: true, macro: function (x) {
  return(["not", ["cmp", ["typeof", x], "\"undefined\""]]);
}});
testify = function (x) {
  if (function63(x)) {
    return(x);
  } else {
    return(function (_) {
      return(_ === x);
    });
  }
};
fn63 = function63;
str63 = string63;
num63 = number63;
atom = atom63;
false63 = testify(false);
lst63 = obj63;
list63 = obj63;
len = _35;
idfn = function (_) {
  return(_);
};
tostr = function (_) {
  if (str63(_)) {
    return(_);
  } else {
    return(str(_));
  }
};
tolist = function (_) {
  if (list63(_)) {
    return(_);
  } else {
    return([_]);
  }
};
parts = function (_) {
  return([vals(_), keys(_)]);
};
acons = function (_) {
  return(! atom63(_));
};
alist = function (_) {
  return(acons(_) && (keys63(_) || some63(_)));
};
empty = function (_) {
  return(acons(_) && ! keys63(_) && none63(_));
};
no = function (_) {
  return(nil63(_) || false63(_) || empty(_));
};
t63 = function (_) {
  return(! no(_));
};
setenv("is", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  if (one63(l)) {
    return(["not", join(["no"], l)]);
  } else {
    return(join(["cmp"], l));
  }
}});
setenv("isnt", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  if (one63(l)) {
    return(join(["no"], l));
  } else {
    return(["not", join(["cmp"], l)]);
  }
}});
map1 = function (f, lst) {
  o(lst, []);
  var val = undefined;
  var _x172 = lst;
  var _n14 = _35(_x172);
  var _i14 = 0;
  while (_i14 < _n14) {
    var x = _x172[_i14];
    val = f(x);
    _i14 = _i14 + 1;
  }
  return(val);
};
mapnil = function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  apply(map1, l);
  return(undefined);
};
setenv("assert", {_stash: true, macro: function () {
  var xs = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["let", "bad", "nil"];
  var _x184 = xs;
  var _n16 = _35(_x184);
  var _i16 = 0;
  while (_i16 < _n16) {
    var cond = _x184[_i16];
    add(e, ["unless", ["do", cond], ["set", "bad", ["quote", str(cond)]]]);
    _i16 = _i16 + 1;
  }
  add(e, ["when", ["is?", "bad"], ["err", "\"assertion failed\"", "bad"]]);
  return(e);
}});
setenv("be", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["assert"], l));
}});
setenv("w/uniq", {_stash: true, macro: function (x) {
  var _r30 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id16 = _r30;
  var body = cut(_id16, 0);
  if (atom63(x)) {
    return(join(["let-unique", [x]], body));
  } else {
    return(join(["let-unique", x], body));
  }
}});
setenv("ado", {_stash: true, macro: function (x) {
  var _r32 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id18 = _r32;
  var ys = cut(_id18, 0);
  return(join(["let", "it", x], ys));
}});
setenv("do1", {_stash: true, macro: function (x) {
  var _r34 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id20 = _r34;
  var ys = cut(_id20, 0);
  var g = unique("g");
  return(join(["let", g, x], ys, [g]));
}});
setenv("if1", {_stash: true, macro: function (x, _then) {
  var _r36 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id22 = _r36;
  var _else = cut(_id22, 0);
  return(["if", x, _then, join(["do"], _else)]);
}});
setenv("but", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["if1"], l));
}});
setenv("lastly", {_stash: true, macro: function (x) {
  var _r38 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id24 = _r38;
  var ys = cut(_id24, 0);
  return(["do1", join(["do"], ys), x]);
}});
setenv("after", {_stash: true, macro: function (x) {
  var _r40 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id26 = _r40;
  var ys = cut(_id26, 0);
  return(["let", [["ok", "v"], ["guard", ["do", x]]], ["if", "ok", "v", join(["lastly", ["err", "v"]], ys)]]);
}});
setenv("o", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var e = ["do"];
  var r = "nil";
  var _x247 = pair(l);
  var _n18 = _35(_x247);
  var _i18 = 0;
  while (_i18 < _n18) {
    var _id28 = _x247[_i18];
    var _var1 = _id28[0];
    var val = _id28[1];
    add(e, ["if", ["nil?", _var1], ["set", _var1, val]]);
    r = _var1;
    _i18 = _i18 + 1;
  }
  add(e, r);
  return(e);
}});
setenv("w/args", {_stash: true, macro: function (l, args) {
  var _r42 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id30 = _r42;
  var body = cut(_id30, 0);
  if (nil63(l)) {
    l = [];
  }
  if (nil63(args)) {
    args = [];
  }
  var g = unique("g");
  return(join(["let", [g, l, "rest", ["get", g, ["quote", "rest"]], vals(args), g, args.rest || [], ["if", "rest", "rest", ["list"]]]], body));
}});
setenv("yesno", {_stash: true, macro: function (name, body) {
  var _x278 = ["x", "yes"];
  _x278.rest = "l";
  return(["mac", name, _x278, ["o", "yes", "t"], ["quasiquote", ["ado", ["unquote", "x"], ["if", ["unquote", ["quote", body]], ["do", ["unquote", "yes"]], ["do", ["unquote-splicing", "l"]]]]]]);
}});
setenv("any?", {_stash: true, macro: function (x, yes) {
  var _r46 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id32 = _r46;
  var l = cut(_id32, 0);
  if (nil63(yes)) {
    yes = true;
  }
  return(["ado", x, ["if", ["and", ["list?", "it"], ["or", ["keys?", "it"], ["some?", "it"]]], ["do", yes], join(["do"], l)]]);
}});
setenv("0?", {_stash: true, macro: function (x, yes) {
  var _r48 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id34 = _r48;
  var l = cut(_id34, 0);
  if (nil63(yes)) {
    yes = true;
  }
  return(["ado", x, ["if", ["or", ["nil?", "it"], ["none?", "it"]], ["do", yes], join(["do"], l)]]);
}});
setenv("1?", {_stash: true, macro: function (x, yes) {
  var _r50 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id36 = _r50;
  var l = cut(_id36, 0);
  if (nil63(yes)) {
    yes = true;
  }
  return(["ado", x, ["if", ["and", ["list?", "it"], ["one?", "it"]], ["do", yes], join(["do"], l)]]);
}});
setenv("2?", {_stash: true, macro: function (x, yes) {
  var _r52 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id38 = _r52;
  var l = cut(_id38, 0);
  if (nil63(yes)) {
    yes = true;
  }
  return(["ado", x, ["if", ["and", ["list?", "it"], ["two?", "it"]], ["do", yes], join(["do"], l)]]);
}});
_any63 = function (_) {
  var bad = undefined;
  if (!( nil63(_) || list63(_))) {
    bad = "(\"or\" (\"nil?\" \"_\") (\"list?\" \"_\"))";
  }
  if (is63(bad)) {
    err("assertion failed", bad);
  }
  var it = _;
  if (list63(it) && (keys63(it) || some63(it))) {
    return(true);
  }
};
_063 = function (_) {
  var bad = undefined;
  if (!( nil63(_) || list63(_))) {
    bad = "(\"or\" (\"nil?\" \"_\") (\"list?\" \"_\"))";
  }
  if (is63(bad)) {
    err("assertion failed", bad);
  }
  var it = _;
  if (nil63(it) || none63(it)) {
    return(true);
  }
};
_163 = function (_) {
  var bad = undefined;
  if (!( nil63(_) || list63(_))) {
    bad = "(\"or\" (\"nil?\" \"_\") (\"list?\" \"_\"))";
  }
  if (is63(bad)) {
    err("assertion failed", bad);
  }
  var it = _;
  if (list63(it) && one63(it)) {
    return(true);
  }
};
_263 = function (_) {
  var bad = undefined;
  if (!( nil63(_) || list63(_))) {
    bad = "(\"or\" (\"nil?\" \"_\") (\"list?\" \"_\"))";
  }
  if (is63(bad)) {
    err("assertion failed", bad);
  }
  var it = _;
  if (list63(it) && two63(it)) {
    return(true);
  }
};
setenv("complement", {_stash: true, macro: function (f) {
  var g = unique("g");
  return(["fn", g, ["not", ["apply", f, g]]]);
}});
setenv("repeat", {_stash: true, macro: function (n) {
  var _r60 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id40 = _r60;
  var l = cut(_id40, 0);
  var g = unique("g");
  return(join(["for", g, n], l));
}});
setenv("push", {_stash: true, macro: function (lst, x) {
  return(["ado", lst, ["add", "it", x], "it"]);
}});
setenv("pop", {_stash: true, macro: function (lst) {
  return(["ado", lst, ["last", "it"], ["drop", "it"]]);
}});
setenv("w/push", {_stash: true, macro: function (lst, x) {
  var _r66 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id42 = _r66;
  var l = cut(_id42, 0);
  var g = unique("g");
  return(["let", g, ["push", lst, x], join(["lastly", ["pop", g]], l)]);
}});
setenv("lfn", {_stash: true, macro: function (name, args, body) {
  var _r68 = unstash(Array.prototype.slice.call(arguments, 3));
  var _id44 = _r68;
  var l = cut(_id44, 0);
  var _e4;
  if (some63(l)) {
    _e4 = l;
  } else {
    _e4 = [name];
  }
  return(join(["let", name, "nil", ["set", name, ["fn", args, body]]], _e4));
}});
setenv("afn", {_stash: true, macro: function (args, body) {
  var _r70 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id46 = _r70;
  var l = cut(_id46, 0);
  return(join(["lfn", "self", args, body], l));
}});
setenv("accum", {_stash: true, macro: function (name) {
  var _r72 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id48 = _r72;
  var body = cut(_id48, 0);
  var g = unique("g");
  return(["let", g, join(), join(["lfn", name, ["item"], ["add", g, "item"]], body), g]);
}});
setenv("bag", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["accum", "put"], l));
}});
setenv("nor", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(["not", join(["or"], l)]);
}});
setenv("ifnot", {_stash: true, macro: function (cond) {
  var _r74 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id50 = _r74;
  var l = cut(_id50, 0);
  return(join(["if", ["not", cond]], l));
}});
setenv("nif", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["ifnot"], l));
}});
setenv("iflet", {_stash: true, macro: function (name) {
  var _r76 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id53 = _r76;
  var l = cut(_id53, 0);
  if (some63(l)) {
    var _id54 = l;
    var x = _id54[0];
    var a = _id54[1];
    var bs = cut(_id54, 2);
    var _e5;
    if (one63(l)) {
      _e5 = name;
    } else {
      _e5 = ["if", name, a, join(["iflet", name], bs)];
    }
    return(["let", name, x, _e5]);
  }
}});
setenv("whenlet", {_stash: true, macro: function (name) {
  var _r78 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id57 = _r78;
  var l = cut(_id57, 0);
  if (some63(l)) {
    var _id58 = l;
    var x = _id58[0];
    var ys = cut(_id58, 1);
    var _e6;
    if (one63(l)) {
      _e6 = name;
    } else {
      _e6 = join(["do"], ys);
    }
    return(["let", name, x, _e6]);
  }
}});
setenv("aif", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["iflet", "it"], l));
}});
setenv("awhen", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["let-when", "it"], l));
}});
kvs = function (x) {
  if (acons(x)) {
    if (keys63(x)) {
      var _g = [];
      var put = undefined;
      put = function (item) {
        return(add(_g, item));
      };
      var _o = x;
      var k = undefined;
      for (k in _o) {
        var v = _o[k];
        var _e7;
        if (numeric63(k)) {
          _e7 = parseInt(k);
        } else {
          _e7 = k;
        }
        var _k = _e7;
        if (num63(_k)) {
          put(v);
        } else {
          var _x437 = [_k, v];
          _x437.key = true;
          put(_x437);
        }
      }
      return(_g);
    } else {
      return(x);
    }
  }
};
car = function (x) {
  if (! no(x)) {
    return(hd(x));
  }
};
cdr = function (x) {
  if (! no(x)) {
    var it = tl(x);
    var _it = it;
    if (nil63(_it) || none63(_it)) {
      return(kvs(_it));
    } else {
      return(_it);
    }
  }
};
caar = function (x) {
  return(car(car(x)));
};
cadr = function (x) {
  return(car(cdr(x)));
};
cddr = function (x) {
  return(cdr(cdr(x)));
};
cons = function (x, y) {
  return(join([x], y));
};
copylist = function (xs) {
  var l = [];
  var _o1 = xs;
  var k = undefined;
  for (k in _o1) {
    var v = _o1[k];
    var _e8;
    if (numeric63(k)) {
      _e8 = parseInt(k);
    } else {
      _e8 = k;
    }
    var _k1 = _e8;
    l[_k1] = v;
  }
  return(l);
};
listify = function (x) {
  if (atom63(x)) {
    return([x]);
  } else {
    return(x);
  }
};
intersperse = function (x, lst) {
  var sep = undefined;
  var _g1 = [];
  var put = undefined;
  put = function (item) {
    return(add(_g1, item));
  };
  var _o2 = lst;
  var _i21 = undefined;
  for (_i21 in _o2) {
    var item = _o2[_i21];
    var _e9;
    if (numeric63(_i21)) {
      _e9 = parseInt(_i21);
    } else {
      _e9 = _i21;
    }
    var __i21 = _e9;
    if (sep) {
      put(sep);
    } else {
      sep = x;
    }
    put(item);
  }
  return(_g1);
};
keep = function (f, xs) {
  f = testify(f);
  var _g2 = [];
  var put = undefined;
  put = function (item) {
    return(add(_g2, item));
  };
  var _x440 = xs;
  var _n22 = _35(_x440);
  var _i22 = 0;
  while (_i22 < _n22) {
    var x = _x440[_i22];
    if (f(x)) {
      put(x);
    }
    _i22 = _i22 + 1;
  }
  return(_g2);
};
rem = function (f, xs) {
  return(keep(function () {
    var _g3 = unstash(Array.prototype.slice.call(arguments, 0));
    return(! apply(testify(f), _g3));
  }, xs));
};
rev = reverse;
wschars = [" ", "\t", "\n", "\r"];
ws63 = function (s) {
  var i = 0;
  while (i < len(s)) {
    var c = char(s, i);
    if (in63(c, wschars)) {
      return(true);
    }
    i = i + 1;
  }
};
rtrim = function (s) {
  var _r95 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id59 = _r95;
  var f = _id59.f;
  while (some63(s) && (f || ws63)(char(s, edge(s)))) {
    s = clip(s, 0, edge(s));
  }
  return(s);
};
ltrim = function (s) {
  var _r96 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id60 = _r96;
  var f = _id60.f;
  while (some63(s) && (f || ws63)(char(s, 0))) {
    s = clip(s, 1, len(s));
  }
  return(s);
};
trim = function (s) {
  var _r97 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id61 = _r97;
  var f = _id61.f;
  return(rtrim(ltrim(s, {_stash: true, f: f}), {_stash: true, f: f}));
};
endswith = function (s, ending) {
  var i = len(s) - len(ending);
  return(i === search(s, ending, i));
};
startswith = function (s, prefix) {
  return(search(s, prefix) === 0);
};
pr = function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var _g4 = l;
  var rest = _g4.rest;
  var _id62 = _g4;
  var x = _id62[0];
  var _e10;
  if (rest) {
    _e10 = rest;
  } else {
    _e10 = [];
  }
  var xs = _e10;
  var _id63 = tolist(xs);
  var sep = _id63[0];
  var lh = _id63[1];
  var rh = _id63[2];
  if (nil63(sep)) {
    sep = "";
  }
  var c = undefined;
  if (lh) {
    write(lh);
  }
  if (sep) {
    var _x443 = l;
    var _n23 = _35(_x443);
    var _i23 = 0;
    while (_i23 < _n23) {
      var _x444 = _x443[_i23];
      if (c) {
        write(c);
      } else {
        c = tostr(sep);
      }
      write(tostr(_x444));
      _i23 = _i23 + 1;
    }
  } else {
    var _x445 = l;
    var _n24 = _35(_x445);
    var _i24 = 0;
    while (_i24 < _n24) {
      var _x446 = _x445[_i24];
      write(tostr(_x446));
      _i24 = _i24 + 1;
    }
  }
  if (rh) {
    write(rh);
  }
  if (l) {
    return(hd(l));
  }
};
prn = function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var _g5 = apply(pr, l);
  pr("\n");
  return(_g5);
};
p = function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  apply(prn, l);
  return(undefined);
};
filechars = function (path) {
  return(read_file(path));
};
readfile = function (path) {
  return(readstr(filechars(path)));
};
doshell = function () {
  var args = unstash(Array.prototype.slice.call(arguments, 0));
  return(rtrim(shell(apply(cat, intersperse(" ", args)))));
};
mvfile = function (src, dst) {
  doshell("mv", escape(src), escape(dst));
  return(dst);
};
getmod = function (file) {
  return(doshell("stat -r", escape(file), "| awk '{ print $3; }'"));
};
chmod = function (spec, file) {
  return(doshell("chmod", escape(spec), escape(file)));
};
chmodx = function (file) {
  return(chmod("+x", file));
};
writefile = function (path, contents) {
  doshell("cp -fp", escape(path), escape(path + ".tmp"));
  write_file(path + ".tmp", contents);
  mvfile(path + ".tmp", path);
  return(contents);
};
setenv("w/file", {_stash: true, macro: function (v, path) {
  var _r108 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id65 = _r108;
  var l = cut(_id65, 0);
  var gp = unique("gp");
  return(["let", [gp, path, v, ["filechars", gp]], ["set", v, join(["do"], l)], ["writefile", gp, v]]);
}});
args = function (_) {
  return(readstr(env("cmdline")));
};
host = function (_) {
  return(env("LUMEN_HOST") || "");
};
host63 = function (_) {
  return(search(host(), _));
};
luajit63 = function (_) {
  return(host63("luajit"));
};
comp = function (_) {
  return(print(compile(macex(_))));
};
macex = compiler.expand;
readstr = function (_) {
  return(read_all(stream(_)));
};
prnerr = function (_x460) {
  var _id66 = _x460;
  var expr = _id66[0];
  var msg = _id66[1];
  prn("Error in ", file, ": ");
  prn("   ", msg);
  prn("The error occurred while evaluating: ");
  prn(expr);
  return(msg);
};
loadstr = function (s) {
  var _r116 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id67 = _r116;
  var on_err = _id67["on-err"];
  var verbose = _id67.verbose;
  var print = _id67.print;
  var _x461 = readstr(s);
  var _n25 = _35(_x461);
  var _i25 = 0;
  while (_i25 < _n25) {
    var expr = _x461[_i25];
    if ("1" === env("VERBOSE")) {
      prn(str(expr));
    }
    if ("1" === env("COMP")) {
      prn(comp(expr));
    }
    var _id68 = (function () {
      try {
        return([true, eval(expr)]);
      }
      catch (_e11) {
        return([false, _e11.message, _e11.stack]);
      }
    })();
    var ok = _id68[0];
    var x = _id68[1];
    if (ok && print === true) {
      prn(x);
    }
    if (! ok) {
      (on_err || prnerr)([expr, x]);
    }
    _i25 = _i25 + 1;
  }
};
load = function (file) {
  var _r118 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id69 = _r118;
  var on_err = _id69["on-err"];
  var verbose = _id69.verbose;
  if (verbose) {
    prn("Loading ", file);
  }
  return(loadstr(read_file(file), {_stash: true, "on-err": on_err, verbose: verbose}));
};
shell = function (cmd) {
  var childproc = require("child_process");
  var exec = childproc.execSync;
  var _o3 = exec(cmd);
  var result = _o3.toString();
  if (env("VERBOSE")) {
    return(prn(result));
  }
};
exit = function (code) {
  return(process.exit(code));
};
appusage = function () {
  prn("  to run a script:    sudoarc foo.l");
  prn("  to get a repl:      sudoarc");
  return(prn(""));
};
script63 = function (name) {
  return(endswith(name, ".l") || endswith(name, ".arc"));
};
appmain = function (argv) {
  if (none63(argv || [])) {
    return;
  }
  var op = argv[0];
  var params = cut(argv, 1);
  if (in63(op, ["help", "h", "--help", "-h", "-?", "?", "/?", "haalp"])) {
    appusage();
    return;
  }
  if (script63(op)) {
    return(load(op));
  }
  if (in63(op, ["eval", "e"])) {
    loadstr(clip(env("cmdline"), _35(op)), {_stash: true, print: true});
    return;
  }
  if (in63(op, ["repl", "r"])) {
    return;
  }
  var _x3 = argv;
  var _n = _35(_x3);
  var _i = 0;
  while (_i < _n) {
    var arg = _x3[_i];
    if (script63(arg)) {
      load(arg);
    } else {
      throw new Error("unknown cmd " + arg);
    }
    _i = _i + 1;
  }
};
appmain(args());
main()
