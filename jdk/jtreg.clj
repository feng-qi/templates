#!/usr/bin/env inlein

'{:dependencies [[org.clojure/clojure "1.8.0"]
                 [me.raynes/fs "1.4.6"]]}

(require '[clojure.pprint     :refer [pprint]])
(require '[clojure.java.shell :refer [sh]])
(require '[me.raynes.fs       :as fs])

;; (->> (sh "ls")
;;      :out
;;      print)

;; (->> (fs/list-dir fs/*cwd*)
;;      (filter fs/file?)
;;      (map str)
;;      (map println)
;;      doall)

(println *command-line-args*)

(def jtreg-cmd [(str (fs/expand-home "~/repos/jtreg/jtreg-hg/dist/jtreg/bin/jtreg"))
                "-othervm" "-a" "-ea" "-esa" "-va"
                "-vmoptions:--add-modules jdk.incubator.vector -XX:+UnlockDiagnosticVMOptions -XX:+DebugVectorApi -XX:-TieredCompilation"
                "-ignore:quiet"
                "-timeoutFactor:16"
                "-J-Xmx4g"
                (str "-testjdk:" (fs/expand-home "~/builds/panama-build/images/jdk"))
                "-server"
                (str "-r:" (fs/expand-home "~/builds/JTReport"))
                (str "-w:" (fs/expand-home "~/builds/JTWork"))])

(defn jtreg [file-or-dir]
  (let [cmd (conj jtreg-cmd file-or-dir)]
    (pprint cmd)
    (->> (apply sh cmd)
         :out
         print)))

;; (defn jtreg [file-or-dir]
;;   (println "debug:" file-or-dir))

(let [invalid-files (->> *command-line-args*
                         (map fs/file)
                         (filter (complement fs/exists?))
                         (map str))]
  (if (empty? invalid-files)
    (doall (map jtreg *command-line-args*))
    (do (println "some file does not exist:")
        (pprint invalid-files))))

(flush)
(shutdown-agents)
;; (System/exit 0)
