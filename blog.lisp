(in-package :com.heitorchang.blog)

(defparameter *version* "2025-10-18_1242")

(defparameter *html-header* "<!DOCTYPE html>
<html lang=\"en\">
    <head>
        <meta charset=\"utf-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
        <title>Heitor's Common Lisp Blog</title>
        <base target=\"_blank\">
        <style>
body {
  font-family: sans-serif;
  background-color: HoneyDew;
  display: flex;
  justify-content: center;
}

a {
  font-weight: bold;
  text-decoration: none;
}

#content {
  max-width: 50rem;
  width: 100%;
  padding: 1rem;
}

.index-table td {
  padding-left: 1.2rem;
}
        </style>
    </head>
    <body>
        <div id=\"content\">
")

(defparameter *html-footer* "
</div></body></html>
")

(defvar *checksum-history* (make-hash-table :test #'equal))

(defun ctime (filename)
  "Retrieve the ctime from the file with the given filename."
  (osicat-posix:stat-ctime (osicat-posix:stat filename)))

(defun md5sum (filename)
  "Compute the checksum of the file."
  (car (uiop:split-string (uiop:run-program (list "md5sum" filename) :output :string))))

(defun convert-markdown (filename output-filename)
  "Convert the Markdown file with 'filename' and write to 'output-filename'"
  (format t "~A ~A~%" "Converting" filename)

  ;; Write the header, converted HTML, and footer
  (with-open-file (out output-filename :direction :output :if-exists :supersede)
    (format out "~A~%" *html-header*)
    (format out "~A~%" "        <p><a href=\"index.html\" target=\"_self\">Home page</a></p>")
    (3bmd:parse-string-and-print-to-stream (uiop:read-file-string filename) out)
    (format out "~A~%" *html-footer*)))

(defun html-filename (filename)
  "Replace the filename's extension with '.html'."
  (file-namestring (make-pathname :type "html" :defaults filename)))

(defun index-link (filename timestamp)
  "Create an individual line in the index's list of posts."
  (format nil "<tr><td><a href=\"~A\" target=\"_self\">~A</a></td> <td><em>~A</em></td></tr>" filename (file-namestring filename) timestamp))

(defun blog (markdown-dir build-dir)
  "Load the checksums and iterate over the files in 'markdown-dir'."
  (format t "Version: ~A~%~%" *version*)
  (let* ((build-dir (uiop/pathname:ensure-directory-pathname build-dir))
         (checksums-filename (merge-pathnames build-dir "checksums.lisp")))

    (ensure-directories-exist build-dir)
    (unless (probe-file checksums-filename)
      (with-open-file (out-checksums checksums-filename :direction :output)
        (format out-checksums "~A" (list "created" (get-universal-time)))))

    ;; Load checksum history
    (let ((checksums (uiop:read-file-forms (merge-pathnames build-dir "checksums.lisp"))))
      (dolist (checksum checksums)
        (setf (gethash (car checksum) *checksum-history*) (cadr checksum))))

    ;; Prepare index.html
    (with-open-file (out-index (merge-pathnames build-dir "index.html") :direction :output :if-exists :supersede)
      (format out-index "~A~%" *html-header*)
      (format out-index "~A~%" "<h1>Heitor's Common Lisp Blog</h1><table class=\"index-table\">")

      ;; Iterate over list of Markdown files
      (dolist (filename (sort (uiop:directory-files (uiop/pathname:ensure-directory-pathname markdown-dir)) #'> :key #'ctime))
        (format out-index "~A~%" (index-link (html-filename filename) (local-time:format-timestring nil (local-time:unix-to-timestamp (ctime filename)) :format local-time:+asctime-format+)))

        ;; Convert markdown
        (let ((output-filename (merge-pathnames build-dir (html-filename filename)))
              (input-md5sum (md5sum (namestring filename))))
          (unless (string= input-md5sum (gethash filename *checksum-history*))
            ;; Add md5sum to checksum hash table
            (setf (gethash filename *checksum-history*) input-md5sum)
            (convert-markdown filename output-filename))))
      (format out-index "~A~%" "</table>")
      (format out-index "~A~%" *html-footer*))

    ;; Write checksums back to history file
    (with-open-file (out-checksums checksums-filename :direction :output :if-exists :supersede)
      (with-standard-io-syntax
        (loop for key being the hash-keys of *checksum-history*
              for val being the hash-values of *checksum-history*
              do (format out-checksums "~S~%" (list key val)))))))

(defun write-cl-blog ()
  "Convenience function that uses predefined directory names."
  (blog "~/code/common-lisp-blog/markdown" "~/code/common-lisp-blog/cl-blog"))
