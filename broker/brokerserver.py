# brokerserver.py

import asyncio
import paho.mqtt.client as mqtt
from xiaomusic.config import (
    KEY_WORD_ARG_BEFORE_DICT,
    Config,
    Device,
)

class BrokerServer:
    def __init__(self, config: Config):
        self.config = config
        self.host = config.hostname
        self.port = config.port + 1
        self.client = mqtt.Client()

    def on_connect(self, client, userdata, flags, rc):
        print(f"Connected with result code {rc}")
        # Subscribe to a topic
        client.subscribe("test/topic")

    def on_message(self, client, userdata, msg):
        print(f"Received message: {msg.topic} {msg.payload}")

    async def start(self):
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

        self.client.connect(self.host, self.port, 60)
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, self.client.loop_forever)