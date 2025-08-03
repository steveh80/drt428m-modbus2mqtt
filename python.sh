#!/usr/bin/env python3
# see https://minimalmodbus.readthedocs.io/en/stable/apiminimalmodbus.html#minimalmodbus.MODE_RTU
import serial
import minimalmodbus
import json
import paho.mqtt.client as mqtt
import time
import os

device = os.environ['DEVICE']
mqtt_server = os.environ['MQTT_SERVER']
mqtt_topic = os.environ['MQTT_TOPIC']
mqtt_user = os.environ['MQTT_USER']
mqtt_pwd = os.environ['MQTT_PWD']


client = mqtt.Client()
client.username_pw_set(mqtt_user, password=mqtt_pwd)
client.connect(mqtt_server)
client.loop_start()


instrument = minimalmodbus.Instrument(port=device, slaveaddress=1, mode=minimalmodbus.MODE_RTU, close_port_after_each_call=True, debug=False)
instrument.serial.baudrate = 9600           # Baud
instrument.serial.parity   = serial.PARITY_EVEN
instrument.serial.bytesize = 8
instrument.serial.stopbits = 1
instrument.clear_buffers_before_each_transaction = True # False
instrument.serial.timeout  = 0.50           # 0.05 seconds is too fast

instrument2= minimalmodbus.Instrument(port=device, slaveaddress=2, mode=minimalmodbus.MODE_RTU, close_port_after_each_call=True, debug=False)


data = {}
data2 = {}

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


    data2['VoltageL1'] = instrument2.read_long( registeraddress=int(0x0400), signed=True) / 1000;
    data2['VoltageL2'] = instrument2.read_long( registeraddress=int(0x0402), signed=True) / 1000;
    data2['VoltageL3'] = instrument2.read_long( registeraddress=int(0x0404), signed=True) / 1000;

    data2['GridFrequency'] = instrument2.read_register( registeraddress=int(0x0435), signed=True) / 10;
    data2['ActivePowerTotal'] = instrument2.read_long( registeraddress=int(0x0420), signed=True);
    data2['ActivePowerL1'] = instrument2.read_long( registeraddress=int(0x041A), signed=True);
    data2['ActivePowerL2'] = instrument2.read_long( registeraddress=int(0x041C), signed=True);
    data2['ActivePowerL3'] = instrument2.read_long( registeraddress=int(0x041E), signed=True);
    data2['ActiveEnergyForwardTotal'] = instrument2.read_long( registeraddress=int(0x010E), signed=True) / 100;
    data2['ActiveEnergyReverseTotal'] = instrument2.read_long( registeraddress=int(0x0118), signed=True) / 100;
    data2['ActiveEnergyTotal'] = instrument2.read_long( registeraddress=int(0x0122), signed=True) / 100;
    data2['ActiveEnergyL1'] = instrument2.read_long( registeraddress=int(0x0500), signed=True) / 100;
    data2['ActiveEnergyL2'] = instrument2.read_long( registeraddress=int(0x0564), signed=True) / 100;
    data2['ActiveEnergyL3'] = instrument2.read_long( registeraddress=int(0x05C8), signed=True) / 100;
    data2['ReactivePowerTotal'] = instrument2.read_long( registeraddress=int(0x0430), signed=True);
    data2['ApparentPowerTotal'] = instrument2.read_long( registeraddress=int(0x0428), signed=True);
    data2['PowerFactorTotal'] = instrument2.read_register( registeraddress=int(0x0439), signed=True) / 100;
  except IOError as e:
    print('ERROR: Failed to read from instrument:\n',e)
 
  instrument.serial.close()
  
  client.publish(mqtt_topic, payload=json.dumps(data), qos=0, retain=False)
  client.publish('meter/load', payload=json.dumps(data2), qos=0, retain=False)


while True:
  process()
  time.sleep(1)
