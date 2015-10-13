
(def fetch (repo subdir)
  (shell (cat "mkdir -p " subdir))
  (shell (cat "git clone https://github.com/" repo " " subdir)))

(each file (args)
  (prn file)
  (iflet code (readfile file))
   (do (prn code)
      (eval code)))

