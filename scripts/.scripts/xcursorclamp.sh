#!/bin/bash

# Terminate already running instances
killall -q xcursorclamp

i=1
# Wait until the processes have been shut down
while pgrep -u $UID -x xcursorclamp >/dev/null
do
    sleep 1
    i=$(( i + 1 ))
    if [ $i -gt 10 ]
    then
        killall -9 -q xcursorclamp
    fi
done

xcursorclamp &
