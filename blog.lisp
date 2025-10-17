(in-package :com.heitorchang.blog)

(defun ctime (filename)
  "Retrieve the ctime from the file with the given filename."
  (osicat-posix:stat-ctime (osicat-posix:stat filename)))

(defun convert-markdown (filename output-filename)
  "Convert the Markdown file with 'filename' and write to 'output-filename'"
  (with-open-file (out output-filename :direction :output :if-exists :supersede)
    (3bmd:parse-string-and-print-to-stream (uiop:read-file-string filename) out)))

(defun html-filename (filename)
  (file-namestring (make-pathname :type "html" :defaults filename)))

(defun blog (markdown-dir build-dir)
  (let ((build-dir (uiop/pathname:ensure-directory-pathname build-dir)))
    (with-open-file (out-index (merge-pathnames build-dir "index.html") :direction :output :if-exists :supersede)
      (dolist (filename (sort (uiop:directory-files (uiop/pathname:ensure-directory-pathname markdown-dir)) #'> :key #'ctime))
        (format out-index "~A~%" filename)
        (convert-markdown filename (merge-pathnames build-dir (html-filename filename)))))))
