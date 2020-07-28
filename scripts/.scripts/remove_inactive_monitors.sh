#!/bin/bash

active_monitors=($(bspc query -M --names))
connected=($(xrandr | grep -E "[^s]connected\s+(primary)?\s+[0-9]" | cut -d' ' -f1))

to_remove=($(echo ${active_monitors[@]} ${connected[@]} ${connected[@]} | tr ' ' '\n' | sort | uniq -u))

dest=${connected[0]}

for monitor in ${to_remove[@]}; do
  bspc monitor -f $monitor

  # list desktops
  desks=($(bspc query -D -m $monitor))

  bspc monitor -a 11

  for desk in ${desks[@]}; do
    bspc desktop $desk -m $dest
  done

  bspc monitor $monitor -r
done

to_add=($(echo ${connected[@]} ${active_monitors[@]} ${active_monitors[@]} | tr ' ' '\n' | sort | uniq -u))
for monitor in ${to_remove[@]}; do
  dim=$(xrandr | grep $monitor | perl -n -e'/(\d+x\d+\+\d+\+\d+)/ && print $1')

  bspc wm -a $monitor $dim
  bspc monitor -f $monitor

  bspc monitor -a 11
  n=$(bspc query -D -m | wc -l)
  d=$(bspc query -M -m):^${n}
  bspc desktop -f $d
done

bspc monitor -f $dest
~/.scripts/sort_desktops.sh
