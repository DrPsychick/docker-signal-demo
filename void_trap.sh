#!/bin/bash

# no traps here and no impact on "parent" shell traps
echo "--> Start (void_trap)"
ps -uwww -p 1
echo "--> Traps (void_trap)"
trap - USR1 USR2 # unset traps: no impact
trap -p # because there are none...
# set new trap
trap 'echo "EXIT (void_trap)"' EXIT
echo "--> Done (void_trap)"