#!/bin/bash

if pgrep -x "duplicacy" > /dev/null
then
  echo "Duplicacy is already running, exiting."
  exit 0
fi

cd /

export XDG_RUNTIME_DIR="/run/user/1000"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

pass=$(gnome-keyring-query get "duplicacy/storage_password")

unset XDG_RUNTIME_DIR
unset DBUS_SESSION_BUS_ADDRESS

#pass=$(systemd-run --quiet --pipe --wait --user --machine pantherman594@.host -- /usr/bin/gnome-keyring-query get "duplicacy/storage_password")

export DUPLICACY_PASSWORD="$pass"
unset pass

# IMPORTANT: Update sudoers file with sudo visudo /etc/sudoers.d/duplicacy to match
# the below line if it is changed.
snapshots="$(sudo /usr/bin/duplicacy list)"

last_snapshot=$(date -d $(echo "$snapshots" | tail -n 1 | awk '{printf $(NF-1)"T"$NF}') +%s)
current_time=$(date +%s)
time_since_last_backup=$((current_time - last_snapshot))

# Take another backup if last backup was more than 6 hours ago.
if [ "$time_since_last_backup" -gt 21600 ]; then
  # IMPORTANT: Update sudoers file with sudo visudo /etc/sudoers.d/duplicacy to match
  # the below line if it is changed.
  sudo /usr/bin/duplicacy backup -threads 4
else
  echo "Last backup was less than 6 hours ago, exiting."
fi

unset DUPLICACY_PASSWORD
