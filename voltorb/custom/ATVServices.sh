#!/system/bin/sh

# Base stuff we need

POGOPKG=com.nianticlabs.pokemongo
CONFIGFILE='/data/local/tmp/voltorb.config'

source $CONFIGFILE
export mitm monitoringenable authlimit atvdetails_receiver_host atvdetails_receiver_port atvdetails_interval

# Check mitm on this device

check_mitm() {    
    if [ "$(pm list packages de.vahrmap.vmapper)" = "package:de.vahrmap.vmapper" ]; then
        log "Found VMapper production version!"
        VMPKG=de.vahrmap.vmapper
    elif [ "$(pm list packages com.gocheats.launcher)" = "package:com.gocheats.launcher" ]; then
        log "Found GoCheats production version!"
        GOCHEATSPKG=com.gocheats.launcher
    else
        log "No MITM installed."
    fi
}

# Stops MITM and Pogo and restarts MITM MappingService

force_restart() {
    if [ "$mitm" = "vmapper" ];then
        am force-stop $POGOPKG
        am force-stop $VMPKG
        sleep 5
        am broadcast -n $VMPKG/.RestartService
		sleep 5
		monkey -p $POGOPKG -c android.intent.category.LAUNCHER 1
    elif [ "$mitm" = "gc" ];then
        am force-stop $GOCHEATSPKG
        sleep 5
        monkey -p $GOCHEATSPKG 1
    fi
    log "Services were restarted!"
}

mitm_root() {
    packageUID=$(dumpsys package "$VMPKG" | grep userId | head -n1 | cut -d= -f2)
    policy=$(magisk --sqlite "select policy from policies where uid='$packageUID'" | cut -d= -f2)
    if [ "$policy" != 2 ]; then
        log "$package current policy is not root. Adding root permissions..."
        if ! magisk --sqlite "REPLACE INTO policies (uid,policy,until,logging,notification) VALUES($packageUID,2,0,1,1)"; then
            log "ERROR: Could not add $VMPKG (UID: $packageUID) to Magisk's DB."
        fi
    else
        log "Root permissions for $VMPKG are OK!"
    fi
}


if [ "$setHostname" = true -a "$mitm" = "vmapper" ] ;then
        DeviceName=$(cat /data/data/de.vahrmap.vmapper/shared_prefs/config.xml | grep "origin" | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }')
        setprop net.hostname $DeviceName
        log "Set hostname to $DeviceName" 
