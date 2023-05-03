# eMagisk

Installs useful binaries: bash, curl, nano, strace, eventrec and tcpdump. Also optionally installs Atlas services that ensure uptime and Webhook stats.

---

## Installation

If you really want to install this version, you have to:

1. Create the zip file with `./build.sh`
2. adb push the magisk module into the device
3. `magisk --install-module magiskmodule.zip`
4. copy `emagisk.config` from `https://github.com/tchavei/eMagisk/blob/master/emagisk.config` into `/data/local/tmp` of your device
5. **Edit the file to match your RDM username, password and server IP:PORT**
6. `reboot`

Note: step 3 only works on Magisk versions 21.2 and forward. If you have an earlier Magisk version, install through Magisk Manager (scrcpy into the device) or update your Magisk.

## RDM Device Status

To prevent eMagisk from hammering RDM with logins, do this:

1. Create a script that pulls device status logs. So a `devicestatus.sh` file that looks like this:

`curl -s -k -u user:password "http://rdmurl/api/get_data?show_devices=true&formatted=true" -o devicestatus.json`

Should probably put it somewhere it can be accessed, I put it in `/var/www/devices`. Then make it executable `sudo chmod +x devicestatus.sh`.

2. Cron it every minute

`*/1 * * * * cd /var/www/devices && sh devices.sh`

3. Need to add a reverse proxy so file can be reached? Something as easy as this works:

```
server {
    listen 9123;
    server_name  127.0.0.1;
        location / {
        alias /var/www/devices/;
    }
}
```

4. Change `rdm_backendURL` in emagisk config to the file location, so like `http://127.0.0.1:9123/devicestatus.json`

NOTE: If you don't want to do this, then just set `rdm_backendURL` equal to `http://rdmurl/api/get_data?show_devices=true&formatted=true`...I think that's it.

## Webhook Stats

To install webhook stats, you have to:

1. Edit the config variables for `atvdetails_interval`, `atvdetails_receiver_host`, and `atvdetails_receiver_port`, as well as set `useSender=true`.
2. Install and fire up the receiver in the `wh_receiver` subfolder of this repo.
