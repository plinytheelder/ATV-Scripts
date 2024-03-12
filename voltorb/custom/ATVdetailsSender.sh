#!/system/bin/sh
# version 1.6

CONFIGFILE='/data/local/tmp/voltorb.config'
logfile='/data/local/tmp/voltorb.log'

#Configs
mitm_conf="/data/data/de.vahrmap.vmapper/shared_prefs/config.xml"

source $CONFIGFILE
export useSender atvdetails_interval atvdetails_receiver_host atvdetails_receiver_port

if [ "$useSender" != true ] ;then
    echo "`date +%Y-%m-%d_%T` ATVdetailsSender: sender stopped" >> $logfile && exit 1
fi

# generic
    RPL=$(($atvdetails_interval/60))
    deviceName=$(su -c cat $mitm_conf | grep "origin" | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }')
    arch=$(uname -m)
    productmodel=$(getprop ro.product.model)
    voltorbversion=$(cat "$MODDIR/version_lock")
    pogo=$(dumpsys package com.nianticlabs.pokemongo | grep versionName | head -n1 | sed 's/ *versionName=//')
    mitmversion=$(dumpsys package de.vahrmap.vmapper | grep versionName | head -n1 | sed 's/ *versionName=//')
    temperature=$(cat /sys/class/thermal/thermal_zone0/temp | cut -c -2)
    magisk=$(magisk -c | sed 's/:.*//')
    mace=$(ifconfig eth0 |grep 'HWaddr' |awk '{ print ($NF) }')
    ip=$(ifconfig wlan0 |grep 'inet addr' |cut -d ':' -f2 |cut -d ' ' -f1 && ifconfig eth0 |grep 'inet addr' |cut -d ':' -f2 |cut -d ' ' -f1)
    hostname=$(getprop net.hostname)
    playstore=$(dumpsys package com.android.vending | grep versionName | head -n 1 | cut -d "=" -f 2 | cut -d " " -f 1)
    proxyinfo=$(proxy=$(settings list global | grep "http_proxy=" | awk -F= '{ print $NF }'); [ -z "$proxy" ] || [ "$proxy" = ":0" ] && echo "none" || echo "$proxy")
# atv performance
# config
    workers=$(su -c cat $mitm_conf | grep "workers" | awk -F "\"" '{print tolower($4)}')
    rotomUrl=$(su -c cat $mitm_conf | grep "websocketurl" | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }')

#send data
    curl -k -X POST $atvdetails_receiver_host:$atvdetails_receiver_port/webhook -H "Accept: application/json" -H "Content-Type: application/json" --data-binary @- <<DATA
{
    "RPL": "${RPL}",
    "deviceName": "${deviceName}",
    "arch": "${arch}",
    "productmodel": "${productmodel}",
    "voltorbversion": "${voltorbversion}",
    "pogo": "${pogo}",
    "mitmversion": "${mitmversion}",
    "temperature": "${temperature}",
    "magisk": "${magisk}",
    "mace": "${mace}",
    "ip": "${ip}",
    "hostname": "${hostname}",
    "playstore": "${playstore}",
    "proxyinfo": "${proxyinfo}",
    "workers": "${workers}",
    "rotomUrl": "${rotomUrl}",
}

DATA
