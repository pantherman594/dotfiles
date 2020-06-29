#!/bin/bash

if [ -f /tmp/temp_quit ]; then bspc quit; fi

notify-send -u critical -t 10000 "Press super+shift+e again to quit bspwm"
touch /tmp/temp_quit
sleep 10
rm /tmp/temp_quit
