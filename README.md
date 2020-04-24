Motivation
==========

When writing shell scripts, the need to have a more sophisticated
error handling mechanism arise quite often. Most shells provide the
`trap` builtin to install a handler for a specific signal but when you
need to stack up multiple handlers the use of `trap` is
cumbersome. This small shell library tries to address this issue and
provide a kind of exception handling mechanism which should improve
the way you deal with errors in your shell scripts. This library is
not tied with a particular shell and can be used with any POSIX shell.

Usage
=====

To use this library, clone this repository and source `tidy.sh` in
your shell script. Three functions should now be available in your
script:

  * `push_sig_handler`
  * `pop_sig_handler`
  * `cancel_sig_handler`

These functions are documented in the source code of the library.

Examples
========

See the `examples` directory.
