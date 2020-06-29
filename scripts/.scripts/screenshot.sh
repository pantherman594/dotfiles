#!/bin/bash
IFS=$'\n'

file_path=/tmp/screenshot.png

# save focused and visible desktops
focused=$(bspc query -D -d)
visible_before=( $(bspc query -D -d .active) )

# take and edit the screenshot
scrot -pfo ${file_path}
gimp -ds -b "(let* ((giw (car (gimp-image-width 1))) (gih (car (gimp-image-height 1)))) (gimp-image-insert-layer 1 (car (gimp-layer-new 1 giw gih 1 \"Edits\" 100 28)) 0 0) )(gimp-image-clean-all 1)" ${file_path} &
name="scr$(date +%s)"
bspc monitor -a $name
bspc desktop $name -f
wait

# restore previous workspaces
visible_after=( $(bspc query -D -d .active) )
for oldvis in ${visible_before[@]}
do
  if [[ ! "${visible_after[@]}" =~ "${oldvis}" ]] && [ "${oldvis}" != "${focused}" ];
  then
    bspc desktop $oldvis -f
  fi
done
bspc desktop $focused -f

# copy to clipboard, clean up
xclip -selection clipboard -target image/png < ${file_path}
