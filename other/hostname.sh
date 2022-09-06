#!/system/bin/sh
sleep 10
deviceName=$(cat /data/local/tmp/atlas_config.json | tr , '\n' | grep -w 'deviceName' | awk -F ":" '{ print $2 }' | tr -d \"})
su -c setprop net.hostname $deviceName
