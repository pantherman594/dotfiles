#!/bin/bash
icon=
last=""
show() {
    if [[ $last != $1 ]]
    then
        echo $1
        last=$1
    fi
}

while true
do
    if xrdb -query | grep -q "`cat ~/.config/polybar/caffine_on`"
    then
        show "%{F#EE6165}$icon"
    else
        show "%{F#FFFFFF}$icon"
    fi
    sleep 30 &
    echo ${!} > ~/.config/polybar/caff_pid
    wait ${!} 2>/dev/null
done
