#!/system/bin/sh
sleep 10
if [[ -f /data/local/tmp/atlas_config.json ]] ;then
    deviceName=$(cat /data/local/tmp/atlas_config.json | tr , '\n' | egrep -w 'deviceName' | awk -F ":" '{ print $2 }' | tr -d \"})
elif [[ -f /data/local/tmp/config.json ]] ;then
    deviceName=$(cat /data/local/tmp/config.json | tr , '\n' | egrep -w 'device_name' | awk -F ":" '{ print $2 }' | tr -d \"})
else exit 0
fi
su -c setprop net.hostname $deviceName
