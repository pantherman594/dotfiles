#!/bin/bash

if [[ $(/usr/bin/virsh --connect qemu:///system domstate $1) != 'running' ]]; then
  /usr/bin/virsh --connect qemu:///system start $1
fi

/usr/bin/virt-manager --connect qemu:///system --show-domain-console $1
