#!/bin/bash

CAFF_ON=~/.config/polybar/caffine_on
CAFF_OFF=~/.config/polybar/caffine_off

if xrdb -query | grep -q "`cat $CAFF_ON`"
then
    xrdb -override $CAFF_OFF
else
    xrdb -override $CAFF_ON
fi
