
(def appusage ()
  (prn "  to run a script:    sudoarc foo.l")
  (prn "  to get a repl:      sudoarc")
  (prn ""))

(def script? (name)
  (or (endswith name ".l")
      (endswith name ".arc")))

(def appmain (argv)
  (when (none? (or argv ()))
    (return)) ; lumen's (main) will start a repl.
  (let (op (at argv 0)
        params (cut argv 1))
    ; help.
    (when (in? op '(help h --help -h -? ? /? haalp))
      (appusage)
      (return))
    ; run a lumen script.
    (when (script? op)
      (return (load op)))
    ; eval expressions.
    (when (in? op '(eval e))
      (loadstr (clip (env 'cmdline) (# op)) :print)
      (return))
    ; get a repl.
    (when (in? op '(repl r))
      (return))) ; lumen's (main) will start a repl.
  ; eval files.
  (step arg argv
    (if (script? arg) (load arg)
        (error (cat "unknown cmd " arg)))))
(appmain (args))


