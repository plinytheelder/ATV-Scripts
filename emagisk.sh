#!/bin/bash

device=$1
echo "$device"
echo "[$device] Connecting"
adb connect "$device"
adb -s "$device" push eMagisk/eMagisk-9.5.0.zip /data/local/tmp
adb -s "$device" push eMagisk/emagisk.config /data/local/tmp/
adb -s "$device" shell "su -c 'magisk --install-module /data/local/tmp/eMagisk-9.5.0.zip'"
adb -s "$device" reboot
