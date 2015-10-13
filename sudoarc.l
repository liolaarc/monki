
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


;
; Let's see how far we can push Lumen in the direction of Arc.
;

(define-macro mac l
  `(define-macro ,@l))

(mac letmac (name args body rest: l)
  `(let-macro ((,name ,args ,body))
     ,@l))

(mac def l
  `(define-global ,@l))

(def idfn (fn (x) x))

(mac w/uniq (x rest: body)
  (if (atom? x)
    `(let-unique (,x) ,@body)
    `(let-unique (,@x) ,@body)))

(mac void l
  `(do ,@l nil))

(mac lfn (name args body rest: l)
  `(let ,name nil
     (set ,name (fn ,args ,body))
     ,@l))

(mac accum (name rest: body)
  (w/uniq g
    `(let ,g ()
       (lfn ,name (item) (add ,g item)
         ,@body)
       ,g)))

(mac acc l `(accum a ,@l))

; This serves as an example of how to write a metamacro.  There are
; probably better ways to write it, and the idea isn't very good in
; this case.  But it's a general technique worth knowing.

(each form (list "let" "each" "step" "for" "when" "while")
  (eval `(mac ,(cat "acc:" form) l
           `(acc (,',form ,@l)))))

; (eval (acc:let x 42 (a '+) (a x) (a 2))) ; gives 44
; (map print (acc:for i 10 (unless (= i 2) (a (cat "Current line is " i)))))
; (sort (acc:each (k v) (hd environment) (a k)))

(mac nor l
  `(not (or ,@l)))

(def lst? (x)
  (nor (atom? x) (function? x)))

(def any? (x)
  (and (lst? x) (some? x)))

; Just an experiment.

; (mac iffy l
;   (if (none? l) nil
;       (one? l) (hd l)
;       (let ((x a rest: bs) l)
;         `(if ,x ,a (iffy ,@bs)))))

(mac iflet (name rest: l)
  (when (some? l)
    (let ((x a rest: bs) l)
      `(let ,name ,x
        ,(if (one? l) name
          `(if ,name ,a (iflet ,name ,@bs)))))))

(mac aif l
  `(iflet it ,@l))

(mac awhen l
  `(let-when it ,@l))
         
(def intersperse (x lst)
  (let sep nil
    (acc:each item lst
      (if sep (a sep)
        (set sep x))
      (a item))))

; Useful benchmark?

; (let lines (split (read-file "test.l") "\n")
;   (apply cat 
;     (intersperse "\n"
;       (intersperse "foo" lines))))
  
(def str (x)
  (if (string? x) x
    (string x)))

(def pr (:sep rest: l)
  (let c nil
    (if sep
      (step x l
        (if c (write c)
          (set c (str sep)))
        (write (str x)))
      (step x l
        (write (str x)))))
  (when l (hd l)))

(mac do1 (a rest: bs)
  (w/uniq g
    `(let ,g ,a
       (do ,@bs)
       ,g)))

(def prn l
  (do1 (apply pr l)
       (pr "\n")))

;
; Imports.
;

(mac import (name)
  `(def ,name (require ',name)))

; method call.
(mac mcall (o method rest: args)
  (w/uniq g
    `(let ,g ,o
      ((get ,g ,method) ,g ,@args))))

;
; Externals (LuaJIT only)
;

(target lua: (do

  (import ffi)

  (mac defc (name val)
    `(do ((get ffi 'cdef) ',(if (id-literal? val) (inner val) val))
         (def ,name (get (get ffi 'C) ',name))))

  ; (sleep secs) to sleep for a number of seconds. 
  ; E.g.
  ;   (print 'begin)
  ;   (sleep 1.3)
  ;   (print 'end)
  (defc usleep |int usleep (unsigned int usecs)|)
  (def sleep (secs)
    (usleep (* secs 1000000))))
)

;
; Externals (All hosts)
;

; (shell cmd) to execute a shell command.
; E.g.
;   (shell "echo hi") => "hi\n"
(target js: (do
  (define childproc (require 'child_process))
  (define exec (get childproc 'execSync))
  (def shell (cmd)
       ; http://stackoverflow.com/questions/20643470/execute-a-command-line-binary-with-node-js
       ; https://nodejs.org/api/child_process.html#child_process_child_process_execsync_command_options
       ;
       ; Returns the stdout of the command.  Throws if the process
       ; times out or has a non-zero exit code.
       (let o (exec cmd)
         ; ((get o 'toString)) ; TODO: Research why this breaks.
         ((get o "toString"))))))
(target lua: (do
  (define popen (get io 'popen))
  (def shell (cmd)
       ; http://stackoverflow.com/questions/9676113/lua-os-execute-return-value
       (let h (popen cmd)
         (do1 (mcall h 'read "*a")
              (mcall h 'close))))))




