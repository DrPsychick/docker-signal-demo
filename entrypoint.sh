#!/bin/bash

########################################################################################################################
# # Standard `entrypoint.sh`
#
# simply terminate all child processes before exiting
# support optionally `exec` to take over the process and signal handling
########################################################################################################################

# if EXEC=yes, then the app takes care of signal handling and cleanup itself
if [ "x$EXEC" = "xyes" ]; then
  exec $@
fi

# cleanup upon TERM signal
function cleanup() {
  trap - TERM
  # terminate all children (jobs)
  kill -TERM 0
}
trap cleanup TERM

$@