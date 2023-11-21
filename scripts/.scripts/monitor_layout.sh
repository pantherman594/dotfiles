#!/bin/bash

PRIMARY_MON="eDP-1"
SECONDARY_MON="DP-1-2"
TERTIARY_MON="DP-1-3"

PRIMARY="--output $PRIMARY_MON --mode 1920x1080 --scale 0.9999x0.9999 --auto --rotate normal"
SECONDARY="--output $SECONDARY_MON --mode 2560x1440 --rate 75 --scale 0.9999x0.9999 --auto --rotate normal"
TERTIARY="--output $TERTIARY_MON --mode 2560x1440 --scale 0.9999x0.9999 --auto --rotate normal"

# SURFACE_PRESET="xrandr --newmode \"2736x1824\"  426.00  2736 2952 3248 3760  1824 1827 1837 1890 -hsync +vsync && xrandr --addmode VIRTUAL1 2736x1824 && xrandr --output eDP1 --scale 1x1 --auto --pos 0x0 --output VIRTUAL1 --mode 2736x1824 --scale 0.5x0.5 --auto --pos 1920x0"
#SURFACE_PRESET="xrandr ${PRIMARY} --primary --pos 0x0 --output VIRTUAL1 --mode 2736x1824 --scale 0.5x0.5 --auto --pos 1920x0"
#SURFACE_PRESET="xrandr ${PRIMARY} --primary --pos 0x0 --output HDMI-2 --mode 1920x1080 --scale 0.9999x0.9999 --auto --pos 1920x0"
SINGLE_PRESET="xrandr ${PRIMARY} --primary --pos 0x0"
DUAL_PRESET="xrandr ${PRIMARY} --primary --pos 0x0 ${SECONDARY} --pos 1920x0"
# TRIPLE_PRESET="xrandr ${PRIMARY} --pos 0x0 ${SECONDARY} --pos 1920x0 ${TERTIARY} --pos 4480x0"
TRIPLE_PRESET="xrandr ${SECONDARY} --primary --pos 0x0 ${TERTIARY} --pos 2560x0 --output $PRIMARY_MON --off"

SINGLE_PRESET_MONS=$(printf "%s\n" $PRIMARY_MON)
DUAL_PRESET_MONS=$(printf "%s\n%s\n" $PRIMARY_MON $SECONDARY_MON)
TRIPLE_PRESET_MONS=$(printf "%s\n%s\n%s\n" $PRIMARY_MON $SECONDARY_MON $TERTIARY_MON)

XRANDR_OUT=$(xrandr)

MONITORS=( $( echo "${XRANDR_OUT}" | awk '( $2 == "connected" ){ print $1 }' ) )
INACTIVE_MONITORS=( $( echo "${XRANDR_OUT}" | awk '( $2 == "disconnected" ){ print $1 }' ) )
DIMENS_X=( $( echo "${XRANDR_OUT}" | sed s/primary\ // | awk '( $2 == "connected" ){ print $3 }' | sed s/x.\*// ) )
DIMENS_Y=( $( echo "${XRANDR_OUT}" | sed s/primary\ // | awk '( $2 == "connected" ){ print $3 }' | sed s/\+.\*// | sed s/.\*x// ) )

NUM_MONITORS=${#MONITORS[@]}
NUM_INACTIVE_MONITORS=${#INACTIVE_MONITORS[@]}


function test_preset() {
    if [ $NUM_MONITORS -lt $(echo "$1" | wc -l) ]; then
        return 1
    fi

    if [[ $(comm -13 <(printf "%s\n" "${MONITORS[@]}" | sort) <(echo "$1" | sort)) != "" ]]; then
        return 1
    fi

    return 0
}


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

##
#  Generate entries, where first is key.
##
function gen_entries() {
    for a in $(seq 0 $(( ${#TILES[@]} -1 )))
    do
        echo $a ${TILES[a]}
    done
}

function prompt_layout() {
  # Call menu
  SEL=$( gen_entries | rofi -i -matching fuzzy -dmenu -p "Monitor Setup" -a 0 -no-custom  | awk '{print $1}' )
  
  # Call xrandr
  echo ${COMMANDS[$SEL]}
}

function get_default() {
  echo ${COMMANDS[2]}
}

TITLES=()
COMMANDS=()

declare -i index=0
TILES[$index]="Cancel"
COMMANDS[$index]="true"
index+=1

TILES[$index]="GUI (arandr)"
COMMANDS[$index]="arandr"
index+=1

if test_preset "$TRIPLE_PRESET_MONS"
then
    TILES[$index]="Triple (Preset)"
    COMMANDS[$index]=${TRIPLE_PRESET}
    index+=1
fi

if test_preset "$DUAL_PRESET_MONS"
then
    TILES[$index]="Dual (Preset)"
    COMMANDS[$index]=${DUAL_PRESET}
    index+=1
fi

if test_preset "$SINGLE_PRESET_MONS"
then
    TILES[$index]="Single (Preset)"
    COMMANDS[$index]=${SINGLE_PRESET}
    index+=1
fi

for entry in $(seq 0 $((${NUM_MONITORS}-1)))
do
    TILES[$index]="Only ${MONITORS[$entry]}"
    COMMANDS[$index]=$(gen_xrandr_only $entry)
    index+=1
done

if [ $NUM_MONITORS -lt 3 ]
then
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
              COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --scale 0.9999x0.9999 --auto --pos $POS_A \
                                --output ${MONITORS[$entry_b]} --scale 0.9999x0.9999 --auto --pos $POS_B"
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
fi

#TILES[$index]="Surface (Preset)"
#COMMANDS[$index]=${SURFACE_PRESET}
#index+=1

  
  
PREV=$XRANDR_OUT

if [[ "$1" == "--auto" ]]; then
    COMMAND=$(get_default)
else
    COMMAND=$(prompt_layout)
fi

echo "$COMMAND"
bash -c "$COMMAND"

if [[ "$1" == "--auto" ]]; then
    ~/.scripts/remove_inactive_monitors.sh
else
    NEW=$(xrandr)

    if [[ "$PREV" != "$NEW" ]]
    then
        ~/.scripts/remove_inactive_monitors.sh
        bspc wm -r || i3-msg restart
    fi
fi
