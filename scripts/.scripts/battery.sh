#!/bin/bash

firstWarning=false
secondWarning=false
while true
do
    charge=$(acpi | cut -d' ' -f3)
    charge=${charge:0:-1}
    percent=$(acpi | cut -d' ' -f4)
    percent=${percent:0:-2}
    if [[ $charge == 'Charging' ]]; then
        firstWarning=false
        secondWarning=false
    else
        if [[ $percent -le 5 && $secondWarning == false ]]; then
            firstWarning=true
            secondWarning=true
            zenity --warning --text "Battery Critical: $percent%, find a power source immediately" --no-wrap
        elif [[ $percent -le 12 && $firstWarning == false ]]; then
            firstWarning=true
            zenity --warning --text "Battery Low: $percent%, find a power source soon" --no-wrap
        fi
    fi
    sleep 10
done
