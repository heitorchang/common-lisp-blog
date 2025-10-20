(defpackage :com.heitorchang.blog (:use :asdf :cl) (:export :write-cl-blog :write-personal-blog))
(in-package :com.heitorchang.blog)

(defsystem "common-lisp-blog"
  :description "A Blog Generator"
  :version "0.0.1"
  :author "Heitor Chang"
  :license "MIT"
  :depends-on (:3bmd :osicat :local-time)
  :components ((:file "blog")))
