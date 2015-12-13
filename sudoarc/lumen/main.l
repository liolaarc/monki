;; -*- mode: lisp -*-

(define reader (require 'reader))
(define compiler (require 'compiler))
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

(define-global eval-print (form)
  (let ((ok x trace) (guard ((get compiler 'eval) form)))
    (if (not ok)
        (target
          js: (print trace)
          lua: (print (cat "error: " x "\n" trace)))
        (is? x) (pretty-print x))))

(define rep (s)
  (eval-print ((get reader 'read-string) s)))

(define-global repl ()
  (let buf ""
    (define rep1 (s)
      (cat! buf s)
      (let (more ()
            form ((get reader 'read-string) buf more))
          (unless (= form more)
            (eval-print form)
            (set buf "")
            ((get system 'write) "> ")))))
  ((get system 'write) "> ")
  (target
    js: (let in (get process 'stdin)
          ((get in 'removeAllListeners))
          ((get in 'setEncoding) 'utf8)
          ((get in 'on) 'data rep1))
    lua: (while true
           (let s ((get io 'read))
             (if s (rep1 (cat s "\n")) (break))))))

(define-global compile-file (path)
  (let (s ((get reader 'stream) ((get system 'read-file) path))
        body ((get reader 'read-all) s)
        form ((get compiler 'expand) `(do ,@body)))
    ((get compiler 'compile) form :stmt)))

(define-global load (path)
  ((get compiler 'run) (compile-file path)))

(define run-file (path)
  ((get compiler 'run) ((get system 'read-file) path)))

(define usage ()
  (print "usage: lumen [options] <object files>")
  (print "options:")
  (print "  -c <input>\tCompile input file")
  (print "  -o <output>\tOutput file")
  (print "  -t <target>\tTarget language (default: lua)")
  (print "  -e <expr>\tExpression to evaluate")
  ((get system 'exit)))

(define main ()
  (let arg (hd (get system 'argv))
    (when (or (= arg "-h")
              (= arg "--help"))
      (usage)))
  (let (pre ()
        input nil
        output nil
        target1 nil
        expr nil
        argv (get system 'argv)
        n (# argv))
    (for i n
      (let a (at argv i)
        (if (or (= a "-c") (= a "-o") (= a "-t") (= a "-e"))
            (if (= i (- n 1))
                (print (cat "missing argument for " a))
              (do (inc i)
                  (let val (at argv i)
                    (if (= a "-c") (set input val)
                        (= a "-o") (set output val)
                        (= a "-t") (set target1 val)
                        (= a "-e") (set expr val)))))
            (not (= "-" (char a 0))) (add pre a))))
    (step file pre
      (run-file file))
    (if (nil? input) (if expr (rep expr) (repl))
      (do (if target1 (set target target1))
          (let code (compile-file input)
            (if (or (nil? output) (= output "-"))
                (print code)
              ((get system 'write-file) output code)))))))

(main)
