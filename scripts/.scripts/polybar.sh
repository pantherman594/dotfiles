#!/bin/bash

# Terminate already running bar instances
killall -q polybar

i=1
# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null
do
    sleep 1
    i=$(( i + 1 ))
    if [ $i -gt 10 ]
    then
        killall -9 -q polybar
    fi
done

# Launch bar1 and bar2
polybar primary -q -r &
polybar secondary -q -r &
