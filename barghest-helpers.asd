(defsystem "barghest-helpers"
  :version "0.0.1"
  :author "nmunro"
  :license "BSD3-Clause"
  :description ""
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "main"))))
  :in-order-to ((test-op (test-op "barghest-helpers/tests"))))

(defsystem "barghest-helpers/tests"
  :author "nmunro"
  :license "BSD3-Clause"
  :depends-on ("barghest-helpers"
               :rove)
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for barghest-helpers"
  :perform (test-op (op c) (symbol-call :rove :run c)))
