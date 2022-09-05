#!/bin/bash

device=$1
IP=$(cat DeviceNameIP.txt | grep -w $device | cut -d '=' -f1)
adb connect "$IP"
adb -s "$IP" shell "su -c am force-stop com.nianticlabs.pokemongo & am force-stop com.pokemod.atlas"
adb -s "$IP" shell "am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService"
