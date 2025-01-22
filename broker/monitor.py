import traceback

import paho.mqtt.client as mqtt
import broker.mqttdevice as MqttDevice
import xiaomusic.config as Config
import logging

class Monitor:
    def __init__(self, config, log):
        self.config = config
        self.log = log
        self.host = config.hostname
        self.port = config.mqtt_port
        self.client = mqtt.Client()
        self.devices = {}

    def on_connect(self, client, userdata, flags, rc):
        self.log.info("Connected with result code " + str(rc))
        client.subscribe("GoOnline")
        client.subscribe("GoOffline")
        client.subscribe("Hello")

    def on_message(self, client, userdata, msg):
        try:
            topic = msg.topic
            payload = msg.payload.decode()
            if topic == "GoOnline":
                if payload not in self.devices:
                    device = MqttDevice.MqttDevice(payload)
                    self.devices[payload] = device
                    self.devices[payload].go_online()
            elif topic == "GoOffline":
                if payload in self.devices:
                    self.devices[payload].go_offline()
            else:
                self.log.info(f"Error: Device {payload} not found.")
        except Exception as e:
            self.log.debug(f"An error occurred: {e}")
            traceback.print_exc()

    def run_start(self):
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        self.client.connect(self.host, self.port, 60)
        self.client.loop_start() #loop_forever() can block other tasks, eg. http.

    def print_online_devices(self):
        online_devices = [name for name, device in self.devices if device.online]
        self.log.info("Online devices:", online_devices)

    def print_offline_devices(self):
        offline_devices = [name for name, device in self.devices if not device.online]
        self.log.info("Offline devices:", offline_devices)