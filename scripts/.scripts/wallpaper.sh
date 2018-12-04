#!/bin/bash

cd /usr/share/backgrounds/pantherman594
wget $(/home/pantherman594/.scripts/wallpaper.py) -O ./wallpaper.jpg
wal -i ./wallpaper.jpg -c -n -e
feh --bg-fill --no-xinerama ./wallpaper.jpg

cd /home/pantherman594/.cache/wal
color=$(head colors -n 2 | tail -n 1)
color="#df${color:1}"
echo '[colors]' > poly
echo "barbg = ${color}" >> poly

cd -
wal -i ./wallpaper.jpg -n
