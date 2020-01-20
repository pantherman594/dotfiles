#!/bin/bash

VM_ID="a63fa90d-b921-4333-8fa5-61aadc743ba2"
oldnum=$(cat ~/.systemsvm 2>/dev/null)
rawstate=$(VBoxManage showvminfo a63fa90d-b921-4333-8fa5-61aadc743ba2 | grep State | cut -d'(' -f1 | tail -c 7)

if [[ ${rawstate} == 'saved ' ]]; then
  VBoxManage startvm ${VM_ID} --type headless
  oldnum=0
fi

newnum=$(expr ${oldnum} + 1)
echo ${newnum} > ~/.systemsvm

echo Waiting...
sleep 3
echo Connecting...
ssh adminuser@192.168.56.102
while [[ $? == 255 ]]; do
  echo Could not connect. Trying again in 5 seconds...
  sleep 5
  echo Connecting...
  ssh adminuser@192.168.56.102
done

afternum=$(expr $(cat ~/.systemsvm) - 1)

if [[ ${afternum} -le 0 ]]; then
  VBoxManage controlvm ${VM_ID} savestate --type headless
  afternum=0
fi
echo ${afternum} > ~/.systemsvm
