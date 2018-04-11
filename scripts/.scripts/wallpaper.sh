#!/bin/bash

cd /usr/share/backgrounds/pantherman594
wget $(/home/pantherman594/.scripts/wallpaper.py) -O ./wallpaper.jpg
wal -i ./wallpaper.jpg -c -n
feh --bg-fill --no-xinerama ./wallpaper.jpg
