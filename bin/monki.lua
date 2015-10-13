function comp(expr)
  return(print(compile(macroexpand(expr))))
end
reader = require("reader")
function read_str(s)
  return(join({"do"}, reader["read-all"](reader.stream(s))))
end
function reload(file)
  local code = read_str(read_file(file))
  comp(code)
  eval(code)
  return(print("Reloaded " .. file))
end
