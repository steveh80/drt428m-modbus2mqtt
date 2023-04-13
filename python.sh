#!/usr/bin/env python3
# see https://minimalmodbus.readthedocs.io/en/stable/apiminimalmodbus.html#minimalmodbus.MODE_RTU
import serial
import minimalmodbus
import json
import paho.mqtt.publish as mqtt
import time
import os

device = os.environ['DEVICE']
mqtt_server = os.environ['MQTT_SERVER']
mqtt_topic = os.environ['MQTT_TOPIC']
mqtt_user = os.environ['MQTT_USER']
mqtt_pwd = os.environ['MQTT_PWD']


instrument = minimalmodbus.Instrument(port=device, slaveaddress=1, mode=minimalmodbus.MODE_RTU, close_port_after_each_call=True, debug=False)
instrument.serial.baudrate = 9600           # Baud
instrument.serial.parity   = serial.PARITY_EVEN
instrument.serial.bytesize = 8
instrument.serial.stopbits = 1
instrument.clear_buffers_before_each_transaction = True # False
instrument.serial.timeout  = 0.30           # 0.05 seconds is too fast

data = {}


def process():
  try:
    ## Read value 
    data['VoltageL1'] = instrument.read_float( registeraddress=int(0x000E));
    data['VoltageL2'] = instrument.read_float( registeraddress=int(0x0010));
    data['VoltageL3'] = instrument.read_float( registeraddress=int(0x0012));

    data['GridFrequency'] = instrument.read_float( registeraddress=int(0x0014));
    data['ActivePowerTotal'] = instrument.read_float( registeraddress=int(0x001C));
    data['ActivePowerL1'] = instrument.read_float( registeraddress=int(0x001E));
    data['ActivePowerL2'] = instrument.read_float( registeraddress=int(0x0020));
    data['ActivePowerL3'] = instrument.read_float( registeraddress=int(0x0022));
    data['ActiveEnergyTotal'] = instrument.read_float( registeraddress=int(0x0100));
    data['ActiveEnergyL1'] = instrument.read_float( registeraddress=int(0x0102));
    data['ActiveEnergyL2'] = instrument.read_float( registeraddress=int(0x0104));
    data['ActiveEnergyL3'] = instrument.read_float( registeraddress=int(0x0106));
    data['ReactivePowerTotal'] = instrument.read_float( registeraddress=int(0x0024));
    data['ApparentPowerTotal'] = instrument.read_float( registeraddress=int(0x002C));
    data['PowerFactorTotal'] = instrument.read_float( registeraddress=int(0x0036));
 
  except IOError as e:
    print('ERROR: Failed to read from instrument:\n',e)
 
  instrument.serial.close()
  
  mqtt.single(mqtt_topic, payload=json.dumps(data), qos=0, retain=False, hostname=mqtt_server, port=1883, auth={'username': mqtt_user, 'password': mqtt_pwd})

while True:
  process()
  time.sleep(2)
