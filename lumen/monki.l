(clone "sctb/lumen")

; By default, use LuaJIT when compiling Lumen.
(patch "makefile"
|LUMEN_LUA  ?= lua|
|LUMEN_LUA  ?= luajit|)

; compiler.l: Re-enable foo.bar syntax, even though it suffers from
; inconsistent behavior.  (E.g. foo.bar-baz doesn't work.)
(patch "compiler.l"
|
(define valid-code? (n)
  (or (number-code? n)         ; 0-9
      (and (> n 64) (< n 91))  ; A-Z
      (and (> n 96) (< n 123)) ; a-z
      (= n 95)))               ; _
|
|
(define valid-code? (n)
  (or (number-code? n)         ; 0-9
      (and (> n 64) (< n 91))  ; A-Z
      (and (> n 96) (< n 123)) ; a-z
      (= n 46)                 ; .
      (= n 95)))               ; _
|)


; runtime.l: def obj? (x)
(patch "runtime.l"
|
(define-global atom? (x)
|
|
(define-global obj? (x)
  (and (is? x) (= (type x) (target js: 'object lua: 'table))))

(define-global atom? (x)
|)

; runtime.l: string:
;  - detect circular lists
;  - return "fn" for functions rather than "function"
;  - prevent errors for unknown types such as LuaJIT cdata
;
(patch "runtime.l"
"""
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
"""
"""
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
""")

; bin/lumen: Fix LUMEN_HOST to handle spaces.
(patch "bin/lumen"
|
if [ ! -z ${LUMEN_HOST} ]
then
    host=${LUMEN_HOST}
|
|
if [ ! -z "${LUMEN_HOST}" ]
then
    host="${LUMEN_HOST}"
|)

; bin/lumen: Use rlwrap when possible.
(patch "bin/lumen"
|exec ${host} "${home}/${code}" "$@"|
; Using rlwrap turns out to make compilation slower.  A full rebuild
; of Lumen jumped from 0.761s to 0.968s, a ~25% slowdown.  Keep
; rlwrap disabled except for repls.
|
if [ -z "$*" ]; then
  exec rlwrap ${host} "${home}/${code}" "$@"
else
  exec        ${host} "${home}/${code}" "$@"
fi
|)


; bin/lumen: Export LUMEN_HOST so that users can discern LuaJIT vs Lua.
(patch "bin/lumen"
|esac

|
|esac

export LUMEN_HOST="${host}"
|)


;
; bin/lumen: Add lib/${os} to the LUA_PATH and NODE_PATH.
;
(patch "bin/lumen"
"""
case $host in
"""
"""
os=$(uname | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")
case $host in
""")



;
; reader.l: Add """raw string""" syntax.
;

(patch "reader.l"
|
(define peek-char (s)
  (let ((:pos :len :string) s)
    (when (< pos len)
      (char string pos))))

(define read-char (s)
  (let c (peek-char s)
    (if c (do (inc (get s 'pos)) c))))
|
|
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
|)

(patch "reader.l"
|
(define-reader (")" s)
  (error (cat "Unexpected ) at " (get s 'pos))))

(define-reader ("\"" s)
  (read-char s)
|
|
(define-reader (")" s)
  (error (cat "Unexpected ) at " (get s 'pos))))

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
|)

;
; reader.l: Add [ ] syntax to represent a fn of one arg, e.g.
;
; (def adder (n) [+ _ n])
; (set add2 (adder 2))
; (add2 40) ; gives 42
;

(patch "reader.l"
|
(define-reader (")" s)
  (error (cat "Unexpected ) at " (get s 'pos))))
|
|
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
|)

(patch "reader.l"
|(define delimiters (set-of "(" ")" ";" "\n"))|
|(define delimiters (set-of "(" ")"  "[" "]"  "{" "}" ";" "\n"))|)

(rebuild 3)
(test)

