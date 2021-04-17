#!/bin/bash

START='\.\/'
NUM='[0-9][0-9]'

titles=()
paths=()

IFS=$'\n'
cd /data

areas=($(find . -maxdepth 1 -regex "$START$NUM-$NUM .+"))
for area in ${areas[@]}; do
  titles+=(${area:2})
  paths+=("/data/${area:2}")
  cd "$area"

  categories=($(find . -maxdepth 1 -regex "$START$NUM .+"))
  for category in ${categories[@]}; do
    titles+=(${category:2})
    paths+=("/data/${area:2}/${category:2}")
    cd "$category"

    ids=($(find . -maxdepth 1 -regex "$START$NUM\.$NUM .+"))
    for i in ${ids[@]}; do
      titles+=(${i:2})
      paths+=("/data/${area:2}/${category:2}/${i:2}")
      cd "$i"

      subs=($(find . -maxdepth 1 -regex "$START$NUM\.${NUM}_$NUM .+"))
      for sub in ${subs[@]}; do
        titles+=(${sub:2})
        paths+=("/data/${area:2}/${category:2}/${i:2}/${sub:2}")
      done

      cd ..
    done

    cd ..
  done

  cd ..
done

function gen_entries() {
  for line in ${titles[@]}; do
    echo $line
  done
}

sel=$(gen_entries | rofi -i -matching normal -disable-history -no-sort -columns 2 -line-padding 5 -lines 10 -dmenu -p "Goto" -a 0 -no-custom -format 'i')
if [ -z "$sel" ]; then
  exit 0
fi
urxvt -cd ${paths[sel]} &
