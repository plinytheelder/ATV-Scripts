#! /bin/bash
readarray -d ' ' devices < <(cat DeviceNameIP.txt | cut -f1 -d'=' | tail -n +2 | xargs)
for device in "${devices[@]}"; do
    ./hostnamee.sh $device
done
