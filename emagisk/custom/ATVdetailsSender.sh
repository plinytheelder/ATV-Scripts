#!/system/bin/sh
# version 1.6

CONFIGFILE='/data/local/tmp/emagisk.config'
logfile='/data/local/tmp/emagisk.log'
reboottype=$1

#Configs
mitm_conf="/data/local/tmp/config.json"

source $CONFIGFILE
export useSender atvdetails_interval atvdetails_receiver_host atvdetails_receiver_port

# initial sleep for reboot
sleep 120

while true
  do
    if [ "$useSender" != true ] ;then
      echo "`date +%Y-%m-%d_%T` ATVdetailsSender: sender stopped" >> $logfile && exit 1
    fi

# generic
    RPL=$(($atvdetails_interval/60))
    deviceName=$(cat $mitm_conf | tr , '\n' | grep -w 'device_name' | awk -F ":" '{ print $2 }' | tr -d \"})
    arch=$(uname -m)
    productmodel=$(getprop ro.product.model)
    pogo=$(dumpsys package com.nianticlabs.pokemongo | grep versionName | head -n1 | sed 's/ *versionName=//')
    mitmversion=$(dumpsys package com.gocheats.launcher | grep versionName | head -n1 | sed 's/ *versionName=//')
    temperature=$(cat /sys/class/thermal/thermal_zone0/temp | cut -c -2)
    magisk=$(magisk -c | sed 's/:.*//')
    mace=$(ifconfig eth0 |grep 'HWaddr' |awk '{ print ($NF) }')
    ip=$(ifconfig wlan0 |grep 'inet addr' |cut -d ':' -f2 |cut -d ' ' -f1 && ifconfig eth0 |grep 'inet addr' |cut -d ':' -f2 |cut -d ' ' -f1)
    hostname=$(getprop net.hostname)
    playstore=$(dumpsys package com.android.vending | grep versionName | head -n 1 | cut -d "=" -f 2 | cut -d " " -f 1)
    proxyinfo=$(proxy=$(settings list global | grep "http_proxy=" | awk -F= '{ print $NF }'); [ -z "$proxy" ] || [ "$proxy" = ":0" ] && echo "none" || echo "$proxy")
# atv performance
# config
    token=$(cat $mitm_conf | tr , '\n' | grep -w 'api_key' | awk -F ":" '{ print $2 }' | tr -d \"})
    workers=$(cat $mitm_conf | tr , '\n' | grep -w 'workers_count' | awk -F ":" '{ print $2 }' | tr -d \"})
    rotomUrl=$(cat $mitm_conf | tr , '\n' | grep -w 'rotom_url' | awk -F "\"" '{ print $4 }')

#send data
    curl -k -X POST $atvdetails_receiver_host:$atvdetails_receiver_port/webhook -H "Accept: application/json" -H "Content-Type: application/json" --data-binary @- <<DATA
{
    "RPL": "${RPL}",
    "deviceName": "${deviceName}",
    "arch": "${arch}",
    "productmodel": "${productmodel}",
    "pogo": "${pogo}",
    "mitmversion": "${mitmversion}",
    "temperature": "${temperature}",
    "magisk": "${magisk}",
    "mace": "${mace}",
    "ip": "${ip}",
    "hostname": "${hostname}",
    "playstore": "${playstore}",
    "proxyinfo": "${proxyinfo}",
    "reboot": "${reboottype}",
    "token": "${token}",
    "workers": "${workers}",
    "rotomUrl": "${rotomUrl}"
}

DATA

    sleep $atvdetails_interval
  done;
