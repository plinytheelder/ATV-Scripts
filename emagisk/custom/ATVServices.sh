#!/system/bin/sh

# Base stuff we need

POGOPKG=com.nianticlabs.pokemongo
UNINSTALLPKGS="com.ionitech.airscreen cm.aptoidetv.pt com.netflix.mediaclient org.xbmc.kodi com.google.android.youtube.tv com.cloudmosa.puffinTV com.netflix.ninja"
CONFIGFILE='/data/local/tmp/emagisk.config'

source $CONFIGFILE
export mitm emagiskenable

# Check if this is a beta or production device

check_beta() {    
    if [ "$(pm list packages com.pokemod.atlas.beta)" = "package:com.pokemod.atlas.beta" ]; then
        log "Found Atlas developer version!"
        ATLASPKG=com.pokemod.atlas.beta
    elif [ "$(pm list packages com.pokemod.atlas)" = "package:com.pokemod.atlas" ]; then
        log "Found Atlas production version!"
        ATLASPKG=com.pokemod.atlas
    elif [ "$(pm list packages com.gocheats.launcher)" = "package:com.gocheats.launcher" ]; then
        log "Found GoCheats production version!"
        GOCHEATSPKG=com.gocheats.launcher
    else
        log "No MITM installed. Abort!"
        exit 1
    fi
}

# Stops MITM and Pogo and restarts MITM MappingService

force_restart() {
    if [ "$mitm" = "atlas" ];then
        am stopservice $ATLASPKG/com.pokemod.atlas.services.MappingService
        am force-stop $POGOPKG
        am force-stop $ATLASPKG
        sleep 5
        am startservice $ATLASPKG/com.pokemod.atlas.services.MappingService
    elif [ "$mitm" = "gc" ];then
        am force-stop $GOCHEATSPKG
        sleep 5
        monkey -p $GOCHEATSPKG 1
    fi
    log "Services were restarted!"
}


if [ "$setHostname" = true -a "$mitm" = "atlas" ] ;then
	atlasDeviceName=$(cat /data/local/tmp/atlas_config.json | tr , '\n' | grep -w 'deviceName' | awk -F ":" '{ print $2 }' | tr -d \"})
 	setprop net.hostname $atlasDeviceName
  	log "Set hostname to $atlasDeviceName" 	
elif [ "$setHostname" = true -a "$mitm" = "gc" ] ;then  
	gcDeviceName=$(cat /data/local/tmp/config.json | awk 'FNR == 3  {print $2}'| awk -F"\"" '{print $2}')
 	setprop net.hostname $gcDeviceName
  	log "Set hostname to $gcDeviceName"
fi

# Adjust the script depending on Atlas or GC

check_beta

# Wipe out packages we don't need in our ATV

echo "$UNINSTALLPKGS" | tr ' ' '\n' | while read -r item; do
    if ! dumpsys package "$item" | \grep -qm1 "Unable to find package"; then
        log "Uninstalling $item..."
        pm uninstall "$item"
    fi
done

# Enable playstore

if [ "$(pm list packages -d com.android.vending)" = "package:com.android.vending" ]; then
    log "Enabling Play Store"
    pm enable com.android.vending
fi

# Set atlas mock location permission as ignore

if ! appops get $ATLASPKG android:mock_location | grep -qm1 'No operations'; then
    log "Removing mock location permissions from $ATLASPKG"
    appops set $ATLASPKG android:mock_location 2
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

if [ $mitm = "atlas" ];then
    if ! pidof "$ATLASPKG:mapping"; then
        log "Starting Atlas Mapping Service"
        force_restart
    fi
elif [ $mitm = "gc" ];then
    if ! pidof "GOCHEATSPKG"; then
        log "Starting GC Mapping Service"
        force_restart
    fi
fi

# Give all mitm services root permissions

for package in $GOCHEATSPKG com.android.shell; do
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
done

# Update Service

if [ "$(pm list packages $GOCHEATSPKG)" = "package:$GOCHEATSPKG" -a "$mitm" = "gc" -a "$emagiskenable" = true ]; then
        log "eMagisk v$(cat "$MODDIR/version_lock"). Starting update check service in 15 minutes..."
	while :; do
            currentgc=$(curl -s -k "$versionsURL/versions" | grep -w "gc" | awk -F "=" '{ print $2 }')
            currentpogo=$(curl -s -k "$versionsURL/versions" | grep -w "pogo" | awk -F "=" '{ print $2 }')
            installedpogo=$(dumpsys package com.nianticlabs.pokemongo | grep versionName | head -n1 | sed 's/ *versionName=//')
            installedgc=$(dumpsys package com.gocheats.launcher | grep versionName | head -n1 | sed 's/ *versionName=//')
	    type=$(uname -m)
	        if [[ $installedpogo != $currentpogo ]] ;then
        		if [ "$type" = "aarch64" ]; then
			curl -o /data/local/tmp/pogo.apk "$versionsURL/pogo64.apk" 
		else
			curl -o /data/local/tmp/pogo.apk "$FileURL/pogo32.apk"
		fi
        		echo "Downloaded POGO (v$currentpogo)"
        		sleep 1
        		su -c "pm install -g /data/local/tmp/pogo.apk"
        		log "Installed POGO (v$currentgc)"
        		sleep 1
    		else
        		echo "No POGO update available (v$installedpogo = v$currentpogo)"
    		fi

    		if [[ $installedgc != $currentgc ]] ;then
		        curl -o /data/local/tmp/gc.apk "$FileURL/gc.apk"
        		echo "Downloaded GC (v$currentgc)"
        		su -c "pm install -g /data/local/tmp/gc.apk"
        		log "Installed GC (v$currentgc)"
        		sleep 1
    		else 
        		log "No GC update available (v$installedgc = v$currentgc)"
		fi
      		if [[ $installedgc != $currentgc -o $installedpogo != $currentpogo ]] ;then
			log "App updated detected. Restarting GC Services"
			force_restart
   		else
     			log "MITM apps are up to date"
		fi
  		sleep 1800
   	done
   fi
     
