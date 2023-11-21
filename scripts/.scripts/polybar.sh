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

POLYBAR="polybar -c ~/.config/polybar/config.ini -q -r"

# Launch bars
launchedBars=0
if type "xrandr"; then
  for m in $(xrandr --listactivemonitors | tail -n+2 | awk -F ' ' '{print $NF}'); do
    if [ "$launchedBars" = 0 ]; then
      MONITOR=$m $POLYBAR primary 2>/tmp/polylog &
      echo MONITOR=$m $POLYBAR primary 2>/tmp/polylog &
    elif [ "$launchedBars" = 1 ]; then
      MONITOR=$m $POLYBAR secondary &
      echo MONITOR=$m $POLYBAR secondary &
    else
      MONITOR=$m $POLYBAR tertiary &
      echo MONITOR=$m $POLYBAR tertiary &
    fi

    launchedBars=$(( $launchedBars + 1 ))
  done
else
  $POLYBAR primary 2>/tmp/polylog &
  $POLYBAR secondary &
  $POLYBAR tertiary  &
fi
