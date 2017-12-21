#!/bin/bash

# Automatically configure monitors when plugged in

# default monitor is LVDS1
MONITOR=LVDS1+VGA1

# functions to switch from LVDS1 to LVDS1+VGA and vice versa
function ActivateVGA {
    echo "Switching to LVDS1+VGA1"
    xrandr --output LVDS1 --primary --mode 1366x768 --pos 0x132 --rotate normal --output DP1 --off --output HDMI1 --off --output VGA1 --mode 1440x900 --pos 1366x0 --rotate normal
    MONITOR=LVDS1+VGA1
}
function DeactivateVGA {
    echo "Switching to LVDS1"
    xrandr --output LVDS1 --primary --mode 1366x768 --pos 0x0 --rotate normal --output DP1 --off --output HDMI1 --off --output VGA1 --off
    MONITOR=LVDS1
}

# functions to check if VGA is connected and in use
function VGAActive {
    [ $MONITOR = "LVDS1+VGA1" ]
}
function VGAConnected {
    ! xrandr | grep "^VGA1" | grep disconnected
}

# actual script
while true
do
    if ! VGAActive && VGAConnected
    then
        ActivateVGA
        sleep 1s
        ~/.scripts/polybar.sh
    fi

    if VGAActive && ! VGAConnected
    then
        DeactivateVGA
        sleep 1s
        ~/.scripts/polybar.sh
    fi

    sleep 3s
done
