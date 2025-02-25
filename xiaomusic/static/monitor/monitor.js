$(function() {
    class MonitorDevice {
        constructor(host, port, clientId) {
            //this.client = new Paho.Client(host, port, "/ws/", clientId);
            this.socket = io({
                path: '/ws',
              });
              socket.on('connect', this.onConnect);
              socket.on('disconnect', this.onDisconnect);
              socket.on('monitor', this.onMessage);
        }

        connect() {
            this.socket.connect();
            socket.connect();
            this.send_message('Hello');
        }
        onConnect() {
            console.log('MonitorDevice: Connected to ws server');
        }
        onDisconnect() {
            console.log('MonitorDevice: Disconnected from ws server');
        }
        onMessage(message) {
            console.log('Received message:', message);
        }
        send_message(message) {
            this.socket.emit('monitor', message);
        }
    }

    $.fn.monitorDevice = function(host, port, clientId) {
        return new MonitorDevice(host, port, clientId);
    };
});
