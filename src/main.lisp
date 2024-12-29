(defpackage barghest/helpers
  (:use :cl)
  (:export #:render
           #:redirect
           #:set-status-code
           #:set-header
           #:forbidden
           #:get-next-url))

(in-package barghest/helpers)

(defun set-status-code (status-code)
  (setf (lack.response:response-status ningle:*response*)
        status-code))

(defun set-header (header)
  (setf (lack.response:response-headers ningle:*response*)
        (append (lack.response:response-headers ningle:*response*) header)))

(defun render (template &rest kws &key &allow-other-keys)
  (let ((template (djula:compile-template* template)))
    (apply #'djula:render-template* (append `(,template nil) kws))))

(define-condition redirect-error (error)
  ((message :initarg :message :initform "Args mismatched" :reader message)))

(defun redirect (url &key (http-code "307") next-url return-url)
  "
  Redirects a url
  @param: http-code An optional http status code, defaults to 307
  @param: next-url The url to redirect to, assuming returning to the current location isn't desired
  @param: return-url If set, will redirect to url and return to the original location
  "
  (set-status-code http-code)
  (cond
    ((and next-url return)
     (error 'redirect-error :message "Can't use next-url and return together"))

    ((and return-url (str:contains? "?" url))
     (set-header (list "Location" (format nil "~A&next=~A" url (lack.request:request-uri ningle:*request*)))))

    ((and return-url (not (str:contains? "?" url)))
     (set-header (list "Location" (format nil "~A?next=~A" url (lack.request:request-uri ningle:*request*)))))

    ((and next-url (str:contains? "?" url))
     (set-header (list "Location" (format nil "~A&next=~A" url next-url))))

    ((and next-url (not (str:contains? "?" url)))
     (set-header (list "Location" (format nil "~A?next=~A" url next-url))))

    (t
     (set-header (list "Location" url)))))

(defun forbidden (template &key msg)
  (set-status-code "403")
  (render template :msg msg))

(defun get-next-url ()
  (format nil "~A" (or (cdr (assoc "next" (lack.request:request-query-parameters ningle:*request*) :test #'equal)) "")))
