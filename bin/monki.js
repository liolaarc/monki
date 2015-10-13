comp = function (expr) {
  return(print(compile(macroexpand(expr))));
};
reader = require("reader");
read_str = function (s) {
  return(join(["do"], reader["read-all"](reader.stream(s))));
};
reload = function (file) {
  var code = read_str(read_file(file));
  comp(code);
  eval(code);
  return(print("Reloaded " + file));
};
