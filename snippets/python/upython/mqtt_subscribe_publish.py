"""
Script tests mqtt subscribe and publish at the same time, within the same loop.
The script presumes that the connection to WiFi has already been established.
"""

from machine import Pin
from utime import sleep_ms
from time import time
from umqtt.simple import MQTTClient
from config import *

MQTT_CLIENT_ID = 'mqttclient'
MQTT_BROKER = '192.168.1.4'
TOPIC_IN = 'mqttclient/in'
TOPIC_OUT = 'mqttclient/out'

l = Pin(2, Pin.OUT, value=1)
m = MQTTClient(MQTT_CLIENT_ID, MQTT_BROKER)

def callback(topic, msg):
    global l
    print((topic, msg))
    if msg == b'on':
        l.value(0)
    elif msg == b'off':
        l.value(1)
    else:
        l.value(not l.value())

m.set_callback(callback)
m.connect()
m.subscribe(TOPIC_IN.encode())

i = 0
print('Publishing message.')
m.publish(TOPIC_OUT.encode(), str(time()).encode())
while True:
    try:
        i += 1
        print('Checking messages on the broker.')
        m.check_msg()
        if i % 10 == 0:
            print('Publishing message.')
            m.publish(TOPIC_OUT.encode(), str(time()).encode())
            i = 0
        sleep_ms(100)
    except Exception as e:
        print(e)
        m.set_callback(callback)
        m.connect()
        m.subscribe(TOPIC_IN.encode())
