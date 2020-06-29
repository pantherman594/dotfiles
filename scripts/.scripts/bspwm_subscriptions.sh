#!/bin/bash

declare -A last_focused

get_name () {
  bspc query -D -d ${1} --names
}

desktop_has_nodes () {
  bspc query -N -d ${1}
}

desktop_is_open () {
  bspc query -D -d ${1}.active
}

should_remove_desktop () {
  if ! desktop_is_open $1 && ! desktop_has_nodes $1; then
    return 0
  else
    return 1
  fi
}


bspc subscribe desktop_focus node_remove node_transfer | while read -a msg ; do
  monitor_id=${msg[1]}
  desktop_id=${msg[2]}
  if [ ${msg[0]} == "desktop_focus" ]; then
    desktop_id=${last_focused[$monitor_id]}
    last_focused[$monitor_id]=${msg[2]}
  fi
  if should_remove_desktop $desktop_id; then
    echo "removing $(get_name $desktop_id)"
    bspc desktop $desktop_id -r
  fi
done
