
(import compiler)
(def eval (get compiler 'eval))

(def surround (x :lh :rh)
  (cat (or lh "\"") x (or rh "\"")))

(def docmd (cmdline)
  (prn cmdline)
  (at (guard (shell cmdline)) 1))

(def ws? (s)
  (or (search s " ")
      (search s "\t")))

(def cmd args
  (let (c ""
        cmds ())
    (each arg args
      (if (= arg ";") (do (add cmds c)
                          (set c ""))
          (= c "") (do (cat! c arg)
                       (cat! c " "))
          (do (cat! c (if (ws? arg) (surround arg) arg))
              (cat! c " "))))
    (if (some? c)
      (add cmds c))
    (docmd (apply cat (intersperse "; " cmds)))))

(def fetch (repo subdir revision)
  (cmd "mkdir -p" subdir)
  (cmd "git clone" (cat "https://github.com/" repo) subdir)
  (cmd "cd" subdir
       ";" "git reset" "--" "."
       ";" "git checkout" "--" ".")
  (when revision
    (cmd "cd" subdir
         ";" "git checkout" revision ".")))

(def monki (file)
  (load file verbose: true))

(each file (args)
  (monki file))

