#!/bin/bash

#SR=$(xrandr --query | grep ' connected primary' | grep -o '[0-9][0-9]*x[0-9][0-9]*[^ ]*')
# Array: width, height, x offset, y offset
#SRA=(${SR//[x+]/ })
#CX=$((${SRA[2]} + 25))
#CY=$((${SRA[1]} - 25 + ${SRA[3]}))

#rectangle="rectangle $CX,$CY $((CX+215)),$((CY-80))"

SCREEN=/tmp/screen.png
SIZE=$(xrandr | awk '($7 == "current" ){print $8"x"$10}' | sed s/,// )
HEIGHT=$(echo "$SIZE" | sed 's/^[0-9]\+x//')

#scrot $SCREEN && convert $SCREEN -scale 10% -scale 1000% -draw "fill black fill-opacity 0.5 $rectangle" $SCREEN
#ffmpeg -loglevel quiet -f x11grab -video_size $SIZE -y -i $DISPLAY -filter_complex "boxblur=10,eq=brightness=-0.15" -vframes 1 $SCREEN
ffmpeg -loglevel quiet -f x11grab -video_size $SIZE -y -i $DISPLAY -i ~/Pictures/overlay.png -filter_complex "[0:v]boxblur=25[base],[1:v]scale=180:80[ovrl],[base][ovrl]overlay=25:$HEIGHT-overlay_h-25" -vframes 1 $SCREEN
#convert $SCREEN -draw "fill black fill-opacity 0.5 $rectangle" $SCREEN

move() {
	run=true
    time_end=$(( $(date +%s) + 60 ))
	while $run; do
		pkill -0 -f "\-\-title=$1"
		successful=$?
		if (( successful != 0 )); then
			run=false
		else
			active_workspace=$( i3-msg -t get_workspaces | jq '.[] | select(.focused).name' )
			i3-msg "[title=^${1}$] move window to workspace $active_workspace"
			i3-msg "[title=^${1}$] floating enable" 
			i3-msg "[title=^${1}$] sticky enable" 
			i3-msg "[title=^${1}$] move position center" 
            sleep 0.25
		fi
        time_now=$(date +%s)
        if (( $time_now >= $time_end )); then
            run=false
            ~/.scripts/lock_actual.sh &
            exit
        fi
	done
}

lock() {
    killall -SIGUSR1 dunst # Pause notifications
    i3lock \
        -n -e -i $SCREEN --screen=1 --indicator \
        --time-pos="x+45:iy+11" --time-str="%H:%M"\
        --date-pos="tx+w-327:ty" \
        --time-align=1 --date-align=1 --layout-align=1 \
        --clock --force-clock --date-str="" \
        --inside-color=00000000 --ring-color=ffffffff --line-uses-inside \
        --keyhl-color=0066a6ff --bshl-color=d23c3dff --separator-color=00000000 \
        --insidever-color=f2cf4dff --insidewrong-color=d23c3dff \
        --time-font=Oxygen --date-font=Oxygen \
        --ringver-color=ffffffff --ringwrong-color=ffffffff --ind-pos="x+157:h+y-65" \
        --radius=20 --verif-size=1 --wrong-size=1 --ring-width=3 --verif-text="" --wrong-text="" \
        --verif-color=ffffffff --wrong-color=ffffffff --time-color=ffffffff --date-color=ffffffff
    killall -SIGUSR2 dunst # Resume notifications

    return

	# Post-login dialog box
	current=$BASHPID
	pgrep "lock_actual.sh" | grep -v "^${current}$" | xargs kill -9

	move Activities &
	OUTPUT=$(zenity --forms --title="Activities" --text="Activities" --add-entry="What do you plan to do?")
	accepted=$?
	if [[ $accepted != 0 || $OUTPUT == "" || $OUTPUT == "break" ]]; then
		move Break &
		OUTPUT=$(zenity --forms --title="Break" --text="Break" --add-entry="How long of a break (minutes)?")
		accepted=$?
		if [[ $accepted != 0 ]] || [[ ! $OUTPUT =~ ^[0-9]{1,2}$ ]] || (( OUTPUT > 30 )); then
			OUTPUT=0
		fi
		sleep $(( OUTPUT*60 ))
		~/.scripts/lock_actual.sh &
	fi
}

lock &

sleep 0.5
xset dpms force off
sleep 0.5
rm $SCREEN
