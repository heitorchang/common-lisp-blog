# ctime

In sorting the blog posts, I am using the `osicat-posix:stat` function. With my SBCL settings of `(debug 2) (safety 1) (space 0) (speed 0)`, I get warning messages "could not stack allocate SB-IMPL::PREDICATE-FUN" and "could not stack allocate SB-IMPL::KEY".

After removing these settings and trying again, the messages no longer appear.

*Edit*: changing this file and checking if `rsync` is behaving properly.