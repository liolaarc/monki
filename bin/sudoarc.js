setenv("mac", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["define-macro"], l));
}});
setenv("letmac", {_stash: true, macro: function (name, args, body) {
  var _r1 = unstash(Array.prototype.slice.call(arguments, 3));
  var _id1 = _r1;
  var l = cut(_id1, 0);
  return(join(["let-macro", [[name, args, body]]], l));
}});
setenv("def", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["define-global"], l));
}});
idfn = function (x) {
  return(x);
};
setenv("w/uniq", {_stash: true, macro: function (x) {
  var _r4 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id3 = _r4;
  var body = cut(_id3, 0);
  if (atom63(x)) {
    return(join(["let-unique", [x]], body));
  } else {
    return(join(["let-unique", x], body));
  }
}});
setenv("void", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["do"], l, ["nil"]));
}});
setenv("lfn", {_stash: true, macro: function (name, args, body) {
  var _r6 = unstash(Array.prototype.slice.call(arguments, 3));
  var _id5 = _r6;
  var l = cut(_id5, 0);
  return(join(["let", name, "nil", ["set", name, ["fn", args, body]]], l));
}});
setenv("accum", {_stash: true, macro: function (name) {
  var _r8 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id7 = _r8;
  var body = cut(_id7, 0);
  var g = unique("g");
  return(["let", g, join(), join(["lfn", name, ["item"], ["add", g, "item"]], body), g]);
}});
setenv("acc", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(join(["accum", "a"], l));
}});
var __o = ["let", "each", "step", "for", "when", "while"];
var _i = undefined;
for (_i in __o) {
  var form = __o[_i];
  var _e1;
  if (numeric63(_i)) {
    _e1 = parseInt(_i);
  } else {
    _e1 = _i;
  }
  var __i = _e1;
  eval(["mac", "acc:" + form, "l", ["quasiquote", ["acc", [["unquote", ["quote", form]], ["unquote-splicing", "l"]]]]]);
}
setenv("nor", {_stash: true, macro: function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  return(["not", join(["or"], l)]);
}});
lst63 = function (x) {
  return(!( atom63(x) || function63(x)));
};
any63 = function (x) {
  return(lst63(x) && some63(x));
};
setenv("iflet", {_stash: true, macro: function (name) {
  var _r12 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id10 = _r12;
  var l = cut(_id10, 0);
  if (some63(l)) {
    var _id11 = l;
    var x = _id11[0];
    var a = _id11[1];
    var bs = cut(_id11, 2);
    var _e2;
    if (one63(l)) {
      _e2 = name;
    } else {
      _e2 = ["if", name, a, join(["iflet", name], bs)];
    }
    return(["let", name, x, _e2]);
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
intersperse = function (x, lst) {
  var sep = undefined;
  var _e3;
  if (sep) {
    _e3 = a(sep);
  } else {
    sep = x;
    _e3 = sep;
  }
  return(acc58each(item, lst, _e3, a(item)));
};
str = function (x) {
  if (string63(x)) {
    return(x);
  } else {
    return(string(x));
  }
};
pr = function () {
  var _r15 = unstash(Array.prototype.slice.call(arguments, 0));
  var _id12 = _r15;
  var sep = _id12.sep;
  var l = cut(_id12, 0);
  var c = undefined;
  if (sep) {
    var _x58 = l;
    var _n1 = _35(_x58);
    var _i1 = 0;
    while (_i1 < _n1) {
      var x = _x58[_i1];
      if (c) {
        write(c);
      } else {
        c = str(sep);
      }
      write(str(x));
      _i1 = _i1 + 1;
    }
  } else {
    var _x59 = l;
    var _n2 = _35(_x59);
    var _i2 = 0;
    while (_i2 < _n2) {
      var x = _x59[_i2];
      write(str(x));
      _i2 = _i2 + 1;
    }
  }
  if (l) {
    return(hd(l));
  }
};
setenv("do1", {_stash: true, macro: function (a) {
  var _r17 = unstash(Array.prototype.slice.call(arguments, 1));
  var _id14 = _r17;
  var bs = cut(_id14, 0);
  var g = unique("g");
  return(["let", g, a, join(["do"], bs), g]);
}});
prn = function () {
  var l = unstash(Array.prototype.slice.call(arguments, 0));
  var _g = apply(pr, l);
  pr("\n");
  return(_g);
};
setenv("import", {_stash: true, macro: function (name) {
  return(["def", name, ["require", ["quote", name]]]);
}});
setenv("mcall", {_stash: true, macro: function (o, method) {
  var _r21 = unstash(Array.prototype.slice.call(arguments, 2));
  var _id16 = _r21;
  var args = cut(_id16, 0);
  var g = unique("g");
  return(["let", g, o, join([["get", g, method], g], args)]);
}});
var childproc = require("child_process");
var exec = childproc.execSync;
shell = function (cmd) {
  var o = exec(cmd);
  return(o["toString"]());
};
