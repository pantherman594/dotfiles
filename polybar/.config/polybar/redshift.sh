#!/bin/bash
icon=
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
    if pgrep -x "redshift" > /dev/null
    then
        show "%{F#EE6165}$icon"
    else
        show "%{F#FFFFFF}$icon"
    fi
done
