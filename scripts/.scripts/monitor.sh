#!/bin/bash

# Automatically prompt monitor configure when plugged in

MONITORS=$(xrandr | grep -o "\bconnected" | wc -l)

function monitorsChanged {
    old=$MONITORS
    MONITORS=$(xrandr | grep -o "\bconnected" | wc -l)
    [[ "$old" != "$MONITORS" ]]
}

while true
do
    if monitorsChanged
    then
        ~/.scripts/monitor_layout.sh
    fi

    sleep 3s
done
