#!/bin/bash

ROFI_FIND_HISTORY_FILE=~/.local/share/rofi/rofi_find_history
ROFI_FIND_HISTORY_MAXCOUNT=30 # maximum number of history entries

# Create the directory for the files of the script
if [ ! -d $(dirname "${ROFI_FIND_HISTORY_FILE}") ]
then
  mkdir -p "$(dirname "${ROFI_FIND_HISTORY_FILE}")"
fi

if [ ! -z "$@" ]
then
  QUERY=$@
  if [[ "$QUERY" == "Clear" ]]
  then
    echo " "
  elif [[ "$QUERY" == \?* ]]
  then
    same_lines=($(grep -nF "${QUERY}" ${ROFI_FIND_HISTORY_FILE} | cut -d':' -f1))
    for ((i=${#same_lines[@]} - 1; i >= 0; i--))
    do
      sed -i "${same_lines[$i]}d" ${ROFI_FIND_HISTORY_FILE}
    done

    echo -e "${QUERY}\n$(cat ${ROFI_FIND_HISTORY_FILE})" > ${ROFI_FIND_HISTORY_FILE}
    if [ $( wc -l < "${ROFI_FIND_HISTORY_FILE}" ) -gt ${ROFI_FIND_HISTORY_MAXCOUNT} ]
    then
        echo "$(head -n ${ROFI_FIND_HISTORY_MAXCOUNT} ${ROFI_FIND_HISTORY_FILE})" > ${ROFI_FIND_HISTORY_FILE}
    fi
    plocate -i -l 1000 ${QUERY:1}
  elif [[ "$QUERY" == /* ]]
  then
    if [[ "$QUERY" == *\?\? ]]
    then
      coproc ( exo-open "${QUERY%\/* \?\?}"  > /dev/null 2>&1 )
      exec 1>&-
      exit;
    else
      coproc ( exo-open "$@"  > /dev/null 2>&1 )
      exec 1>&-
      exit;
    fi
  else
    return
  fi
else
  echo Clear
  cat ${ROFI_FIND_HISTORY_FILE}
fi