elif [ "$setHostname" = true -a "$mitm" = "gc" ] ;then  
        DeviceName=$(cat /data/local/tmp/config.json | tr , '\n' | grep -w 'device_name' | awk -F ":" '{ print $2 }' | tr -d \"})
        setprop net.hostname $DeviceName
        log "Set hostname to $DeviceName"
fi

# Adjust the script depending on Atlas or GC

check_mitm

# Enable playstore

if [ "$(pm list packages -d com.android.vending)" = "package:com.android.vending" ]; then
    log "Enabling Play Store"
    pm enable com.android.vending
fi

# Set mock location permission as ignore

if ! appops get $VMPKG android:mock_location | grep -qm1 'No operations'; then
    log "Removing mock location permissions from $VMPKG"
    appops set $VMPKG android:mock_location 2
fi

# Disable all location providers

if ! settings get; then
    log "Checking allowed location providers as 'shell' user"
    allowedProviders=".$(su shell -c settings get secure location_providers_allowed)"
else
    log "Checking allowed location providers"
    allowedProviders=".$(settings get secure location_providers_allowed)"
fi

if [ "$allowedProviders" != "." ]; then
    log "Disabling location providers..."
    if ! settings put secure location_providers_allowed -gps,-wifi,-bluetooth,-network >/dev/null; then
        log "Running as 'shell' user"
        su shell -c 'settings put secure location_providers_allowed -gps,-wifi,-bluetooth,-network'
    fi
fi

# Make sure the device doesn't randomly turn off

if [ "$(settings get global stay_on_while_plugged_in)" != 3 ]; then
    log "Setting Stay On While Plugged In"
    settings put global stay_on_while_plugged_in 3
fi

# Start MITM on boot

if [ $mitm = "vmapper" ];then
    if ! pidof "$VMPKG:mapping"; then
        log "Starting Vmapper Mapping Service"
        force_restart
    fi
elif [ $mitm = "gc" ];then
    if ! pidof "GOCHEATSPKG"; then
        log "Starting GC Mapping Service"
        force_restart
    fi
fi

# Give all mitm services root permissions

for package in $VMPKG com.android.shell; do
    packageUID=$(dumpsys package "$package" | grep userId | head -n1 | cut -d= -f2)
    policy=$(magisk --sqlite "select policy from policies where uid='$packageUID'" | cut -d= -f2)
    if [ "$policy" != 2 ]; then
        log "$package current policy is not root. Adding root permissions..."
        if ! magisk --sqlite "REPLACE INTO policies (uid,policy,until,logging,notification) VALUES($packageUID,2,0,1,1)"; then
            log "ERROR: Could not add $package (UID: $packageUID) to Magisk's DB."
        fi
    else
        log "Root permissions for $package are OK!"
    fi
done

zygisk=$(magisk --sqlite "select value from settings where key='zygisk'" | cut -d= -f2)
if [ "$zygisk" != 1 ]; then
        log "Enabling zygisk..."
        if ! magisk --sqlite "REPLACE INTO settings (key,value) VALUES('zygisk',1)"; then
            log "ERROR: Could not add $package (UID: $packageUID) to Magisk's DB."
        fi
else
        log "Zygisk is enabled!"
fi

rm /sdcard/vmapper.log

# Update Service

if [ "$monitoringenable" = true ]; then
    (
        log "Starting update check service every $(($atvdetails_interval / 60)) minutes..."
        while :; do
            currentvm=$(curl -s -k "$versionsURL/versions" | grep -w "vmapper" | awk -F "=" '{ print $2 }')
            currentpogo=$(curl -s -k "$versionsURL/versions" | grep -w "vmpogo" | awk -F "=" '{ print $2 }')
            installedpogo=$(dumpsys package com.nianticlabs.pokemongo | grep versionName | head -n1 | sed 's/ *versionName=//')
            installedvm=$(dumpsys package de.vahrmap.vmapper | grep versionName | head -n1 | sed 's/ *versionName=//')
            type=$(uname -m)
                counter=0
                if [[ $installedpogo != $currentpogo ]] ;then
                log "New POGO version detected. Downloading apk." 
                        if [ "$type" = "aarch64" ]; then
                        curl -o /data/local/tmp/pogo.apk "$versionsURL/vmpogo64.apk" 
                else
                        curl -o /data/local/tmp/pogo.apk "$versionsURL/vmpogo32.apk"
                fi
                        log "Downloaded POGO (v$currentpogo)"
                        sleep 1
                        su -c "pm install -g /data/local/tmp/pogo.apk"
                        log "Installed POGO (v$currentpogo)"
                        counter=$((counter+1))
                        sleep 1
                else
                        log "Current POGO (v$installedpogo installed)"
                fi

                if [[ $installedvm = $currentvm ]] ;then
					log "Current Vmapper (v$installedvm installed)"
                else 
					log "New Vmapper version detected. Downloading apk."
                    curl -o /data/local/tmp/vmapper.apk "$versionsURL/vmapper.apk"
                    log "Downloaded Vmapper (v$currentvm)"
                    su -c "pm install -g /data/local/tmp/vmapper.apk"
                    log "Installed Vmapper (v$currentvm)"
                    counter=$((counter+1))
                    sleep 1
                fi
                if [[ $counter != 0 ]] ;then
                        log "$counter apps updated detected. Restarting Vmapper Services"
                        mitm_root
                        force_restart
                else
                        log "MITM apps are up to date"
                fi
                log "Checking again in $(($atvdetails_interval / 60)) minutes"
                log "Sending ATV Details to receiver"
                . "$MODDIR/ATVdetailsSender.sh"
				log "Checking for misbehaving devices"
				authcount=$(cat /sdcard/vmapper.log | grep "Auth event 1" | wc -l)
				if [ $authcount -gt $authlimit ] ;then
					log "Device has made $authcount Auth requests in the past $(($atvdetails_interval / 60)) minutes. Rebooting"
     					curl -k -X POST $atvdetails_receiver_host:$atvdetails_receiver_port/reboot -H "Accept: application/json" -H "Content-Type: application/json" -d '{"deviceName":"'$DeviceName'","reboot":"reboot","RPL":"'$atvdetails_interval'"}'
					rm /sdcard/vmapper.log
					reboot
				else
					log "Device has made $authcount Auth requests in the past $(($atvdetails_interval / 60)) minutes. Device ain't misbehaving."
					rm /sdcard/vmapper.log
				fi
                sleep $atvdetails_interval
        done
    )
else
        log "eMagisk v$(cat "$MODDIR/version_lock"). Update Services disabled."
fi
