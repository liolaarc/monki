
(let sys (require 'system)
  (def j (get sys 'path-join))
  (def file? (get sys 'file-exists?)))

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
  (at (guard (shell cmdline)) 1))

(def cwd ".")

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

(def resetcwd ()
  (set cwd ".")
  (set pushds ()))

(def pwd ()
  ($ hush: true "pwd"))

(mac w/pushd (path rest: body)
  `(do (pushd ,path)
       ,@body
       (popd)))

(def mkdir (path)
  ($ "mkdir" "-p" path))

(mac w/mkdir (path rest: body)
  (w/uniq g
    `(let ,g ,path
       (mkdir ,g)
       (pushd ,g)
       ,@body
       (popd))))

(def tree (path :match)
  (unless (dir? path)
    (error (cat "tree: not a dir: " path)))
  (pushd path)
  (let s (if match 
             ; ($ "find" "." "|" "sed" "'s|^\\./||'" "|" "grep" match)
             ; ($ "find" "." "|" "sed" "'s|^\\./||'"))
             ($ "find" "." "|" "grep" "-v" "'/\\.monki/'" "|" "grep" match)
             ($ "find" "." "|" "grep" "-v" "'/\\.monki/'"))
    (split s "\n")))

(def $ args
  (let hush (get args 'hush)
    (let (c ""
          cmds ())
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
        (unless hush (prn cmdline))
        (rtrim (docmd cmdline))))))

(def git? (path)
  (dir? (j path ".git")))

(def git (path what rest: args)
  (unless (= what "clone")
    (unless (git? path)
      (error (cat "no .git at " path))))
  (apply $ (join (list "git" (cat "--git-dir=" (q (j path ".git"))) what) args)))

(def clone (repo revision)
  (when (or (not repo) (none? repo))
    (error "fetch: bad repo"))
  (unless (or (= "." (char repo 0))
              (= 0 (search repo "://")))
    (set repo (cat "https://github.com/" repo)))
  (mkdir (j ".monki" "git"))
  ($ "echo" "'*'" ">" (j ".monki" ".gitignore"))
  (let dst (j ".monki" "git")
    (unless (git? dst) ($ "git" "clone" "-n" repo dst))
    (unless (git? dst) (error (cat "could not clone " repo " to " dst)))
    (git dst "reset" "--" ".")
    (git dst "checkout" "--" ".")
    (git dst "pull")
    (when revision (git dst "checkout" revision "."))))

(def monki (path)
  (let (dir (dirname path)
        file (basename path))
    (cd dir)
    ; copy the file, in case the repo we're cloning from contains a file
    ; of the same name.
    ($ "mkdir" "-p" (j ".monki" "tmp"))
    ($ "cp" file (j ".monki" "tmp"))
    ; run the file.
    (load (realpath path)  verbose: true)
    ; restore the file.
    ($ "cp" (j ".monki" "tmp" file) file)
    ($ "rm" (j ".monki" "tmp" file))
    (resetcwd)))

; recursively call monki on any file named "monki.l" under the path.
(def monkitree (path)
  (each file (tree path match: "/monki.l$")
    (prn file)
    (monki file)))

(let l (args)
  (if (none? l) (monkitree (pwd))
    (each path l
      (if (dir? path) (monkitree path)
        (monki path)))))

