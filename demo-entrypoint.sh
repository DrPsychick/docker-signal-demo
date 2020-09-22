#!/bin/bash

function cleanup() {
  echo "--> Cleanup..."
  # unset TERM trap
  trap - TERM
  # terminate all jobs (child processes)
  kill -TERM 0
  ps faxuwww
}

trap cleanup EXIT
# trap each signal and print what happens...
trap 'echo "--> got signal: TERM - shutdown."; tmux kill-server; screen -X kill' TERM
trap 'echo "--> got signal: INT - shutting down..."; tmux send-keys C-c exit C-m; screen -X kill' INT
trap 'echo "--> got signal: USR1 - stopping tmux"; tmux send-keys C-c exit C-m' USR1
trap 'echo "--> got signal: USR2 - stopping screen"; screen -X kill' USR2
trap 'echo "--> got signal: HUP - status report"; ps faxuwww' HUP
trap 'echo "--> got signal: QUIT/ABRT"' QUIT ABRT

# start a tmux session
tmux new-session -d -s tmux
tmux send-keys 'while (true); do echo "$(date +%Y-%m-%d\ %H:%M:%S) tmux-running" | tee -a console.log; sleep 1; done' C-m

# start a screen session
screen -dmS screen bash -c 'while (true); do echo "$(date +%Y-%m-%d\ %H:%M:%S) screen-running" | tee -a console.log; sleep 1; done'

# dump running processes
ps fauxwww
# dump installed traps
echo "--> Traps"
trap -p

# output to pod stdout (will be stopped by cleanup)
tail -fF console.log &

# run a second background job
(while (true); do echo "Job no.2 is still here ..."; sleep 5; done) &

# demonstrate how exec passes on the signals
if [ "x$EXEC_DEMO" = "xyes" ]; then
  # execution stops here, void_trap.sh will take over
  exec /void_trap.sh
fi

# void_trap is executed in a sub shell and this continues
# void_trap has no effect on traps in this script
/void_trap.sh

# wait for tmux and screen to quit
tmux_pid=$(tmux display-message -pF '#{pid}')
scrn_pid=$(screen -ls | grep -P "^\t[0-9]*\." | sed -e 's#^\t\([0-9]\+\)\..*#\1#')
echo "Tmux: $tmux_pid Screen: $scrn_pid"
while (ps -p $tmux_pid,$scrn_pid >/dev/null); do sleep 2; done
echo "--> Done"
