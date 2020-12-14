#!/bin/bash

if [[ $(rfkill list wlan -r | head -n2 | tail -n1 | cut -d' ' -f3) == "no" ]]
then
    sudo rfkill block wlan
else
    sudo rfkill unblock wlan
fi
