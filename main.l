
(def fetch (repo subdir)
  (shell (cat "mkdir -p " subdir))
  (shell (cat "git clone https://github.com/" repo " " subdir)))

(each file (args)
  (prn file)
  (iflet exprs (readfile file))
   (do (prn exprs)
      (eval exprs)))

