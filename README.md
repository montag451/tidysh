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

Installation
============

To install this shell library, type the following commands:

```sh
git clone https://github.com/montag451/tidysh.git tidysh
cd tidysh
mkdir build
cd build
cmake ../
make install
```

It will install the library in `/usr/local/lib/tidysh`. If you want to
change the install directory you can set the variables
`CMAKE_INSTALL_PREFIX` and/or `CMAKE_INSTALL_LIBDIR`.

You can also create RPM and DEB packages using the command `make package`.

Usage
=====

To use this library, source it in your shell script. Four functions
should now be available in your script:

  * `tidy_push`
  * `tidy_pop`
  * `tidy_cancel`
  * `tidy_quote`

These functions are documented in the source code of the library.

Examples
========

See the `examples` directory.
