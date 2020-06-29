#!/bin/bash
IFS=$'\n'

file_path=/tmp/screenshot.png

# save focused and visible workspaces
focused=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
visible_before=( $(i3-msg -t get_workspaces | jq -r '.[] | select(.visible==true).name') )

# take and edit the screenshot
scrot -pfo ${file_path}
gimp -ds -b "(let* ((giw (car (gimp-image-width 1))) (gih (car (gimp-image-height 1)))) (gimp-image-insert-layer 1 (car (gimp-layer-new 1 giw gih 1 \"Edits\" 100 28)) 0 0) )(gimp-image-clean-all 1)" ${file_path} &
i3-msg "workspace scr$(date +%s)"
wait

# restore previous workspaces
visible_after=( $(i3-msg -t get_workspaces | jq -r '.[] | select(.visible==true).name') )
for oldvis in ${visible_before[@]}
do
  echo ${oldvis}
  if [[ ! "${visible_after[@]}" =~ "${oldvis}" ]] && [ "${oldvis}" != "${focused}" ];
  then
    echo "switch"
    i3-msg "workspace ${oldvis}"
  fi
done
i3-msg "workspace ${focused}"

# copy to clipboard, clean up
xclip -selection clipboard -target image/png < ${file_path}
