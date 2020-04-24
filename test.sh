#!/bin/sh

set -e

. "$(dirname "$0")/tidy.sh"

tidy_push EXIT "echo 'Bye!'"
tidy_push EXIT "echo 1" HANDLER
tidy_push EXIT "echo 2"
tidy_push EXIT "echo 3"
tidy_push EXIT "\
bash -c 'echo \"foo  bar     baz\";\
exit 2'"
echo "----"
tidy_pop EXIT 1 || echo "Handler exited with code: $?"
echo "----"
tidy_push EXIT "echo 5" HANDLER_2
tidy_push EXIT "echo 6"
tidy_push EXIT "echo 7; false"
tidy_push EXIT "echo 8"
tidy_pop EXIT 1
tidy_push EXIT "echo 9" HANDLER_3
echo "----"
echo "Cancel handler ${HANDLER_3}"
tidy_cancel EXIT "${HANDLER_3}"
echo "----"
echo "Cancel handler ${HANDLER_2}"
tidy_cancel EXIT "${HANDLER_2}" RES
echo "Handlers exit codes: ${RES}"
echo "----"
tidy_pop EXIT
