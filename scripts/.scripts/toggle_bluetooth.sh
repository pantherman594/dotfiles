#!/bin/bash

if [[ $(rfkill list bluetooth -r | head -n2 | tail -n1 | cut -d' ' -f3) == "no" ]]
then
    sudo rfkill block bluetooth
else
    sudo rfkill unblock bluetooth
fi
kill "$(cat ~/.config/polybar/bluetooth.pid)"
