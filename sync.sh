#!/bin/bash

hash dialog 2>/dev/null || { echo >&2 "I require dialog but it's not installed.  Aborting."; exit 1; }
hash stow 2>/dev/null || { echo >&2 "I require stow but it's not installed.  Aborting."; exit 1; }

FILES=""

for dir in `ls -d */`
do
	FILES="$FILES ${dir%%/} | on "
done
echo $FILES

CONFIGS=`dialog --stdout --checklist "Select configurations to install" 14 48 14 $FILES`

if test $? -eq 0
then
	clear
	stow $CONFIGS -t ~
	echo Configuration installation completed
else
	clear
	echo Configuration installation cancelled
fi
