#!/bin/bash

#SR=$(xrandr --query | grep ' connected primary' | grep -o '[0-9][0-9]*x[0-9][0-9]*[^ ]*')
# Array: width, height, x offset, y offset
#SRA=(${SR//[x+]/ })
#CX=$((${SRA[2]} + 25))
#CY=$((${SRA[1]} - 25 + ${SRA[3]}))

#rectangle="rectangle $CX,$CY $((CX+215)),$((CY-80))"

SCREEN=/tmp/screen.png
SIZE=$(xrandr | awk '($7 == "current" ){print $8"x"$10}' | sed s/,// )

#scrot $SCREEN && convert $SCREEN -scale 10% -scale 1000% -draw "fill black fill-opacity 0.5 $rectangle" $SCREEN
#ffmpeg -loglevel quiet -f x11grab -video_size $SIZE -y -i $DISPLAY -filter_complex "boxblur=10,eq=brightness=-0.15" -vframes 1 $SCREEN
ffmpeg -loglevel quiet -f x11grab -video_size $SIZE -y -i $DISPLAY -i ~/Pictures/overlay.png -filter_complex "[0:v]boxblur=5[base],[1:v]scale=180:80[ovrl],[base][ovrl]overlay=25:main_h-overlay_h-25" -vframes 1 $SCREEN
#convert $SCREEN -draw "fill black fill-opacity 0.5 $rectangle" $SCREEN

xset dpms force off

lock() {
    killall -SIGUSR1 dunst # Pause notifications
    i3lock \
        -n -e -i $SCREEN --screen=0 --indicator \
        --timepos="x+45:iy-87" --timestr="%H:%M"\
        --datepos="tx+cw-327:ty" \
        --time-align=1 --date-align=1 --layout-align=1 \
        --clock --force-clock --datestr="" \
        --insidecolor=00000000 --ringcolor=ffffffff --line-uses-inside \
        --keyhlcolor=0066a6ff --bshlcolor=d23c3dff --separatorcolor=00000000 \
        --insidevercolor=f2cf4dff --insidewrongcolor=d23c3dff \
        --timefont=Oxygen --datefont=Oxygen \
        --ringvercolor=ffffffff --ringwrongcolor=ffffffff --indpos="x+157:h+y-65" \
        --radius=20 --textsize=1 --modsize=8 --ring-width=3 --veriftext="" --wrongtext="" \
        --textcolor=ffffffff --timecolor=ffffffff --datecolor=ffffffff
    killall -SIGUSR2 dunst # Resume notifications
}
lock &

sleep 1
rm $SCREEN
