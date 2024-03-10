# Voltorb

Installs useful binaries: bash, curl, nano, strace, eventrec and tcpdump. Also optionally installs Atlas services that ensure uptime and Webhook stats.

---

## Installation

If you really want to install this version, you have to:

1. Create the zip file with `./build.sh`
2. adb push the magisk module into the device
3. `magisk --install-module magiskmodule.zip`
4. copy `voltorb.config` into `/data/local/tmp` of your device
5. **Edit the file to match your info**
6. `reboot`

Note: step 3 only works on Magisk versions 21.2 and forward. If you have an earlier Magisk version, install through Magisk Manager (scrcpy into the device) or update your Magisk.

## Update Services

To keep your devices up to date:

1. Find some place to stick stuff that your devices can reach. Local server is probably ideal.

2. Add a `versions` file with info like this:

```
pogo=0.291.2
gc=3.0.113
```

3. Add the following files to that directory `pogo32.apk`, `pogo64.apk`, and `gc.apk`.

4. Update the `versions` file as needed to keep track of updates.

## Webhook Stats

To install webhook stats, you have to:

1. Edit the config variables for `atvdetails_interval`, `atvdetails_receiver_host`, and `atvdetails_receiver_port`, as well as set `useSender=true`.
2. Install and fire up the receiver in the `wh_receiver` subfolder of this repo.
