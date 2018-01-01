#!/bin/bash

echo "RUNN" >> ~/.scripts/redlog
if pgrep -x "redshift" > /dev/null
then
    echo "kill" >> ~/.scripts/redlog
    killall redshift
else
    urxvt -e redshift &
    sleep 2
    i3-msg "[title=redshift] move container to workspace 99rs"
fi
