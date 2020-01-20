#!/bin/bash

batBright=$(xbacklight -get)
acBright=$batBright

if [ -e ~/.brightness ]; then
    batBright=$(cat ~/.brightness | head -n1)
    acBright=$(cat ~/.brightness | tail -n1)

    xbacklight -d :0 -set $batBright -time 250
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
            killall -q compton
            acBright=$(xbacklight -get)
            xbacklight -d :0 -set $batBright -time 250
        else
            batBright=$(xbacklight -get)
        fi
    else 
        delay=10
        firstWarning=false
        secondWarning=false

        if [[ $prev == 'Discharging' ]]; then
            if ! pgrep -u $UID -x compton > /dev/null; then
                ~/.scripts/compton.sh &
            fi

            batBright=$(xbacklight -get)
            xbacklight -d :0 -set $acBright -time 250
        else
            acBright=$(xbacklight -get)
        fi
    fi

    echo $batBright > ~/.brightness
    echo $acBright >> ~/.brightness

    prev=$charge
    sleep $delay
done
