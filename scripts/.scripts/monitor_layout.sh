#!/bin/bash

SURFACE_PRESET="xrandr --output eDP1 --scale 1x1 --auto --pos 0x0 --output VIRTUAL1 --scale 0.5x0.5 --auto --pos 1920x0"
DUAL_PRESET="xrandr --output eDP1 --scale 1x1 --auto --pos 0x1080 --output DP2-1 --scale 1x1 --auto --pos 0x0"
TRIPLE_PRESET="${DUAL_PRESET} && xrandr --output eDP1 --scale 1x1 --auto --pos 0x1080 --output DP2-1 --scale 1x1 --auto --pos 0x0 --output DP2-2 --scale 1.2x1.2 --auto --pos 1920x432 --rotate left"

XRANDR=$(which xrandr)

MONITORS=( $( ${XRANDR} | awk '( $2 == "connected" ){ print $1 }' ) )
INACTIVE_MONITORS=( $( ${XRANDR} | awk '( $2 == "disconnected" ){ print $1 }' ) )
DIMENS_X=( $( ${XRANDR} | sed s/primary\ // | awk '( $2 == "connected" ){ print $3 }' | sed s/x.\*// ) )
DIMENS_Y=( $( ${XRANDR} | sed s/primary\ // | awk '( $2 == "connected" ){ print $3 }' | sed s/\+.\*// | sed s/.\*x// ) )

NUM_MONITORS=${#MONITORS[@]}
NUM_INACTIVE_MONITORS=${#INACTIVE_MONITORS[@]}

TITLES=()
COMMANDS=()


function gen_xrandr_only() {
    selected=$1

    cmd="xrandr --output ${MONITORS[$selected]} --auto --scale 1x1 --pos 0x0"

    for entry in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $selected != $entry ]
        then
            cmd="$cmd --output ${MONITORS[$entry]} --off"
        fi
    done

    for entry in $(seq 0 $((${NUM_INACTIVE_MONITORS}-1)))
    do
        cmd="$cmd --output ${INACTIVE_MONITORS[$entry]} --off"
    done

    echo $cmd
}



declare -i index=0
TILES[$index]="Cancel"
COMMANDS[$index]="true"
index+=1

TILES[$index]="GUI (arandr)"
COMMANDS[$index]="arandr"
index+=1

if [ $NUM_MONITORS -ge 3 ]
then
    TILES[$index]="Triple (Preset)"
    COMMANDS[$index]=${TRIPLE_PRESET}
    index+=1
fi

if [ $NUM_MONITORS -ge 2 ]
then
    TILES[$index]="Dual Vertical (Preset)"
    COMMANDS[$index]=${DUAL_PRESET}
    index+=1

    TILES[$index]="Surface (Preset)"
    COMMANDS[$index]=${SURFACE_PRESET}
    index+=1
fi


for entry in $(seq 0 $((${NUM_MONITORS}-1)))
do
    TILES[$index]="Only ${MONITORS[$entry]}"
    COMMANDS[$index]=$(gen_xrandr_only $entry)
    index+=1
done

##
# Dual screen options
##
for entry_a in $(seq 0 $((${NUM_MONITORS}-1)))
do
    for entry_b in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $entry_a != $entry_b ]
        then
              POS_A="0x0"
              POS_B="${DIMENS_X[entry_a]}x0"

            TILES[$index]="Dual Screen ${MONITORS[$entry_a]} -> ${MONITORS[$entry_b]}"
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --scale 1x1 --auto --pos $POS_A \
                              --output ${MONITORS[$entry_b]} --scale 1x1 --auto --pos $POS_B"
            echo ${COMMANDS[$index]}

            index+=1
        fi
    done
done


##
# Clone monitors
##
for entry_a in $(seq 0 $((${NUM_MONITORS}-1)))
do
    for entry_b in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $entry_a != $entry_b ]
        then
            TILES[$index]="Clone Screen ${MONITORS[$entry_a]} -> ${MONITORS[$entry_b]}"
            #COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --auto; xrandr --output ${MONITORS[$entry_b]} --auto --same-as ${MONITORS[$entry_a]}"
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_b]} --auto --same-as ${MONITORS[$entry_a]}"

            index+=1
        fi
    done
done


##
#  Generate entries, where first is key.
##
function gen_entries() {
    for a in $(seq 0 $(( ${#TILES[@]} -1 )))
    do
        echo $a ${TILES[a]}
    done
}

PREV=$(xrandr)

# Call menu
SEL=$( gen_entries | rofi -i -matching fuzzy -dmenu -p "Monitor Setup" -a 0 -no-custom  | awk '{print $1}' )

# Call xrandr
echo ${COMMANDS[$SEL]}
bash -c "${COMMANDS[$SEL]}"

NEW=$(xrandr)

if [[ "$PREV" != "$NEW" ]]
then
    i3-msg restart
fi
