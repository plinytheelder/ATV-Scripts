#!/bin/bash

device=$1
echo "$device"
echo "[$device] Connecting"
./adb connect "$device"
./adb -s "$device" push downloads/safetynet_fix.zip /sdcard/
./adb -s "$device" push eMagiskTest/eMagisk-9.5.0.zip /data/local/tmp
./adb -s "$device" push eMagiskTest/emagisk.config /data/local/tmp/
./adb -s "$device" push hostname.sh /data/local/tmp/
./adb -s "$device" shell "su -c 'magisk --install-module /data/local/tmp/safetynet_fix.zip'"
./adb -s "$device" shell "su -c 'magisk --install-module /data/local/tmp/eM
./adb -s "$device" shell "su -c 'mv /data/local/tmp/hostname.sh /data/adb/service.d/'"
./adb -s "$device" shell "su -c 'chmod +x /data/adb/service.d/hostname.sh'"
./adb -s "$device" reboot
