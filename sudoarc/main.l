
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
    (when (in? op (list "-h" "--help" "help"))
      (appusage)
      (return))
    ; run a lumen script.
    (when (script? op)
      (return (load op)))
    ; run any lumen scripts, then get a repl.
    (when (= op "repl")
      (map load params)
      (return))) ; lumen's (main) will start a repl.
  ; eval files.
  (step arg argv
    (if (script? arg) (load arg)
        (error (cat "unknown cmd " arg)))))
(appmain (args))


