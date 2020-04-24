#!/bin/sh

set -e

. "$(dirname "$0")/tidy.sh"

push_sig_handler EXIT "echo 'Bye!'"
push_sig_handler EXIT "echo 1" HANDLER
push_sig_handler EXIT "echo 2"
push_sig_handler EXIT "echo 3"
push_sig_handler EXIT "\
bash -c 'echo \"foo  bar     baz\";\
exit 2'"
echo "----"
pop_sig_handler EXIT 1 || echo "Handler exited with code: $?"
echo "----"
push_sig_handler EXIT "echo 5" HANDLER_2
push_sig_handler EXIT "echo 6"
push_sig_handler EXIT "echo 7; false"
push_sig_handler EXIT "echo 8"
pop_sig_handler EXIT 1
push_sig_handler EXIT "echo 9" HANDLER_3
echo "----"
echo "Cancel handler ${HANDLER_3}"
cancel_sig_handler EXIT "${HANDLER_3}"
echo "----"
echo "Cancel handler ${HANDLER_2}"
cancel_sig_handler EXIT "${HANDLER_2}" RES
echo "Handlers exit codes: ${RES}"
echo "----"
pop_sig_handler EXIT
