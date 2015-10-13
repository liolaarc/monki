setenv("mac", {_stash = true, macro = function (...)
  local l = unstash({...})
  return(join({"define-macro"}, l))
end})
setenv("letmac", {_stash = true, macro = function (name, args, body, ...)
  local _r1 = unstash({...})
  local _id1 = _r1
  local l = cut(_id1, 0)
  return(join({"let-macro", {{name, args, body}}}, l))
end})
setenv("def", {_stash = true, macro = function (...)
  local l = unstash({...})
  return(join({"define-global"}, l))
end})
idfn = function (x)
  return(x)
end
setenv("w/uniq", {_stash = true, macro = function (x, ...)
  local _r4 = unstash({...})
  local _id3 = _r4
  local body = cut(_id3, 0)
  if atom63(x) then
    return(join({"let-unique", {x}}, body))
  else
    return(join({"let-unique", x}, body))
  end
end})
setenv("void", {_stash = true, macro = function (...)
  local l = unstash({...})
  return(join({"do"}, l, {"nil"}))
end})
setenv("lfn", {_stash = true, macro = function (name, args, body, ...)
  local _r6 = unstash({...})
  local _id5 = _r6
  local l = cut(_id5, 0)
  return(join({"let", name, "nil", {"set", name, {"fn", args, body}}}, l))
end})
setenv("accum", {_stash = true, macro = function (name, ...)
  local _r8 = unstash({...})
  local _id7 = _r8
  local body = cut(_id7, 0)
  local g = unique("g")
  return({"let", g, join(), join({"lfn", name, {"item"}, {"add", g, "item"}}, body), g})
end})
setenv("acc", {_stash = true, macro = function (...)
  local l = unstash({...})
  return(join({"accum", "a"}, l))
end})
local __o = {"let", "each", "step", "for", "when", "while"}
local _i = nil
for _i in next, __o do
  local form = __o[_i]
  eval({"mac", "acc:" .. form, "l", {"quasiquote", {"acc", {{"unquote", {"quote", form}}, {"unquote-splicing", "l"}}}}})
end
setenv("nor", {_stash = true, macro = function (...)
  local l = unstash({...})
  return({"not", join({"or"}, l)})
end})
function lst63(x)
  return(not( atom63(x) or function63(x)))
end
function any63(x)
  return(lst63(x) and some63(x))
end
setenv("iflet", {_stash = true, macro = function (name, ...)
  local _r12 = unstash({...})
  local _id10 = _r12
  local l = cut(_id10, 0)
  if some63(l) then
    local _id11 = l
    local x = _id11[1]
    local a = _id11[2]
    local bs = cut(_id11, 2)
    local _e2
    if one63(l) then
      _e2 = name
    else
      _e2 = {"if", name, a, join({"iflet", name}, bs)}
    end
    return({"let", name, x, _e2})
  end
end})
setenv("aif", {_stash = true, macro = function (...)
  local l = unstash({...})
  return(join({"iflet", "it"}, l))
end})
setenv("awhen", {_stash = true, macro = function (...)
  local l = unstash({...})
  return(join({"let-when", "it"}, l))
end})
function intersperse(x, lst)
  local sep = nil
  local _e3
  if sep then
    _e3 = a(sep)
  else
    sep = x
    _e3 = sep
  end
  return(acc58each(item, lst, _e3, a(item)))
end
function str(x)
  if string63(x) then
    return(x)
  else
    return(string(x))
  end
end
function pr(...)
  local _r15 = unstash({...})
  local _id12 = _r15
  local sep = _id12.sep
  local l = cut(_id12, 0)
  local c = nil
  if sep then
    local _x71 = l
    local _n1 = _35(_x71)
    local _i1 = 0
    while _i1 < _n1 do
      local x = _x71[_i1 + 1]
      if c then
        write(c)
      else
        c = str(sep)
      end
      write(str(x))
      _i1 = _i1 + 1
    end
  else
    local _x72 = l
    local _n2 = _35(_x72)
    local _i2 = 0
    while _i2 < _n2 do
      local x = _x72[_i2 + 1]
      write(str(x))
      _i2 = _i2 + 1
    end
  end
  if l then
    return(hd(l))
  end
end
setenv("do1", {_stash = true, macro = function (a, ...)
  local _r17 = unstash({...})
  local _id14 = _r17
  local bs = cut(_id14, 0)
  local g = unique("g")
  return({"let", g, a, join({"do"}, bs), g})
end})
function prn(...)
  local l = unstash({...})
  local _g = apply(pr, l)
  pr("\n")
  return(_g)
end
setenv("import", {_stash = true, macro = function (name)
  return({"def", name, {"require", {"quote", name}}})
end})
setenv("mcall", {_stash = true, macro = function (o, method, ...)
  local _r21 = unstash({...})
  local _id16 = _r21
  local args = cut(_id16, 0)
  local g = unique("g")
  return({"let", g, o, join({{"get", g, method}, g}, args)})
end})
ffi = require("ffi")
setenv("defc", {_stash = true, macro = function (name, val)
  local _e4
  if id_literal63(val) then
    _e4 = inner(val)
  else
    _e4 = val
  end
  return({"do", {{"get", "ffi", {"quote", "cdef"}}, {"quote", _e4}}, {"def", name, {"get", {"get", "ffi", {"quote", "C"}}, {"quote", name}}}})
end})
ffi.cdef("int usleep (unsigned int usecs)")
usleep = ffi.C.usleep
function sleep(secs)
  return(usleep(secs * 1000000))
end
local popen = io.popen
function shell(cmd)
  local h = popen(cmd)
  local _g2 = h
  local _g1 = _g2.read(_g2, "*a")
  local _g3 = h
  _g3.close(_g3)
  return(_g1)
end
