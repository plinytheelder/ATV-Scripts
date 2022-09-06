#!/bin/bash

device=$1
echo "$device"
echo "[$device] Connecting"
./adb connect "$device"
./adb -s "$device" push other/hostname.sh /data/local/tmp/
./adb -s "$device" shell "su -c 'mv /data/local/tmp/hostname.sh /data/adb/service.d/'"
./adb -s "$device" shell "su -c 'chmod +x /data/adb/service.d/hostname.sh'"
./adb -s "$device" reboot
