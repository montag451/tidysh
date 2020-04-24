#!/bin/sh

# Exit if an unexpected error occurs
set -e

# Source tidy.sh
. "$(dirname "$0")/../tidy.sh"

# Install a handler to say bye when the script finishes
tidy_push EXIT "echo 'Bye!'"

INSTALL_DIR=$(mktemp -d)
# We install a handler to remove the install dir if something goes
# wrong during the installation, the handler will be cancelled at the
# end of the install procedure if installation was successful.
tidy_push\
    EXIT\
    "echo 'Something has gone wrong'; rm -rf '${INSTALL_DIR}'"\
    HANDLER_ID

# Create a temporary directory to do temporary things :)
TMP_DIR=$(mktemp -d)
# Install a handler to cleanup the temporary directory at the end of
# the script no matter the outcome of the installation procedure
tidy_push EXIT "echo 'Clean up the mess'; rm -rf '${TMP_DIR}'"

# Do more stuff (more signal handlers may be installed)...

# Simulate the success or the failure of the installation depending on
# the PID of the shell
[ "$(($$%2))" -eq 0 ] && true || false

# If we reach this point it means that everything was fine, cancel the
# handler
tidy_cancel EXIT "${HANDLER_ID}"

# Inform user that everything is OK
echo "\
Installation was successful, the application \
has been installed in ${INSTALL_DIR}"
