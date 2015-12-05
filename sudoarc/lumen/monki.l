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


; compiler.l: On LUMEN_HOST=node, "0?" is incorrectly read as 0.  We
; fix the bug here.

(patch "reader.l"
||
(define-reader ("" s) ; atom
||
||
(define digit? (s i)
  (let c (code s i)
    (and (>= c 48) (<= c 57))))

(define-reader ("" s) ; atom
||)

(patch "reader.l"
||
        (= str "-inf") -inf
||
||
        (= str "-inf") -inf
        (not (digit? str (edge str))) str
||)


; (patch "compiler.l"
; ||
; (export run
; ||
; ||
; (define-global load-compile-file (file lang rest: preload)
;   (if (nil? lang) (set lang target))
;   (let (compiler (require 'compiler)
;         run (get compiler 'run)
;         expand (get compiler 'expand)
;         system (require 'system)
;         read-file (get system 'read-file)
;         reader (require 'reader)
;         stream (get reader 'stream)
;         read-all (get reader 'read-all)
;         reads (fn (s) (read-all (stream s)))
;         prev-target target
;         prev-print print)
;     (set target lang)
;     (when (is? preload)
;       (step x preload
;         (run (read-file x))))
;     (step expr (reads (read-file file))
;       (set print (fn l nil))
;       (let ((ok x) (guard (eval expr)))
;         (set print prev-print)
;         (unless ok
;           (print x)
;           (return))
;         (print (compile (expand `(do ,expr))))))
;     (set target prev-target)
;     nil))

; (export run
; ||)


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
(define-global string (x depth)
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
            (set (get xs k) (string v d))
          (do (add ks (cat k ":"))
              (add ks (string v d)))))
      (each v (join xs ks)
        (cat! s sp v)
        (set sp " "))
      (cat s  ")"))))
||
||
(define-global string (x depth ancestors)
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
            (set (get xs k) (string v d ans))
          (do (add ks (cat k ":"))
              (add ks (string v d ans)))))
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
; https://github.com/sctb/lumen/pull/32
; Add stack traces to error messages.
;

(patch "compiler.l"
"""
          hf `(return (%array false (get ,e "message")))
"""
"""
          hf `(return (%array false (get ,e "message") (get ,e "stack")))
""")

(patch "macros.l"
"""
    (let-unique (e x msg)
      `(let (,x nil
             ,msg nil
             ,e (xpcall
                 (fn () (set ,x ,expr))
                 (fn (m) (set ,msg (%message-handler m)))))
         (list ,e (if ,e ,x ,msg))))))
"""
"""
    (let-unique (e x msg trace)
      `(let (,x nil
             ,msg nil
             ,trace nil
             ,e (xpcall
                 (fn () (set ,x ,expr))
                 (fn (m)
                   (set ,trace ((get debug 'traceback)))
                   (set ,msg (%message-handler m ,trace)))))
         (list ,e (if ,e ,x ,msg)
                  (if ,e nil ,trace))))))
""")

(patch "main.l"
"""
  (let ((ok x) (guard ((get compiler 'eval) form)))
    (if (not ok) (print (cat "error: " x))
"""
"""
  (let ((ok x trace) (guard ((get compiler 'eval) form)))
    (if (not ok) (print (target js: trace
                                lua: (cat "error: " x "\n" trace)))
""")

(patch "test.l"
"""
    (test= (list false "Expected ) at 5") (guard (read "(open")))))
"""
"""
    (test= (list false "Expected ) at 5") (cut (guard (read "(open")) 0 2))))
""")

(patch "test.l"
"""
(define-test guard
  (test= '(true 42) (guard 42))
  (test= '(false foo) (guard (error "foo")))
  (test= '(false foo) (guard (do (error "foo") (error "baz"))))
  (test= '(false baz) (guard (do (guard (error "foo")) (error "baz"))))
  (test= '(true 42) (guard (if true 42 (error "baz"))))
  (test= '(false baz) (guard (if false 42 (error "baz")))))
"""
"""
(define-test guard
  (let-macro ((guard2 (x) `(cut (guard ,x) 0 2)))
    (test= '(true 42) (guard2 42))
    (test= '(false foo) (guard2 (error "foo")))
    (test= '(false foo) (guard2 (do (error "foo") (error "baz"))))
    (test= '(false baz) (guard2 (do (guard2 (error "foo")) (error "baz"))))
    (test= '(true 42) (guard2 (if true 42 (error "baz")))
    (test= '(false baz) (guard2 (if false 42 (error "baz")))))))
""")


;
; Calling (repl) from a REPL no longer results in a double REPL
; on LUMEN_HOST=node, though this isn't a proper fix.
;
(patch "main.l"
"""
          ((get in 'setEncoding) 'utf8)
"""
"""
          ((get in 'removeAllListeners))
          ((get in 'setEncoding) 'utf8)
""")

; Apply all of these changes by rebuilding Lumen several times.  The
; first rebuild will be using the old Lumen compiler. The second will
; be running with any changes we made to the compiler. The third
; should produce identical output.  Finally, run all test suites.
; (See test.l)

(rebuild 3) ; `make -B; make -B; make -B`
(test)      ; `make test`

