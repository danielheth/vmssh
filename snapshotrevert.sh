#!/bin/sh
#set -x
cd "$(dirname "$0")/../"

# Power on a VM
if [ $# -le 0 ]
then
  echo "USAGE: ./snapshotrevert.sh vm_name snapshot_name"
  exit 1
fi


want_vm=$1
want_ss=$2

all_vms=$(vim-cmd vmsvc/getallvms)
echo "$all_vms" | while read line
do
       ID=$(echo "$line" | awk '{print $1}')
       NAME=$(echo "$line" | awk '{print $2}')
       if [ "$NAME" = "$want_vm" ]
       then
               echo "we got what we wanted: ID: $ID NAME: $NAME"
               snapshots=$(vim-cmd vmsvc/snapshot.get "$ID")
               #echo "SNAPSHOTS: $snapshots"
               new=0
               echo "$snapshots" | while read ss
               do
                       #echo "$ss"
                       if echo "$ss" | egrep -q -- "-ROOT|-CHILD"
                       then
                               # we are in a new stanza
                               echo "in new stanza"
                               new=1
                       fi
                       if [ $new -eq 1 ]
                       then
                               if echo "$ss" | egrep -q "Snapshot Name"
                               then
                                       ss_name=$(echo "$ss" | awk '{ print substr($0,index($0,":")+2)}')
                                       #echo "SS_NAME: $ss_name"
                               fi
                       fi
                       if [ $new -eq 1 ]
                       then
                               if echo "$ss" | egrep -q "Snapshot Id"
                               then
                                       ss_id=$(echo "$ss" | awk '{print $4}')
                                       #echo "SS_NAME: ~$ss_name~ SS_ID: $ss_id want_ss ~$want_ss~ vmid $ID"
                                       new=0
                                       if [ "$want_ss" = "$ss_name" ]
                                       then
                                               echo "reverting snapshot $ss_name for vm $NAME......."
                                               vim-cmd vmsvc/snapshot.revert $ID $ss_id false
                                       fi
                               fi
                       fi
               done
       fi
done