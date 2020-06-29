#!/bin/bash
fails=0
icon=
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
  ping google.com -c 1 -w 3 2>/dev/null 1>&2
  if [ $? -eq 0 ]; then
    fails=0
    show ""
  else
    fails=$(( fails + 1 ))
    show "%{F#FF0000}$icon %{F#FFFFFF}$fails"
  fi
  sleep 5
done
