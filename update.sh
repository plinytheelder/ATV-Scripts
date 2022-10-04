#!/bin/bash
device=$1
    ./adb connect $device
    type=$(./adb -s $device shell uname -m)
        if [ "$type" = "aarch64" ]; then
                ./adb -s $device install -r -d ./apks/downloads/pogo64.apk
                ./adb -s $device shell 'am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService'
                echo "$device is done"
        else
                ./adb -s $device install -r -d ./apks/downloads/pogo32.apk
                ./adb -s $device shell 'am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService'
                echo "$device is done"
        fi
