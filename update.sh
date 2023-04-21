#!/bin/bash
device=$1
version=$2
    ./adb connect $device
    type=$(./adb -s $device shell uname -m)
    versioninfo=$(./adb -s $device shell dumpsys package com.nianticlabs.pokemongo | grep versionName | head -n1 | sed 's/ *versionName=//')
        if [ "$version" = "$versioninfo" ]; then
                ./adb disconnect $device
        elif [ "$type" = "aarch64" ]; then
                ./adb -s $device install -r -d ./apks/downloads/pogo64.apk
                ./adb -s $device shell 'am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService'
                echo "$device is done"
        else
                ./adb -s $device install -r -d ./apks/downloads/pogo32.apk
                ./adb -s $device shell 'am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService'
                echo "$device is done"
        fi
