#!/bin/sh
#set -x

# Power on a VM
if [ $# -le 0 ]
then
  echo "USAGE: ./poweron.sh vm_name"
  exit 1
fi
readonly VMNAME=$1

VMID=$(vim-cmd vmsvc/getallvms | awk "/^[0-9]+ +$VMNAME /{print \$1}")
vim-cmd vmsvc/power.on $VMID
