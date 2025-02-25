import time
from datetime import datetime

class MqttDevice:
    def __init__(self, name):
        self.name = name
        self.start = None
        self.stop = None
        self.duration = 0
        self.is_online = False
        self.last_online = None

    def go_online(self):
        self.start = time.time()
        self.is_online = True
        self.last_online = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"{self.name} is now online. Last online: {self.last_online}")

    def go_offline(self):
        self.stop = time.time()
        if self.start is not None:
            self.duration += self.stop - self.start
        self.is_online = False
        print(f"{self.name} is now offline. Total online duration: {self.duration} seconds. Last online: {self.last_online}")

    def get_duration(self):
        if self.is_online:
            current_duration = int(time.time() - self.start)
            return self.duration + current_duration
        print(f"Last online: {self.last_online}")
        return int(self.duration)

# Example usage
if __name__ == "__main__":
    device = MqttDevice("Device1")
    device.go_online()
    time.sleep(2)
    device.go_offline()
    print(f"Total duration: {device.get_duration()} seconds")