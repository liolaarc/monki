(clone "laarc/lumen" "0008-reader-fix")

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

(rebuild 3)
(test)

