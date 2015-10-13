
; Useful shorthand for seeing what a Lumen expression compiles to.  It
; can be used anywhere eval is used, and it shows you what code eval
; would have run.  E.g. try:
;
;   (let code '(let (adder (fn (x) (fn (n) (+ x n))) add2 (adder 2)) (add2 42))
;     (comp code)
;     (eval code))
;

(define-global comp (expr)
  (print (compile (macroexpand expr))))

(set reader (require 'reader))

(define-global read-str (s)
    `(do ,@((get reader 'read-all)
            ((get reader 'stream) s))))

(define-global reload (file)
  (let code (read-str (read-file file))
    (comp code)
    (eval code)
    (print (cat "Reloaded " file))))

