# Atlas-Scripts

Included are Ubuntu based scripts for Atlas device management.

***DISCLAIMER***

Code is sourced heavily from other users and the Google. The contents in this repo are not guaranteed to be clean but should mostly work.

**SCRIPTS**

- Edit your network details in `devicelist.py` to generate lists for device IP and names that have Port 5555 open. This is tested with Python 3.6, no idea about others. If it complains about a missing module, then `pip3 install xxx` it yourself.

- Use `./emagisk.sh DEVICEIP:DEVICEPORT` to install eMagisk on your device. Or do `./emagiskall.sh` to install it across all your devices that you found by running `devicelist.py`.

**DASHBOARDS**

- The eMagisk version in this repo includes webhook stats for keeping track of your devices.
