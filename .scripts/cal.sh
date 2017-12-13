#!/bin/bash

if pgrep -u $UID -x gsimplecal >/dev/null
then
    killall gsimplecal
else
    gsimplecal &
fi