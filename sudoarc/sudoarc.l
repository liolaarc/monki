
;; Definition funcs

(define-macro alias (newname oldname)
  `(define-macro ,newname l `(,',oldname ,@l)))

(alias var define)
(alias def define-global)
(alias sym define-symbol)
(alias mac define-macro)
(alias special define-special)

; if a variable is nil, set it to a default value.
(mac o l
  (with e '(do)
    (let lastvar 'nil
      (step (var val) (pair l)
        (add e `(if (nil? ,var) (set ,var ,val)))
        (set lastvar var))
      (add e lastvar))))

;; Module funcs

(mac lib (name) `(def ,name (require ',name)))
(mac use (name) `(var ,name (require ',name)))

; {reader stream} becomes (get reader 'stream)
(mac curly (module func)
  `(get ,module ',func))

;; Multi-Definition funcs

(mac multi (name val argc) (o argc 2)
  (if (atom? val)
    `(mac ,name l
      (with e '(do)
        (step (x . ys) (tuple l ,argc)
          (add e `(,',val ,x ,@ys)))))
    `(mac ,name l
      (prn (with e '(do)
        (step it (tuple l ,argc)
          (let ((x . ys) it)
            (add e ,val))))))))

(multi vars var 2)
(multi defs def 2)
(multi syms sym 2)
(multi macs mac 3)
(multi specials special 3)
(multi libs lib 1)
(multi uses use 1)

;; Modules

(uses
  compiler
  reader
  system)

(vars
  stream {reader stream}
  read-all {reader read-all}
  write {system write}
  read-file {system read-file}
  write-file {system write-file})

;; Basics
(def len  #)
(def idfn [do _])
(def fn?  function?)
(def atom atom?)
(def env  {system get-environment-variable})

(mac w/uniq (x . body)
  (if (atom? x)
    `(let-unique (,x) ,@body)
    `(let-unique (,@x) ,@body)))

(mac void l
  `(do ,@l nil))

(mac lfn (name args body . l)
  `(let ,name nil
     (set ,name (fn ,args ,body))
     ,@(if (some? l) l
         (list name))))

(mac afn (args body . l)
  `(lfn self ,args ,body ,@l))

(mac accum (name . body)
  (w/uniq g
    `(let ,g ()
       (lfn ,name (item) (add ,g item)
         ,@body)
       ,g)))

(mac acc l `(accum a ,@l))

; ; This serves as an example of how to write a metamacro.  There are
; ; probably better ways to write it, and the idea isn't very good in
; ; this case.  But it's a general technique worth knowing.

; (each form (list "let" "each" "step" "for" "when" "while")
;   (eval `(mac ,(cat "acc:" form) l
;            `(acc (,',form ,@l)))))

; ; (eval (acc:let x 42 (a '+) (a x) (a 2))) ; gives 44
; ; (map print (acc:for i 10 (unless (= i 2) (a (cat "Current line is " i)))))
; ; (sort (acc:each (k v) (hd environment) (a k)))

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
;       (let ((x a . bs) l)
;         `(if ,x ,a (iffy ,@bs)))))

(mac iflet (name . l)
  (when (some? l)
    (let ((x a . bs) l)
      `(let ,name ,x
        ,(if (one? l) name
          `(if ,name ,a (iflet ,name ,@bs)))))))

(mac whenlet (name . l)
  (when (some? l)
    (let ((x . ys) l)
      `(let ,name ,x
         ,(if (one? l) name
            `(do ,@ys))))))

(mac aif l
  `(iflet it ,@l))

(mac awhen l
  `(let-when it ,@l))

(mac repeat (n . l)
  (w/uniq g
    `(for ,g ,n
      ,@l)))

(def acons (x)
  (not (atom x)))

(def car (x)
  (if (and (acons x) (some? x))
      (hd x)))
 
(def cdr (x)
  (if (and (acons x) (some? x))
      (tl x)))        

(def caar (x) (car (car x)))
(def cadr (x) (car (cdr x)))
(def cddr (x) (cdr (cdr x)))

(def cons (x y)
  (join (list x) y))

(def copylist (xs)
  (let l ()
    (each (k v) xs
      (set (get l k) v))
    l))

(def listify (x)
  (if (atom? x) (list x)
    x))

(def intersperse (x lst)
  (let sep nil
    (acc (each item lst
      (if sep (a sep)
        (set sep x))
      (a item)))))

(mac complement (f)
  (w/uniq g
    `(fn ,g (not (apply ,f ,g)))))

(def testify (x)
  (if (function? x) x
    [= _ x]))

(def keep (f xs)
  (set f (testify f))
  (acc (step x xs
    (when (f x)
      (a x)))))

(def rem (f xs)
  (keep (complement (testify f)) xs))

(def rev reverse)

; Useful benchmark?

; (let lines (split (read-file "test.l") "\n")
;   (apply cat 
;     (intersperse "\n"
;       (intersperse "foo" lines))))
  
(def str (x)
  (if (string? x) x
    (string x)))

(def wschars (list " " "\t" "\n" "\r"))

(def ws? (s)
  (for i (len s)
    (let c (char s i)
      (when (in? c wschars)
        (return true)))))

(def rtrim (s :f)
  (while (and (some? s) ((or f ws?) (char s (edge s))))
    (set s (clip s 0 (edge s))))
  s)

(def ltrim (s :f)
  (while (and (some? s) ((or f ws?) (char s 0)))
    (set s (clip s 1 (len s))))
  s)

(def trim (s :f)
  (rtrim (ltrim s f: f) f: f))

(def endswith (s ending)
  (let i (- (len s) (len ending))
    (= i (search s ending i))))

(def startswith (s prefix)
  (= (search s prefix) 0))

(def pr (:sep . l)
  (let c nil
    (if sep
      (step x l
        (if c (write c)
          (set c (str sep)))
        (write (str x)))
      (step x l
        (write (str x)))))
  (when l (hd l)))

(mac do1 (a . bs)
  (w/uniq g
    `(let ,g ,a
       (do ,@bs)
       ,g)))

(def prn l
  (do1 (apply pr l)
       (pr "\n")))

(def p l
  (void (apply prn l)))

(def filechars (path)
  (read-file path))

(def readfile (path)
  (readstr (filechars path)))

(def doshell args
  (rtrim (shell (apply cat (intersperse " " args)))))

(def mvfile (src dst)
  (doshell "mv" (escape src) (escape dst))
  dst) ; todo: nil for failure, non-nil for success.

(def getmod (file)
  (doshell "stat -r" (escape file) "| awk '{ print $3; }'"))

(def chmod (spec file)
  (doshell "chmod" (escape spec) (escape file)))

(def chmodx (file)
  (chmod "+x" file))

(def writefile (path contents)
  (doshell "cp -fp" (escape path) (escape (cat path ".tmp")))
  (write-file (cat path ".tmp") contents)
  (mvfile (cat path ".tmp") path)
  contents)

(mac w/file (v path . l)
  (w/uniq gp
    `(let (,gp ,path
           ,v (filechars ,gp))
       (set ,v (do ,@l))
       (writefile ,gp ,v))))

(def args [readstr (env 'cmdline)])
(def host [or (env "LUMEN_HOST") ""])
(def host? [search (host) _])
(def luajit? [host? 'luajit])

; Useful shorthand for seeing what a Lumen expression compiles to.  It
; can be used anywhere eval is used, and it shows you what code eval
; would have run.  E.g. try:
;
;   (let exprs '(let (adder (fn (x) (fn (n) (+ x n))) add2 (adder 2)) (add2 42))
;     (comp exprs)
;     (eval exprs))
;
(def comp [print (compile (macex _))])
(def macex {compiler expand})
(def readstr [read-all (stream _)])

(def prnerr ((expr msg))
  (prn "Error in " file ": ")
  (prn "   " msg)
  (prn "The error occurred while evaluating: ")
  (prn expr)
  msg)

(def loadstr (str :verbose :on-err :print)
  (step expr (readstr str)
    (when (= "1" (env "VERBOSE")) (prn (string expr)))
    (when (= "1" (env "COMP")) (prn (comp expr)))
    (let ((ok x) (guard (eval expr)))
      (when (and ok (= print true))
        (prn x)) 
      (unless ok
        ((or on-err prnerr) (list expr x))))))

(def load (file :verbose :on-err)
  (when verbose
    (prn "Loading " file))
  (loadstr (read-file file)
    verbose: verbose
    on-err: on-err))

;
; These run only on LuaJIT.
;

(target lua:
  (when (luajit?)

    (lib ffi)

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
      (do (usleep (* secs 1000000))
          nil))))

;
; These run on all hosts.
;

; (shell cmd) to execute a shell command.
; E.g.
;   (shell "echo hi") => "hi\n"
(def shell (cmd)
  (target js: (do
    (var childproc (require 'child_process))
    (var exec {childproc execSync})
         ; http://stackoverflow.com/questions/20643470/execute-a-command-line-binary-with-node-js
         ; https://nodejs.org/api/child_process.html#child_process_child_process_execsync_command_options
         ;
         ; Returns the stdout of the command.  Throws if the process
         ; times out or has a non-zero exit code.
         (let o (exec cmd)
           ; ({o toString}) ; TODO: Research why this breaks.
           ({o toString}))))
  (target lua: (do
    (var exec (s)
      ; http://stackoverflow.com/questions/9676113/lua-os-execute-return-value
      ; Watch out, popen() sometimes fails to block:
      ; http://lua-users.org/lists/lua-l/2013-10/msg00727.html
      (let h ({io popen} cmd)
        (do1 ({h read} h "*a")
             ({h close} h))))
    (exec cmd))))

; (exit)
(def exit (code)
  (target js: ({process exit} code)
          lua: ({os exit} code)))


