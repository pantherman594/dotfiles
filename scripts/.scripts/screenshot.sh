#!/bin/bash
file_path=/tmp/$( date '+%Y-%m-%d_%H-%M-%S' )_screenshot.png
scrot -m ${file_path}
i3-msg "workspace scr$(date +%s)"
pinta ${file_path}
i3-msg "workspace back_and_forth"
xclip -selection clipboard -target image/png -i < ${file_path}
rm ${file_path}
