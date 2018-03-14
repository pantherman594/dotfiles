#!/bin/bash

ID=$(ps aux | grep WeatherDesk | grep .py | awk '( $11 == "python3" ){ print $2 }')

if [[ $ID ]]
then
    kill $ID
fi

python3 ~/Documents/Programming/WeatherDesk/WeatherDesk.py -t 4
