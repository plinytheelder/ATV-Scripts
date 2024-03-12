# Webhook receiver for getting data from ATV devices
# replacement for ATVdetails
#
__author__ = "GhostTalker and Apple314"
__copyright__ = "Copyright 2022, The GhostTalker project"
__version__ = "0.1.5"
__status__ = "DEV"

import os
import sys
import time
import datetime
import json
import requests
import configparser
import pymysql
from mysql.connector import Error
from mysql.connector import pooling
from flask import Flask, request

## read config
_config = configparser.ConfigParser()
_rootdir = os.path.dirname(os.path.abspath('config.ini'))
_config.read(_rootdir + "/config.ini")
_host = _config.get("socketserver", "host", fallback='0.0.0.0')
_port = _config.get("socketserver", "port", fallback='5050')
_mysqlhost = _config.get("mysql", "mysqlhost", fallback='127.0.0.1')
_mysqlport = _config.get("mysql", "mysqlport", fallback='3306')
_mysqldb = _config.get("mysql", "mysqldb")
_mysqluser = _config.get("mysql", "mysqluser")
_mysqlpass = _config.get("mysql", "mysqlpass")

## do validation and checks before insert
def validate_string(val):
   if val != None:
        if type(val) is int:
            #for x in val:
            #   print(x)
            return str(val).encode('utf-8')
        else:
            return val

## create connection pool and connect to MySQL
try:
    connection_pool = pooling.MySQLConnectionPool(pool_name="mysql_connection_pool",
                                                  pool_size=5,
                                                  pool_reset_session=True,
                                                  host=_mysqlhost,
                                                  port=_mysqlport,
                                                  database=_mysqldb,
                                                  user=_mysqluser,
                                                  password=_mysqlpass)

    print("Create connection pool: ")
    print("Connection Pool Name - ", connection_pool.pool_name)
    print("Connection Pool Size - ", connection_pool.pool_size)

    # Get connection object from a pool
    connection_object = connection_pool.get_connection()

    if connection_object.is_connected():
        db_Info = connection_object.get_server_info()
        print("Connected to MySQL database using connection pool ... MySQL Server version on ", db_Info)

        cursor = connection_object.cursor()
        cursor.execute("select database();")
        record = cursor.fetchone()
        print("You're connected to - ", record)

except Error as e:
    print("Error while connecting to MySQL using Connection pool ", e)

finally:
    # closing database connection.
    if connection_object.is_connected():
        cursor.close()
        connection_object.close()
        print("MySQL connection is closed")

