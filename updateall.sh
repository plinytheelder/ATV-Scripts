#!/bin/bash
versioninput=$1
readarray -d ' ' devices < <(cat DeviceNameIP.txt | cut -f1 -d'=' | tail -n +2 | xargs)
for device in "${devices[@]}"; do
    ./update.sh $device $versioninput
done
