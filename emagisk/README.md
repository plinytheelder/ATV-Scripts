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

## Webhook Stats

To install webhook stats, you have to:

1. Edit the config variables for `atvdetails_interval`, `atvdetails_receiver_host`, and `atvdetails_receiver_port`, as well as set `useSender=true`.
2. Install and fire up the receiver in the `wh_receiver` subfolder of this repo.
