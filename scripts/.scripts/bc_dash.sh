#!/bin/bash

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
    comp=true
    case $opt in
        $user)
            lpass show -c bc.edu --username
            ;;
        $pass)
            lpass show -c bc.edu --password
            ;;
        $connVPN)
            lpass show -c bc.edu --password
            nmcli con up "Eagle VPN" --ask
            ;;
        $discVPN)
            nmcli con down "Eagle VPN"
            ;;
        $uis)
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
