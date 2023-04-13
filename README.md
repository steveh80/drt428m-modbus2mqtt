# drt428m-modbus2mqtt
Reads values from a DRT428M-2 meter and pushes the data to a mqtt broker.

It sends the meter readings via JSON Object:

```
{
    "VoltageL1": 235.39999389648438,
    "VoltageL2": 236.1999969482422,
    "VoltageL3": 235.6999969482422,
    "GridFrequency": 50,
    "ActivePowerTotal": 2.13100004196167,
    "ActivePowerL1": 0.890999972820282,
    "ActivePowerL2": 0.6119999885559082,
    "ActivePowerL3": 0.6269999742507935,
    "ActiveEnergyTotal": 7.429999828338623,
    "ActiveEnergyL1": 3.1600000858306885,
    "ActiveEnergyL2": 1.7100000381469727,
    "ActiveEnergyL3": 2.559999942779541,
    "ReactivePowerTotal": 1.815999984741211,
    "ApparentPowerTotal": 2.818000078201294,
    "PowerFactorTotal": 0.8399999737739563
}
```

## How to run this
You can run this via docker as a service:

```
docker run -d \ 
	--device /dev/serial/by-id/usb-1a86_USB_Single_Serial_5434043459-if00:/dev/ttyACM0 \
	--network app-net \
	--ip 192.168.168.23 \
	--name meter-heatpump \
	--env MQTT_SERVER="192.168.168.4" \
	--env MQTT_USER="charger" \
	--env MQTT_PWD="moth-havoc-CANE" \
	--env MQTT_TOPIC="meter/heatpump" \
	--env DEVICE="/dev/ttyACM0" \
	haeuslschmid/drt428m-modbus2mqtt
```

