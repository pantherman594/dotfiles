#!/bin/bash

# Terminate already running bar instances and their helper functions
killall -q polybar
ps axo pid,command | grep "bash /home/pantherman594/.config/polybar/scripts/" | head -n -1 | sed 's/^ *\([0-9]*\).*$/\1/g' | xargs kill

i=1
# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null
do
    # killall -q polybar
    sleep 1
    i=$(( i + 1 ))
    if [ $i -gt 10 ]
    then
        killall -9 -q polybar
    fi
done

# Launch bars
launchedSecondary=false
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [[ "$m" != "eDP-1" ]]; then
      if [ "$launchedSecondary" = false ]; then
        MONITOR=$m polybar -c ~/.config/polybar/config.ini secondary -q -r &
        launchedSecondary=true
      else
        MONITOR=$m polybar -c ~/.config/polybar/config.ini tertiary -q -r &
      fi
    fi
  done
else
  polybar secondary -q -r &
  polybar tertiary  -q -r &
fi
polybar -c ~/.config/polybar/config.ini primary -q -r 2>/tmp/polylog &
