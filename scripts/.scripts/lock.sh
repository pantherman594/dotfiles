#!/bin/bash

if xrdb -query | grep -q "`cat ~/.config/polybar/caffine_off`"
then
    xset dpms force off
    sleep 30
    if xset q | grep -q 'Monitor is Off'
    then
        ~/.scripts/lock_actual.sh
    fi
fi
