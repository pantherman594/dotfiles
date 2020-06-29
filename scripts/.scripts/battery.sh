#!/bin/bash

batBright=$(light -G)
acBright=$batBright

if [ -e ~/.brightness ]; then
    batBright=$(cat ~/.brightness | head -n1)
    acBright=$(cat ~/.brightness | tail -n1)

    light -S $batBright
fi

firstWarning=false
secondWarning=false
prev="Discharging"
delay=60

while true
do
    charge=$(acpi | cut -d' ' -f3)
    charge=${charge:0:-1}
    percent=$(acpi | cut -d' ' -f4)
    percent=${percent:0:-2}

    if [[ $charge == 'Discharging' ]]; then
        delay=60
        if [[ $percent -le 5 && $secondWarning == false ]]; then
            firstWarning=true
            secondWarning=true
            notify-send -u critical "Battery Critical" "$percent%, find a power source immediately"
        elif [[ $percent -le 12 && $firstWarning == false ]]; then
            firstWarning=true
            notify-send -u critical "Battery Low" "$percent%, find a power source soon"
        fi

        if [[ $prev != 'Discharging' ]]; then
            # killall -q picom
            acBright=$(light -G)
            light -S $batBright
        else
            batBright=$(light -G)
        fi
    else 
        delay=10
        firstWarning=false
        secondWarning=false

        if [[ $prev == 'Discharging' ]]; then
            # if ! pgrep -u $UID -x picom > /dev/null; then
            #     ~/.scripts/picom.sh &
            # fi

            batBright=$(light -G)
            light -S $acBright
        else
            acBright=$(light -G)
        fi
    fi

    echo $batBright > ~/.brightness
    echo $acBright >> ~/.brightness

    prev=$charge
    sleep $delay
done
