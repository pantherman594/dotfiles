#!/bin/bash

RED_PID=~/.config/polybar/redshift.pid

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
    title=rsbg$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
    urxvt -title ${title} -e sh -c "redshift -l 42.34:-71.20 -t 6500:3200" &
    sleep 0.25
    i3-msg "[title=${title}] move scratchpad"
    sleep 1
fi
kill $(cat $RED_PID)
