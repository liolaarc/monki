
(define-macro void l
  `(do ,@l nil))

;; Definition funcs

(define-macro alias (newname oldname)
  `(define-macro ,newname l `(,',oldname ,@l)))

(alias var define)
(alias def define-global)
(alias sym define-symbol)
(alias mac define-macro)
(alias special define-special)

; {foo bar} becomes (get foo 'bar)
(mac curly (module func)
  `(get ,module ',func))

;; Multi-Definition funcs

(mac multi (name val argc)
  (if (nil? argc) (set argc 2))
  (if (atom? val)
    `(mac ,name l
      (with e '(do)
        (step (x . ys) (tuple l ,argc)
          (add e `(,',val ,x ,@ys)))))
    `(mac ,name l
      (with e '(do)
        (step it (tuple l ,argc)
          (let ((x . ys) it)
            (add e ,val)))))))

(multi vars var 2)
(multi defs def 2)
(multi syms sym 2)
(multi macs mac 3)
(multi specials special 3)

;; Module funcs

(mac lib (name) `(def ,name (require ',name)))
(mac use (name) `(var ,name (require ',name)))

(multi libs lib 1)
(multi uses use 1)

;; Modules

(uses
  compiler
  reader
  system)

(vars
  stream     {reader stream}
  read-all   {reader read-all}
  read-file  {system read-file}
  write-file {system write-file})

(defs
  env    {system get-environment-variable}
  macex  {compiler expand}
  comp   [print (compile (macex _))]
  write1 {system write}
  write  [void (write1 (tostr _))])

;; Arc Basics

(sym t true)

(def err (msg . l)
  (if (nil? msg) (set msg "fatal"))
  (let x (if (none? l)
             (tostr msg)
             (apply cat `(,(tostr msg) ,": " ,@(map str l))))
    (error x)))

(mac cmp (x y)
  `(= (do ,x) (do ,y)))

(mac def? (x)
  (target
    lua: `(is? ,x)
    js:  `(not (cmp (typeof ,x) "undefined"))))

(def testify (x)
  (if (function? x) x
    [cmp _ x]))
  
(defs
  fn? function?
  str? string?
  num? number?
  atom atom?
  false? (testify false)
  lst? obj?
  list? obj?
  len #
  idfn [do _]
  tostr [if (str? _) _ (str _)]
  tolist [if (list? _) _ (list _)])

(def parts [list (vals _) (keys _)])
(def acons [not (atom? _)])
(def alist [and (acons _) (or (keys? _) (some? _))])
(def empty [and (acons _) (not (keys? _)) (none? _)])

(def no [or (nil? _) (false? _) (empty _)])
(def t? [not (no _)])

(mac is l
  (if (one? l)
    `(not (no ,@l))
    `(cmp ,@l)))

; for each x in lst, calls (f x).  Returns the last result.
(def map1 (f lst) (o lst ())
  (let val nil
    (step x lst
      (set val (f x)))
    val))

; for each x in lst, calls (f x).  Returns nil.
(def mapnil l
  (void (apply map1 l)))

(mac assert xs
  (with e `(let bad nil)
    (step cond xs
      (add e `(unless (do ,cond) (set bad ',(str cond)))))
    (add e `(when (is? bad)
              (err "assertion failed" bad)))))
(alias be assert)

(mac w/uniq (x . body)
  (if (atom? x)
    `(let-unique (,x) ,@body)
    `(let-unique (,@x) ,@body)))

(mac ado (x . ys)
  `(let it ,x
     ,@ys))

(mac do1 (x . ys)
  (w/uniq g
    `(let ,g ,x
       ,@ys
       ,g)))

(mac but (cond then . else)
  `(if ,cond ,then
     (do ,@else)))

(mac isnt (cond then . else)
  `(if (not ,cond) ,then
     (do ,@else)))

(mac lastly (x . ys)
  `(do1 (do ,@ys) ,x))

(mac after (x . ys)
  `(let ((ok v) (guard (do ,x)))
     (if ok v
       (lastly (err v)
         ,@ys))))

; optional args.  For each (var val) in l, if var is nil, then
; do (set var val)
(mac o l
  (with e '(do)
    (let r 'nil
      (step (var val) (pair l)
        (add e `(if (nil? ,var) (set ,var ,val)))
        (set r var))
      (add e r))))

; e.g.
;  (def foo l (w/args l (a b c . (lh rh))
;    (obj a: a b: b c: c lh: lh rh: rh rest: rest)))
(mac w/args (l args . body) (o l () args ())
  (w/uniq g
    `(let (,g ,l
           rest (get ,g 'rest)
           ,(vals args) ,g
           ,(or (get args 'rest) ()) (if rest rest (list)))
       ,@body)))

(mac yesno (name body)
  `(mac ,name (x yes . l) (o yes t)
     `(ado ,x (if ,',body (do ,yes) (do ,@l)))))

(yesno any? (and (list? it) (or (keys? it) (some? it))))
(yesno 0? (or (nil? it) (none? it)))
(yesno 1? (and (list? it) (one? it)))
(yesno 2? (and (list? it) (two? it)))

(def _any? [do (be (or (nil? _) (list? _))) (any? _)])
(def _0?   [do (be (or (nil? _) (list? _))) (0? _)])
(def _1?   [do (be (or (nil? _) (list? _))) (1? _)])
(def _2?   [do (be (or (nil? _) (list? _))) (2? _)])

(mac complement (f)
  (w/uniq g
    `(fn ,g (not (apply ,f ,g)))))

(mac repeat (n . l)
  (w/uniq g
    `(for ,g ,n
      ,@l)))

(mac push (lst x)
  `(ado ,lst (add it ,x) it))

(mac pop (lst)
  `(ado ,lst (last it) (drop it)))

(mac w/push (lst x . l)
  (w/uniq g
    `(let ,g (push ,lst ,x)
       (lastly (pop ,g)
          ,@l))))

(mac lfn (name args body . l)
  `(let ,name nil
     (set ,name (fn ,args ,body))
     ,@(if (some? l) l
         (list name))))

(mac afn (args body . l)
  `(lfn self ,args ,body ,@l))

(mac letmac (name args body . l)
  `(let-macro ((,name ,args ,body))
     ,@l))

(mac add (l x)
  (target js: `(do ((get ,l 'push) ,x) nil)
          lua: `((get table 'insert) ,l ,x)))


(mac accum (name . body)
  (w/uniq g
    `(with ,g ()
       (letmac ,name (x) (list 'add ',g x)
         ,@body))))

(mac bag l
  `(accum put ,@l))

(mac sbag l
  `(sort (bag ,@l)))

; ; This serves as an example of how to write a metamacro.  There are
; ; probably better ways to write it, and the idea isn't very good in
; ; this case.  But it's a general technique worth knowing.

; (each form (list "let" "each" "step" "for" "when" "while")
;   (eval `(mac ,(cat "bag:" form) l
;            `(bag (,',form ,@l)))))

; ; (eval (bag:let x 42 (put '+) (put x) (put 2))) ; gives 44
; ; (map print (bag:for i 10 (unless (= i 2) (put (cat "Current line is " i)))))
; ; (sort (bag:each (k v) (hd environment) (put k)))

(mac nor l
  `(not (or ,@l)))

(mac ifnot (cond . l)
  `(if (not ,cond) ,@l))
(alias nif ifnot)

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

(mac kv (lst . body)
  `(each (k v) ,lst
     ,@body))

(mac skv (lst . body)
  (w/uniq g
    `(let ,g ,lst
       (step k (sbag (kv ,g
                       (isnt (num? k) (put k)
                         ,@body)))
         (let v (get ,g k)
           ,@body)))))

(def kvs (x)
  (bag (kv x
         (if (num? k) (put v)
           (put (list k v))))))

(def car (x)
  (if (is x)
    (hd x)))
 
(def cdr (x)
  (if (is x)
    (ado (tl x)
      (0? it (kvs it)
        it))))

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
    (bag (each item lst
      (if sep (put sep)
        (set sep x))
      (put item)))))

(def keep (f xs)
  (set f (testify f))
  (bag (step x xs
    (when (f x)
      (put x)))))

(def rem (f xs)
  (keep (complement (testify f)) xs))

(def rev reverse)
; ;; Printing.

; (def bstr [do (obj buf: (o _ "") in: 0)])
; (def bget [get _ 'buf])
; (def bcat1 (b x) (when (is? x) (cat! {b buf} x)))
; (def bin (b)
;   (repeat (inc {b in})
;     (bcat1 b "  "))
;   b)
; (def bout (b)
;   (dec {b in})
;   ; (bcat1 b "\n")
;   b)
; (def bcat l (w/args l
;           (b val sep parents . (lh rh))
;   (do (if (and (not (atom? x)) (in? x parents))
;     (bcat1 b 'circular)
;     (w/push parents x
;             (bcat b x "" parents . (list lh rh)))))
;   (when (atom? val)
;     (bcat1 b (if (fn? val) "fn" val))
;     (return (bget b)))
;   (o parents () lh "(" rh ")")
;   (bcat1 b lh)
;   (let ks ()
;     (each (k v) val
;       (add ks k))
;     (set ks (sort ks))
;     (step k ks
;       (let x (get val k)
;         (o sep "")
;         (if (not (num? k))
;           (set sep "\n"))
;         (bcat1 b sep)
;         (if (= sep "\n")
;           (bin b)
;           (do (unless (atom? x) (bcat1 b lh))
;               (set sep " ")))
;         (unless (num? k)
;           (bcat1 b (tostr k))
;           (bcat1 b ": "))
;         (if (and (not (atom? x)) (in? x parents))
;             (bcat1 b 'circular)
;             (w/push parents x
;               (bcat b x "" parents . (list lh rh))))
;         (if (= sep "\n")
;           (bout b)
;           (unless (atom? x) (bcat1 b rh))))))
;   (bcat1 b rh)
;   (bget b)))

; (def cats l
;   (bcat (bstr) (if (one? l) (at l 0) l)))

; (def write [print (cats _)])

;; Basics

; Useful benchmark?

; (let lines (split (read-file "test.l") "\n")
;   (apply cat 
;     (intersperse "\n"
;       (intersperse "foo" lines))))

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

;  (def foo l (w/args l (a b c . (lh rh))
(def pr l (w/args l (x . xs)
  (let ((sep lh rh) (tolist xs))
    (o sep "")
    (let c nil
      (if lh (write lh))
      (if sep
        (step x l
          (if c (write c)
            (set c (tostr sep)))
          (write (tostr x)))
        (step x l
          (write (tostr x))))
      (if rh (write rh)))
    (when l (hd l)))))

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

(def loadstr (s :verbose :on-err :print)
  (step expr (readstr s)
    (when (= "1" (env "VERBOSE")) (prn (str expr)))
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
           (with result ({o toString}))
             (when (env "VERBOSE")
               (prn result)))))
  (target lua: (do
    (var exec (s)
      ; http://stackoverflow.com/questions/9676113/lua-os-execute-return-value
      ; Watch out, popen() sometimes fails to block:
      ; http://lua-users.org/lists/lua-l/2013-10/msg00727.html
      (let h ({io popen} cmd)
        (do1 (with result ({h read} h "*a")
               (when (env "VERBOSE")
                 (prn result)))
             ({h close} h))))
    (exec cmd))))

; (exit)
(def exit (code)
  (target js: ({process exit} code)
          lua: ({os exit} code)))


