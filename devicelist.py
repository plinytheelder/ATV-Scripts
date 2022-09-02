import socket, subprocess, json, os, time  # for connecting

# Discovery Tool for Atlas Devices, writes to two files:
# IP addresses (DeviceIP.txt)
# IP addreses + Names (DeviceNameIP.txt)


host = "192.168.0."  # Fill in local IP Here without ending number
port = 5555  # Atlas port
f = open("DeviceIP.txt", "w")
x = open("DeviceNameIP.txt", "w")


def is_port_open(host, port):
    """
    determine whether `host` has the `port` open
    """
    # creates a new socket
    s = socket.socket()
    try:
        # tries to connect to host using that port
        s.settimeout(20.0)
        s.connect((host, port))
        # make timeout if you want it a little faster ( less accuracy )

    except:
        # cannot connect, port is closed
        # return false
        return False
    else:
        # the connection was established, port is open!
        return True


def write_devicename(hostport):

    os.system("./adb connect "+str(hostport))
    os.system("./adb -s " + str(hostport) + " pull /data/local/tmp/atlas_config.json")

    with open("atlas_config.json") as jsonFile:
        jsonObject = json.load(jsonFile)
        jsonFile.close()
    devicename = "="+jsonObject['deviceName']
    x.write(hostport+devicename+"\n")


for DeviceIP in range(38, 245):
    if is_port_open(host+str(DeviceIP), port):
        print(f"[+] {host+str(DeviceIP)}:{port} is open      ")
        f.write(host + str(DeviceIP) + ":" + str(port) + "\n")
        write_devicename(host + str(DeviceIP) + ":" + str(port))
    else:
        print(f"[!] {host+str(DeviceIP)}:{port} is closed    ", end="\r")
