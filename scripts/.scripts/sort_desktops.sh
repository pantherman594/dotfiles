#!/bin/bash

mon=$(bspc query -M -m)
desks=($(bspc query -D -m --names))
len=${#desks[@]}

swaps () {
  changed=1
  for (( i=0; i<$((len-1)); i++ )); do
    i1=$((i+1))
    if [ ${desks[$i]} -gt ${desks[$i1]} ]; then
      bspc desktop $mon:^$i1 -b next
      echo bspc desktop ${desks[$i]} -s ${desks[$i1]}
      temp=${desks[$i]}
      desks[$i]=${desks[$i1]}
      desks[$i1]=$temp
      changed=0
    fi
  done
  return $changed
}

while swaps; do :; done
