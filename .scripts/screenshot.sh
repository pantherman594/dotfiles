#!/bin/bash
killall -q shutter
file_path=/tmp/$( date '+%Y-%m-%d_%H-%M-%S' )_screenshot.png
shutter --section -s -c -o ${file_path} -e -n
xclip -selection clipboard -target image/png -i < ${file_path}
rm ${file_path}