## webhook receiver
app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def webhook():
    if request.method == 'POST':
        print("Data received from Webhook is: ", request.json)

        # parse json data to SQL insert
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        deviceName = validate_string(request.json["deviceName"])
        if 'arch' in request.json:
            arch = validate_string(request.json["arch"]) 
        else: arch = None
        if 'productmodel' in request.json:
            productmodel = validate_string(request.json["productmodel"]) 
        else: productmodel = None
        if 'emagiskversion' in request.json:
            emagiskversion = validate_string(request.json["emagiskversion"]) 
        else: emagiskversion = None
        if 'pogo' in request.json:
            pogo = validate_string(request.json["pogo"]) 
        else: pogo = None
        if 'mitmversion' in request.json:
            mitmversion = validate_string(request.json["mitmversion"]) 
        else: mitmversion = None
        if 'temperature' in request.json:
            temperature = validate_string(request.json["temperature"]) 
        else: temperature = None
        if 'magisk' in request.json:
            magisk = validate_string(request.json["magisk"]) 
        else: magisk = None
        if 'mace' in request.json:
            mace = validate_string(request.json["mace"]) 
        else: mace = None
        if 'ip' in request.json:
            ip = validate_string(request.json["ip"]) 
        else: ip = None        
        if 'hostname' in request.json:
            hostname = validate_string(request.json["hostname"]) 
        else: hostname = None        
        if 'playstore' in request.json:
            playstore = validate_string(request.json["playstore"]) 
        else: playstore = None        
        if 'proxyinfo' in request.json:
            proxyinfo = validate_string(request.json["proxyinfo"]) 
        else: proxyinfo = None
        if 'RPL' in request.json:
            RPL = validate_string(request.json["RPL"]) 
        else: RPL = None
        if 'authBearer' in request.json:
            authBearer = validate_string(request.json["authBearer"]) 
        else: authBearer = None
        if 'token' in request.json:
            token = validate_string(request.json["token"]) 
        else: token = None
        if 'workers' in request.json:
            workers = validate_string(request.json["workers"]) 
        else: workers = None
        if 'rotomUrl' in request.json:
            rotomUrl = validate_string(request.json["rotomUrl"]) 
        else: rotomUrl = None
        if 'rotomsecret' in request.json:
            rotomsecret = validate_string(request.json["rotomsecret"]) 
        else: rotomsecret = None
        
        insert_stmt1 = "\
            INSERT INTO ATVsummary \
                (timestamp, \
                deviceName, \
                arch, \
                productmodel, \
                emagiskversion, \
                pogo, \
                mitmversion, \
                temperature, \
                magisk, \
                MACe, \
                ip, \
                hostname, \
                playstore, \
                proxyinfo, \
                token, \
                workers, \
                rotomUrl, \
                rotomsecret) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) \
            ON DUPLICATE KEY UPDATE \
                timestamp = VALUES(timestamp), \
                deviceName = VALUES(deviceName), \
                arch = VALUES(arch), \
                productmodel = VALUES(productmodel), \
                emagiskversion = VALUES(emagiskversion), \
                pogo = VALUES(pogo), \
                mitmversion = VALUES(mitmversion), \
                temperature = VALUES(temperature), \
                magisk = VALUES(magisk), \
                MACe = VALUES(MACe), \
                ip = VALUES(ip), \
                hostname = VALUES(hostname), \
                playstore = VALUES(playstore), \
                proxyinfo = VALUES(proxyinfo), \
                token = VALUES(token), \
                workers = VALUES(workers), \
                rotomUrl = VALUES(rotomUrl), \
                rotomsecret = VALUES(rotomsecret)"

        data1 = (str(timestamp), str(deviceName), str(arch), str(productmodel), str(emagiskversion), str(pogo), str(mitmversion), str(temperature), str(magisk), str(mace), str(ip), str(hostname), str(playstore), str(proxyinfo), str(token), str(workers), str(rotomUrl), str(rotomsecret) )

        insert_stmt2 = (
            "INSERT INTO ATVstats (timestamp, RPL, deviceName, temperature)"
            "VALUES ( %s, %s, %s, %s)"
        )        
        
        data2 = (str(timestamp), str(RPL), str(deviceName), str(temperature) )

        try:
            connection_object = connection_pool.get_connection()
        
            # Get connection object from a pool
            if connection_object.is_connected():
                print("MySQL pool connection is open.")
                # Executing the SQL command
                cursor = connection_object.cursor()
                cursor.execute(insert_stmt1, data1)
                cursor.execute(insert_stmt2, data2)
                connection_object.commit()
                print("Data inserted")
                
        except Exception as e:
            # Rolling back in case of error
            connection_object.rollback()
            print(e)
            print("Data NOT inserted. rollbacked.")

        finally:
            # closing database connection.
            if connection_object.is_connected():
                cursor.close()
                connection_object.close()
                print("MySQL pool connection is closed.")

        return "Webhook received!"

@app.route('/reboot', methods=['POST'])
def reboot():
    if request.method == 'POST':
        print("Data received from Webhook is: ", request.json)

        # parse json data to SQL insert
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        deviceName = validate_string(request.json["deviceName"])
        if 'reboot' in request.json:
            reboot = validate_string(request.json["reboot"]) 
        else: reboot = None
        if 'RPL' in request.json:
            RPL = validate_string(request.json["RPL"]) 
        else: RPL = None
        
        insert_stmt3 = (
            "INSERT INTO ATVstats (timestamp, deviceName, RPL, reboot)"
            "VALUES ( %s, %s, %s, %s)"
        )        
        
        data3 = (str(timestamp), str(deviceName), str(RPL), str(reboot) )

        try:
            connection_object = connection_pool.get_connection()
        
            # Get connection object from a pool
            if connection_object.is_connected():
                print("MySQL pool connection is open.")
                # Executing the SQL command
                cursor = connection_object.cursor()
                cursor.execute(insert_stmt3, data3)
                connection_object.commit()
                print("Data inserted")
                
        except Exception as e:
            # Rolling back in case of error
            connection_object.rollback()
            print(e)
            print("Data NOT inserted. rollbacked.")

        finally:
            # closing database connection.
            if connection_object.is_connected():
                cursor.close()
                connection_object.close()
                print("MySQL pool connection is closed.")

        return "Webhook received!"

# start scheduling
try:
    app.run(host=_host, port=_port)

except KeyboardInterrupt:
    print("Webhook receiver will be stopped")
    exit(0)
