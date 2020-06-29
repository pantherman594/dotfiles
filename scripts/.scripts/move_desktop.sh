#!/bin/bash
v() {
  if [ $SIDE = 1 ]; then
    return 1
  else
    return 0
  fi
}
mov() {
  case $1 in
    0) v && echo "2" || echo "1";;
    1) v && echo "2" || echo "1";;
    2) v && echo "3" || echo "3";;
  esac
}
active=$(bspc query -M -m .focused)
mon=($(bspc query -M))
for i in ${!mon[@]}; do
  echo $i
  if [ ${mon[$i]} = $active ]; then
    move_to=$(mov $i)
    echo "move to $move_to"
    break
  fi
done
active_desk=$(bspc query -D -d .focused --names)
bspc node -f @/
# bspc node -d ^${move_to}:^${active_desk}
