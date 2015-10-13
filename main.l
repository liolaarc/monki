
(def system (require 'system))
(def env (get system 'get-environment-variable))

(def args (env 'cmdline))

(prn args)

