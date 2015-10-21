(clone "sctb/lumen")


; compiler.l: Re-enable foo.bar syntax, even though it suffers from
; inconsistent behavior.  (E.g. foo.bar-baz doesn't work.)
(patch "compiler.l"
"""
(define valid-code? (n)
  (or (number-code? n)         ; 0-9
      (and (> n 64) (< n 91))  ; A-Z
      (and (> n 96) (< n 123)) ; a-z
      (= n 95)))               ; _
"""
"""
(define valid-code? (n)
  (or (number-code? n)         ; 0-9
      (and (> n 64) (< n 91))  ; A-Z
      (and (> n 96) (< n 123)) ; a-z
      (= n 46)                 ; .
      (= n 95)))               ; _
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
|)

(patch "reader.l"
|(define delimiters (set-of "(" ")" ";" "\n"))|
|(define delimiters (set-of "(" ")"  "[" "]"  "{" "}" ";" "\n"))|)

(rebuild 3)
(test)

