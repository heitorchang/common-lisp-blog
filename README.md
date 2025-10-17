# Common Lisp Blog

Convert Markdown files to HTML and generate an index.

## Generating HTML pages

Load the system, change packages, and call `(blog)`

```
(asdf:load-system "common-lisp-blog")
(in-package :com.heitorchang.blog)
(blog "~/code/common-lisp-blog/markdown" "~/code/common-lisp-blog/cl-blog")
```

## Copying files to the public server

`rsync -a cl-blog/ heitor@remote.com:/home/public/cl-blog`