#!/bin/bash

firstWarning=false
secondWarning=false
while true
do
    charge=$(acpi | cut -d' ' -f3)
    charge=${charge:0:-1}
    percent=$(acpi | cut -d' ' -f4)
    percent=${percent:0:-2}
    if [[ $charge == 'Charging' || $charge == 'Full' ]]; then
        firstWarning=false
        secondWarning=false
    else
        if [[ $percent -le 5 && $secondWarning == false ]]; then
            firstWarning=true
            secondWarning=true
            notify-send -u critical "Battery Critical" "$percent%, find a power source immediately"
        elif [[ $percent -le 12 && $firstWarning == false ]]; then
            firstWarning=true
            notify-send -u critical "Battery Low" "$percent%, find a power source soon"
        fi
    fi
    sleep 10
done
