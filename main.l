
(let x (require 'compiler)
  (def eval (get x 'eval))
  (def macex (get x 'expand)))

(let x (require 'system)
  (def j (get x 'path-join))
  (def file? (get x 'file-exists?)))

(def dir? (path)
  ; There isn't any way to determine whether a directory exists in
  ; plain Lua without resorting to third-party libraries.
  ;
  ; This hack is silly, but it works on all hosts.  It's also
  ; vulnerable to shell injection. (Monki scripts are already code
  ; execution, so maybe this doesn't matter, but fix it anyway.)
  ; TODO: Remove this hack.
  (= "1\n" (docmd (cat "sh -c 'if [ -d " (escape path) " ]; then echo 1; fi'"))))

(def exists? (path)
  (or (dir? path) (file? path)))

(def rmrf (path)
  (when (= 0 (search path "/"))
    (error (cat "Cowardly refusing to rm -rf an absolute path: " path)))
  (when (or (dir? path) (file? path) )
    ($ "rm" "-rf" path)))

(def surround (x :lh :rh)
  (cat (or lh "\"") x (or rh "\"")))

(def docmd (cmdline)
  (at (guard (shell cmdline)) 1))

(def wschars (list " " "\t" "\n" "\r"))

(def ws? (s)
  (for i (len s)
    (let c (char s i)
      (when (in? c wschars)
        (return true)))))

(def $ args
  (let quiet (get args 'quiet)
    (when quiet
      (set (get args 'quiet) nil)) ; TODO: Report this bug.
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
      (let cmdline (apply cat (intersperse "; " cmds))
        (unless quiet
          (prn cmdline))
        (docmd cmdline)))))

(def git? (path)
  (dir? (j path ".git")))

(def git (path what rest: args)
  (unless (= what "clone")
    (unless (git? path)
      (error (cat "no .git at " path))))
  (apply $ (join (list "cd" path ";" "git" what) args)))

; TODO: add support for file paths.
(def realpath (path)
  (unless (dir? path)
    (error (cat "no such dir: " path)))
  (let s ($ "cd" path ";" "pwd")
    ; remove newline. TODO: add a trim fn.
    (clip s 0 (- (len s) 1)))) 

(def fetch (repo dst revision)
  ($ "mkdir" "-p" ".monki")
  ($ "echo" "'*'" ">" (j ".monki" ".gitignore"))
  (let dstgit (j ".monki" dst)
    (unless (git? dstgit)
      (git ".monki" "clone" "-n" (cat "https://github.com/" repo) dst))
    (unless (git? dstgit)
      (error (cat "could not clone " repo " to " dstgit))))
  ($ "mkdir" "-p" dst)
  (let gitdir (realpath (j ".monki" dst ".git"))
    ($ "cd" dst ";" "rm" "-f" ".git")
    ($ "cd" dst ";" "ln" "-s" gitdir ".git"))
  (git dst "reset" "--" ".")
  (git dst "checkout" "--" ".")
  (git dst "pull")
  (when revision
    (git dst "checkout" revision "."))
  ($ "rm" (j dst ".git")))

(def monki (file)
  (load file verbose: true))

(each file (args)
  (monki file))

