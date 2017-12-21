#!/bin/bash

XRANDR=$(which xrandr)

MONITORS=( $( ${XRANDR} | awk '( $2 == "connected" ){ print $1 }' ) )
DIMENS_X=( $( ${XRANDR} | sed s/primary\ // | awk '( $2 == "connected" ){ print $3 }' | sed s/x.\*// ) )
DIMENS_Y=( $( ${XRANDR} | sed s/primary\ // | awk '( $2 == "connected" ){ print $3 }' | sed s/\+.\*// | sed s/.\*x// ) )


NUM_MONITORS=${#MONITORS[@]}

TITLES=()
COMMANDS=()


function gen_xrandr_only() {
    selected=$1

    cmd="xrandr --output ${MONITORS[$selected]} --auto "

    for entry in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $selected != $entry ]
        then
            cmd="$cmd --output ${MONITORS[$entry]} --off"
        fi
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
            DIFF=$(( (${DIMENS_Y[entry_a]}) - (${DIMENS_Y[entry_b]}) ))
            if [ $DIFF -lt 0 ]
            then
                DIFF=$(( -1 * DIFF ))
                POS_A="0x$DIFF"
                POS_B="${DIMENS_X[entry_a]}x0"
            else
                POS_A="0x0"
                POS_B="${DIMENS_X[entry_a]}x$DIFF"
            fi

            TILES[$index]="Dual Screen ${MONITORS[$entry_a]} -> ${MONITORS[$entry_b]}"
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --auto --pos $POS_A \
                              --output ${MONITORS[$entry_b]} --auto --pos $POS_B"
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
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --auto \
                              --output ${MONITORS[$entry_b]} --auto --same-as ${MONITORS[$entry_a]}"

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
SEL=$( gen_entries | rofi -dmenu -p "Monitor Setup:" -a 0 -no-custom  | awk '{print $1}' )

# Call xrandr
$( ${COMMANDS[$SEL]} )

NEW=$(xrandr)

if [[ "$PREV" != "$NEW" ]]
then
    i3-msg restart
fi