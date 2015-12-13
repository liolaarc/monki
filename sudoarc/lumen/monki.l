(clone "sctb/lumen")


; By default, use LuaJIT when compiling Lumen.
(patch "makefile"
||LUMEN_LUA  ?= lua||
||LUMEN_LUA  ?= luajit||)


; compiler.l: Re-enable foo.bar syntax, even though it suffers from
; inconsistent behavior.  (E.g. foo.bar-baz doesn't work.)
(patch "compiler.l"
||
(define valid-code? (n)
  (or (number-code? n)         ; 0-9
      (and (> n 64) (< n 91))  ; A-Z
      (and (> n 96) (< n 123)) ; a-z
      (= n 95)))               ; _
||
||
(define valid-code? (n)
  (or (number-code? n)         ; 0-9
      (and (> n 64) (< n 91))  ; A-Z
      (and (> n 96) (< n 123)) ; a-z
      (= n 46)                 ; .
      (= n 95)))               ; _
||)


; runtime.l:
;   def tuple (lst n)
;   def vals (lst)
(patch "runtime.l"
||
(define-global pair (l)
  (with l1 ()
    (for i (# l)
      (add l1 (list (at l i) (at l (+ i 1))))
      (inc i))))
||
||
(define-global pair (l)
  (with l1 ()
    (for i (# l)
      (add l1 (list (at l i) (at l (+ i 1))))
      (inc i))))

(define-global tuple (lst n)
  (if (nil? n) (set n 2))
  (with l1 ()
    (for i (# lst)
      (let l2 ()
        (for j n
          (add l2 (at lst (+ i j))))
        (add l1 l2))
      (inc i (- n 1)))))

(define-global vals (lst)
  (with r ()
    (step x lst
      (add r x))))
||)


; runtime.l: modify atom? to return true for functions.
(patch "runtime.l"
||
(define-global atom? (x)
  (or (nil? x) (string? x) (number? x) (boolean? x)))
||
||
(define-global atom? (x)
  (or (nil? x) (string? x) (number? x) (boolean? x) (function? x)))
||)
(patch "test.l"
||(test= false (atom? (fn ())))||
||(test= true (atom? (fn ())))||)


; runtime.l: def obj? (x)
(patch "runtime.l"
||
(define-global atom? (x)
||
||
(define-global obj? (x)
  (and (is? x) (= (type x) (target js: 'object lua: 'table))))

(define-global atom? (x)
||)


; runtime.l: string:
;  - detect circular lists
;  - return "fn" for functions rather than "function"
;  - prevent errors for unknown types such as LuaJIT cdata
;
(patch "runtime.l"
||
(define-global str (x depth)
  (if (and depth (> depth 40)) "circular"
      (nil? x) "nil"
      (nan? x) "nan"
      (= x inf) "inf"
      (= x -inf) "-inf"
      (boolean? x) (if x "true" "false")
      (string? x) (escape x)
      (atom? x) (tostring x)
      (function? x) "function"
    (let (s "(" sp ""
          xs () ks ()
          d (+ (or depth 0) 1))
      (each (k v) x
        (if (number? k)
            (set (get xs k) (str v d))
          (do (add ks (cat k ":"))
              (add ks (str v d)))))
      (each v (join xs ks)
        (cat! s sp v)
        (set sp " "))
      (cat s  ")"))))
||
||
(define-global str (x depth ancestors)
  (if (nil? x) "nil"
      (nan? x) "nan"
      (= x inf) "inf"
      (= x -inf) "-inf"
      (boolean? x) (if x "true" "false")
      (string? x) (escape x)
      (atom? x) (tostring x)
      (function? x) "fn"
      (not (obj? x)) (cat "|" (type x) "|")
    (let (s "(" sp ""
          xs () ks ()
          d (+ (or depth 0) 1)
          ans (join (list x) (or ancestors ())))
      (when (in? x (or ancestors ()))
        (return "circular"))
      (each (k v) x
        (if (number? k)
            (set (get xs k) (str v d ans))
          (do (add ks (cat k ":"))
              (add ks (str v d ans)))))
      (each v (join xs ks)
        (cat! s sp v)
        (set sp " "))
      (cat s  ")"))))
||)


; bin/lumen: Use rlwrap when possible.
(patch "bin/lumen"
||exec ${host} "${home}/${code}" "$@"||
; Using rlwrap turns out to make compilation slower.  A full rebuild
; of Lumen jumped from 0.761s to 0.968s, a ~25% slowdown.  Keep
; rlwrap disabled except for repls.
||
if [ -z "$*" ]; then
  exec rlwrap ${host} "${home}/${code}" "$@"
else
  exec        ${host} "${home}/${code}" "$@"
fi
||)


; bin/lumen: Export LUMEN_HOST so that users can discern LuaJIT vs Lua.
(patch "bin/lumen"
||esac

||
||esac

export LUMEN_HOST="${host}"
||)


;
; bin/lumen: Add lib/${os} to the LUA_PATH and NODE_PATH.
;
(patch "bin/lumen"
||
case $host in
||
||
os=$(uname | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")
case $host in
||)


; reader.l: turn "." atoms into "rest:" atoms.
; This enables (fn (x . ys) ...) rather than (fn (x rest: ys) ...)
(patch "reader.l"
||
        (= str "-inf") -inf
||
||
        (= str "-inf") -inf
        (= str ".")    "rest:"
||)


; reader.l: Add """raw string""" syntax.

(patch "reader.l"
||
(define peek-char (s)
  (let ((:pos :len :string) s)
    (when (< pos len)
      (char string pos))))

(define read-char (s)
  (let c (peek-char s)
    (if c (do (inc (get s 'pos)) c))))
||
||
(define peek-char (s count offset)
  (let ((:pos :len :string) s
        from (+ pos (or offset 0))
        n (or count 1))
    (when (<= from (- len n))
      (if (= n 1)
        (char string from)
        (clip string from (+ from n))))))

(define read-char (s count offset)
  (let c (peek-char s count offset)
    (if c (do (inc (get s 'pos) (# c)) c))))
||)

(patch "reader.l"
||
(define-reader ("\"" s)
  (read-char s)
||
||
(define-reader ("\"\"\"" s)
  (read-char s 3)
  (with r nil
    (let str "\""
      (while (nil? r)
        (let c (peek-char s 3)
          (if (= c "\"\"\"") (set r (cat str (do (read-char s 3) "\"")))
              (nil? c) (set r (expected s "\"\"\""))
            (let x (read-char s)
              (cat! str (if (or (= x "\"") (= x "\\")) (cat "\\" x) x)))))))))

(define-reader ("\"" s)
  (when (= (peek-char s 3) "\"\"\"")
    (return ((get read-table "\"\"\"") s)))
  (read-char s)
||)


; reader.l: Add ||raw string|| syntax.

(patch "reader.l"
"""
(define-reader ("|" s)
  (read-char s)
"""
"""
(define-reader ("||" s)
  (read-char s 2)
  (with r nil
    (let str "\""
      (while (nil? r)
        (let c (peek-char s 2)
          (if (= c "||") (set r (cat str (do (read-char s 2) "\"")))
              (nil? c) (set r (expected s "||"))
            (let x (read-char s)
              (cat! str (if (or (= x "\"") (= x "\\")) (cat "\\" x) x)))))))))

(define-reader ("|" s)
  (when (= (peek-char s 2) "||")
    (return ((get read-table "||") s)))
  (read-char s)
""")


;
; reader.l: Add [ ] syntax to represent a fn of one arg, e.g.
;
; (def adder (n) [+ _ n])
; (set add2 (adder 2))
; (add2 40) ; gives 42
;

(patch "reader.l"
||
(define-reader (")" s)
  (error (cat "Unexpected ) at " (get s 'pos))))
||
||
(define-reader (")" s)
  (error (cat "Unexpected ) at " (get s 'pos))))

(define-reader ("[" s)
  (read-char s)
  (with r nil
    (let l ()
      (while (nil? r)
        (skip-non-code s)
        (let c (peek-char s)
          (if (= c "]") (do (read-char s) (set r `(fn (_) ,l)))
              (nil? c) (set r (expected s "]"))
            (let x (read s)
              (add l x))))))))
(define-reader ("]" s)
  (error (cat "Unexpected ] at " (get s 'pos))))

(define-reader ("{" s)
  (read-char s)
  (with r nil
    (let l ()
      (while (nil? r)
        (skip-non-code s)
        (let c (peek-char s)
          (if (= c "}") (do (read-char s) (set r `(curly ,@l)))
              (nil? c) (set r (expected s "}"))
            (let x (read s)
              (add l x))))))))
(define-reader ("}" s)
  (error (cat "Unexpected } at " (get s 'pos))))
||)

(patch "reader.l"
||(define delimiters (set-of "(" ")" ";" "\n"))||
||(define delimiters (set-of "(" ")"  "[" "]"  "{" "}" ";" "\n"))||)


;
; Expose some useful fns globally.
;

(make-global "main.l"
  "repl"
  "eval-print")


;
; Calling (repl) from a REPL no longer results in a double REPL
; on LUMEN_HOST=node, though this isn't a proper fix.
;
(patch "main.l"
||
          ((get in 'setEncoding) 'utf8)
||
||
          ((get in 'removeAllListeners))
          ((get in 'setEncoding) 'utf8)
||)



;
; Add support for LUMEN_HOST=luvit
;

(patch "main.l"
||(is? x) (print (str x))||
||(is? x) (pretty-print x)||)


(patch "main.l"
||
(define system (require 'system))
||
||
(define system (require 'system))

(define-global pretty-print (x)
  (print (str x)))

(target lua:
  (let ((ok req) (guard (require 'require)))
    (when ok
      (set require (req "."))
      (define-global pretty-print (get (require 'pretty-print) 'prettyPrint))
      ; On some platforms, luvit sets stdin to nonblocking.  This hack
      ; forces stdin to be in blocking mode.   (TODO: Remove this hack.)
      ((get compiler 'run) """
ffi = require('ffi')
ffi.cdef[[int fcntl(int fildes, int cmd, ...);]]
ffi.cdef[[static const int F_GETFL= 3;/* get file status flags */]]
ffi.cdef[[static const int F_SETFL= 4;/* set file status flags */]]
ffi.cdef[[static const int O_NONBLOCK	= 0x0004;		/* no delay */]]
local flags = ffi.C.fcntl(0, ffi.C.F_GETFL, 0)
bit = require("bit")
flags = bit.bxor(flags, ffi.C.O_NONBLOCK)
ffi.C.fcntl(0, ffi.C.F_SETFL, flags)
"""))))
||)


(patch "system.l"
||
(define argv
  (target js: (cut (get process 'argv) 2) lua: arg))
||
||
(define argv
  (target js: (cut (get process 'argv) 2) lua: (or arg (cut args 1))))
||)



; Apply all of these changes by rebuilding Lumen several times.  The
; first rebuild will be using the old Lumen compiler. The second will
; be running with any changes we made to the compiler. The third
; should produce identical output.  Finally, run all test suites.
; (See test.l)

(rebuild 3) ; `make -B; make -B; make -B`
(test)      ; `make test`

