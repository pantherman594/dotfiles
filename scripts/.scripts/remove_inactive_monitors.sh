#!/bin/bash

OLDIFS=$IFS
IFS=$'\n'

active_monitors=$(bspc query -M --names)
connected=$(xrandr --listactivemonitors | tail -n+2 | awk -F ' ' '{print $NF}')

comm_result=$(comm --output-delimiter='>' <(echo "${active_monitors[@]}" | sort) <(echo "${connected[@]}" | sort))

to_remove=($(echo "$comm_result" | perl -nE 'print "$_" unless /^>/'))
to_add=($(echo "$comm_result" | perl -nE 'print "$1\n" if /^>([^>].*)$/'))
to_setgeo=($(echo "$comm_result" | perl -nE 'print "$1\n" if /^>>(.+)$/'))

dest=$(echo "$connected" | head -n 1)

#printf "To remove:\n%s\n\n" "${to_remove[@]}"
#printf "To add:\n%s\n\n" "${to_add[@]}"
#printf "Destination:\n%s\n" "$dest"
#exit

for monitor in ${to_add[@]}; do
  echo "Add $monitor"
  dim=$(xrandr | grep $monitor | perl -n -e'/(\d+x\d+\+\d+\+\d+)/ && print $1')

  bspc wm -a $monitor $dim
  bspc monitor -f $monitor

  bspc monitor $monitor -a 11
  n=$(bspc query -D -m $monitor | wc -l)
  d=$(bspc query -M -m $monitor):^${n}
  bspc desktop -f $d
done

for monitor in ${to_setgeo[@]}; do
  dim=$(xrandr | grep $monitor | perl -n -e'/(\d+x\d+\+\d+\+\d+)/ && print $1')

  bspc monitor $monitor -g $dim
done

for monitor in ${to_remove[@]}; do
  echo $monitor
  bspc monitor -f $monitor

  # list desktops
  desks=($(bspc query -D -m $monitor))

  bspc monitor -a 11

  for desk in ${desks[@]}; do
    name=$(bspc query -D -d $desk --names)
    echo "$name ($desk) -> $dest"
    bspc desktop $desk -n "_$name"
    bspc monitor $dest -a "$name"
    bspc desktop -f $name
    bspc desktop $desk -m $dest
    bspc desktop $desk -n "$name"
    bspc desktop -f $desk
  done

  bspc monitor $monitor -r
done

bspc monitor -f $dest

IFS=$OLDIFS

~/.scripts/sort_desktops.sh
