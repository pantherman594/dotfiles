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

# Launch bars
polybar primary -q -r &
launchedSecondary=false
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [[ "$m" != "eDP-1" ]]; then
      if [ "$launchedSecondary" = false ]; then
        MONITOR=$m polybar secondary -q -r &
        launchedSecondary=true
      else
        MONITOR=$m polybar tertiary -q -r &
      fi
    fi
  done
else
  polybar secondary -q -r &
  polybar tertiary  -q -r &
fi
