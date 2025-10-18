# Satisfied so far

I'm hardly writing anything but it feels good that the md5sum hashtable solution is working. The initial version, which just iterated over a sorted list of filenames, was pretty straightforward.

On the other hand, I had to think about how to store the hashtable's key-value pairs. `#'equal` needed to be the test, otherwise, I would get duplicate keys.

While writing shell scripts I mentally say *shebang* to ensure `#!` (*she* is like ha*sh* and *bang* is the exclamation point).

In Lisp, we have *sharp-quote*: `#'` for the functions.