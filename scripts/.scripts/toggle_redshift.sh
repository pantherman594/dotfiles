#!/bin/bash

RED_PID=~/.config/polybar/red_pid

if pgrep -x "redshift" > /dev/null
then
    killall -q redshift

    i=1
    # Wait until the processes have been shut down
    while pgrep -u $UID -x redshift >/dev/null
    do
        sleep 1
        i=$(( i + 1 ))
        if [ $i -gt 10 ]
        then
            killall -9 -q redshift
        fi
    done
else
    urxvt -e redshift &
    sleep 2
    i3-msg "[title=redshift] move container to workspace 99rs"
fi
kill $(cat $RED_PID)
