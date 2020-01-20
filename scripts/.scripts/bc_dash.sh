#!/bin/bash

itemId="ea7915ff-0eb6-449a-9011-3441f2f6062b"
unlock_bw () {
  if [ -z ${BW_SESSION+x} ]; then
    echo -n "Bitwarden Master Password: "
    read -s password
    echo
    sessionKey=$(bw unlock "$password" --raw)

    if [ "$sessionKey" == "" ]; then
      unlock_bw
    else
      export BW_SESSION=${sessionKey}
      echo
      echo Vault unlocked. To keep it unlocked, run:
      echo export BW_SESSION=\"${BW_SESSION}\"
      echo
      sessionKey=""
    fi
  fi
}

bw_get () {
  field=$1

  unlock_bw
  value=$(bw get $field $itemId)
  if [ "$value" == "Session key is invalid." ]; then
    unset BW_SESSION
    bw_get $1
  fi

  echo -n $value | xclip -sel clip
}

PS3='Select a task: '
connVPN="Connect to Eagle VPN"
discVPN="Disconnect from VPN"
uis="Launch UIS"
pass="Copy BC Password"
user="Copy BC Username"
quit="Quit"
options=("$user" "$pass" "$connVPN" "$discVPN" "$uis" "$quit")
select opt in "${options[@]}"
do
    echo
    comp=true
    case $opt in
        $user)
            bw_get username
            echo Username copied.
            ;;
        $pass)
            bw_get password
            echo Password copied.
            ;;
        $connVPN)
            bw_get password
            nmcli con up "Eagle VPN" --ask
            ;;
        $discVPN)
            nmcli con down "Eagle VPN"
            ;;
        $uis)
            bw_get password
            c3270 N:bcvmcms.bc.edu
            ;;
        $quit)
            break
            ;;
        *)
            echo "Invalid option $REPLY"
            comp=false
            ;;
    esac
    if $comp; then
        break
    fi
done
