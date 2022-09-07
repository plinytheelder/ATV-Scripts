#!/bin/bash
while IFS== read device name;do
    adb connect $device
    type=$(adb -s $device shell uname -m)
        if [ "$type" = "aarch64" ]; then
                adb -s $i install -r -d ./apks/atlas.apk
                adb -s $i install -r -d ./apks/pogo64.apk
                adb -s $i shell 'am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService'
                echo "$name is done"
        else
                adb -s $i install -r -d ./apks/atlas.apk
                adb -s $i install -r -d ./apks/pogo32.apk
                adb -s $i shell 'am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService'
                echo "$name is done"
        fi
done <"DeviceNameIP.txt"
