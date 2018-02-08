#!/bin/bash

if pgrep -x "redshift" > /dev/null
then
    killall redshift
else
    urxvt -e redshift &
    sleep 2
    i3-msg "[title=redshift] move container to workspace 99rs"
fi
