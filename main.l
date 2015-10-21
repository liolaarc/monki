
(let sys (require 'system)
  (def j (get sys 'path-join))
  (def file? (get sys 'file-exists?)))

(def dir? (path)
  ; There isn't any way to determine whether a directory exists in
  ; plain Lua without resorting to third-party libraries.
  ;
  ; This hack is silly, but it works on all hosts.  It's also
  ; vulnerable to shell injection. (Monki scripts are already code
  ; execution, so maybe this doesn't matter, but fix it anyway.)
  ; TODO: Remove this hack.
  (= "1" ($ hush: true "sh" "-c" (cat "if [ -d " (escape path) " ]; then echo 1; fi"))))

(def exists? (path)
  (or (dir? path) (file? path)))

(def dirname (file)
  ($ hush: true "dirname" file))

(def basename (file)
  ($ hush: true "basename" file))

(def realpath (path)
  (if (dir? path)
    ($ "cd" path ";" "pwd")
    (j ($ "cd" (dirname path) ";" "pwd") (basename path))))

(def rmrf (path)
  (when (= 0 (search path "/"))
    (error (cat "Cowardly refusing to rm -rf an absolute path: " path)))
  (when (or (dir? path) (file? path) )
    ($ "rm" "-rf" path)))

(def surround (x :lh :rh)
  (cat (or lh "") x (or rh "")))

(def q (x)
  (if (ws? x) (surround x lh: "\'" rh: "\'")
    x))

(def docmd (cmdline)
  ;(at (guard (shell cmdline)) 1))
  (shell cmdline))

(def cwd ".")
(def getcwd () cwd)

(def pushds ())

(def pushd (path)
  (add pushds (pwd))
  (cd path))

(def popd ()
  (when (none? pushds)
    (error "popd: directory stack empty"))
  (let i (edge pushds)
    (cd (at pushds i))
    (set pushds (cut pushds 0 i)))
  (pwd))

(def cd (path)
  (if path
      (set cwd ($ hush: true "cd" path ";" "pwd"))
      (set cwd "."))
  (pwd))
(def cd1 cd)

(mac cd (path rest: l)
  (if (none? l)
    `(cd1 ,path)
    `(do (pushd ,path)
         (do1 (do ,@l)
           (popd)))))

(def resetcwd ()
  (set cwd ".")
  (set pushds ()))

(def pwd ()
  ($ hush: true "pwd"))

(def mkdir (path)
  ($ "mkdir" "-p" path))

(mac w/mkdir (path rest: body)
  (w/uniq g
    `(let ,g ,path
       (mkdir ,g)
       (pushd ,g)
       (do1 (do ,@body)
         (popd)))))

(def tree (path pattern)
  (unless (dir? path)
    (error (cat "tree: not a dir: " path)))
  (cd path
    (let s (trim (if pattern 
               ($ "find" "." "|" "grep" "-v" "'/\\.monki/'" "|" "grep" pattern "|" "cat")
               ($ "find" "." "|" "grep" "-v" "'/\\.monki/'" "|" "cat")))
      (if (and s (some? s))
        (split s "\n")
        (list)))))

(def which (prog)
  (let ((ok x) (guard ($ "which" prog)))
    (when ok
      x)))

(def freebsd? ()
  (= ($ "uname") "FreeBSD"))

(def make args
  (let prog (if (freebsd?)
                (if (which "gmake") "gmake"
                    (error "Install gmake by running:  sudo pkg install gmake"))
                "make")
    (prn (apply $ (join (list "time" prog) args)))))

(def clean () (make "clean"))
(def build () (make "--always-make" "all"))
(def test () (make "--always-make" "test"))

(def rebuild (count)
  (clean)
  (repeat (or count 1)
    (build)))

;
; Application.
;

(def unlit (x)
  (if (id-literal? x) (inner x)
    x))

(def replace (str x y count)
  (lfn self (str x y count)
     (do (when (and count (= count 0))
           (return str))
         (iflet pos (search str x)
           (cat (clip str 0 pos)
                y
                (self (clip str (+ pos (# x))) x y (and count (- count 1))))
           str))
    (self (unlit str) (unlit x) (unlit y) count)))

(lfn tolit (x)
  (if (not (atom? x)) x
      (id-literal? x) (list 'quote (inner x))
      (string? x) x
    (list 'quote x))

(mac replace args
  `(replace1 ,@(map tolit args))))
(def replace1 replace) ; a sneaky hack to make (apply replace '(foo o z)) work.

(mac patch (file x y)
  (w/uniq g
    `(w/file ,g (j (getcwd) ,file)
       (replace ,g ,x ,y))))

(mac create (file x)
  (w/uniq g
    `(let ,g (j (getcwd) ,file)
       (touch ,g)
       (w/file ,g (j (getcwd) ,file)
         ,x))))

(def touch (files)
  (apply $ `(touch ,@(listify files))))

(def $ args
  (let hush (get args 'hush)
    (let (c "" cmds ())
      (step arg args
        (if (= arg ";") (do (add cmds c)
                            (set c ""))
            (= c "") (do (cat! c arg)
                         (cat! c " "))
            (do (cat! c (q arg))
                (cat! c " "))))
      (if (some? c)
        (add cmds c))
      (let cmdline (apply cat (intersperse "; " cmds))
        (when (not (= cwd "."))
          (set cmdline (cat "cd " (q cwd) "; " cmdline)))
        (when (or (not hush) (env "VERBOSE"))
          (prn cmdline))
        (rtrim (docmd cmdline))))))

(def git? (path)
  (dir? (j path ".git")))

(def git (path what rest: args)
  (unless (= what "clone")
    (unless (git? path)
      (error (cat "no .git at " path))))
  (apply $ (join (list hush: true "git"
                       (cat "--git-dir=" (q (j path ".git")))
                       what) args)))

(def gitdir (path nocheck)
  (let dst (if path (j path ".monki" "git") (j ".monki" "git"))
    (unless nocheck
      (unless (git? dst)
        (let errmsg (cat "Error: no .git at " dst)
          (prn errmsg))))
    dst))

(def giturl (dst)
  (when (git? dst)
    (trim ($ "cat" (j dst ".git" "config")
             "|" "grep" "-o" "url.*=.*"
             "|" "cut" "-d'='" "-f2-"))))

(def repo-changed? (dst repo)
  (iflet url (giturl dst)
    (not (= url repo))))

(def clone (repo revision)
  (when (or (not repo) (none? repo))
    (error "fetch: bad repo"))
  (unless (or (= "." (char repo 0))
              (search repo "://"))
    (set repo (cat "https://github.com/" repo)))
  (mkdir (gitdir "." true))
  ($ "echo" "'*'" ">" (j ".monki" ".gitignore"))
  (let dst (gitdir "." true)
    (when (repo-changed? dst repo)
      (rmrf dst))
    (unless (git? dst) ($ "git" "clone" "-n" repo dst))
    (unless (git? dst) (error (cat "could not clone " repo " to " dst)))
    (git dst "reset" "--" ".")
    (git dst "checkout" "--" ".")
    (git dst "checkout" "master")
    (git dst "pull")
    (when revision (git dst "checkout" revision))))

(def monki (path)
  (let (dir (dirname path)
        file (basename path))
    (cd dir
      ; copy the file, in case the repo we're cloning from contains a file
      ; of the same name.
      ($ "mkdir" "-p" (j ".monki" "tmp"))
      ($ "cp" file (j ".monki" "tmp"))
      ; run the file.
      (load (realpath file)  verbose: true)
      ; restore the file.
      ($ "cp" (j ".monki" "tmp" file) file)
      ($ "rm" (j ".monki" "tmp" file)))))

; recursively call monki on any file named "monki.l" under the path.
(def monkitree (path)
  (cd path
    (each file (tree "." "/monki.l$")
      (prn (j (pwd) path file))
      (monki file))))

; ; TODO: Figure out why this breaks. Report it if it's a compiler bug.
; (def monkitree (path)
;   (each file (tree path "/monki.l$")
;     (cd path ; this is where the bug happens, and only on lua hosts.
;       (prn (j (pwd) file))
;       (monki file))))

(def musage ()
  (prn "  to run all monki.l files beneath a dir:")
  (prn "    monki <dir>")
  (prn "  to clone a git repo at a subdir:")
  (prn "    monki clone <url> [revision] <subdir>")
  (prn "")
  (prn " e.g.  monki clone laarc/monki monki"))

(def mmain (argv)
  ; eval files in subdirs.
  (when (none? (or argv ()))
    (return (monkitree (pwd))))
  ; help.
  (when (in? (at argv 0) (list "-h" "--help" "help"))
    (musage)
    (return))
  (let (op (at argv 0)
        params (cut argv 1))
    ; clone.
    (when (= op "clone")
      (unless (> (len argv) 1)
        (musage)
        (return))
      (let dst (at argv (edge argv))
        (when (dir? dst)
          (error (cat "monki clone: already exists: " dst)))
        (mkdir dst)
        ($ "echo" (cat "(clone " (inner (string (cut params 0 (edge params)))) ")")
           ">" (j dst "monki.l"))
        (return (monkitree dst))))
    ; git.
    (when (= op "git")
      (prn (apply git (join (list (gitdir (pwd))) (or params ()))))
      (return)))
  ; eval files.
  (step arg argv
    (if (dir? arg) (monkitree arg)
        (endswith arg ".l") (monki arg)
        (error (cat "unknown cmd " arg)))))
(mmain (args))

