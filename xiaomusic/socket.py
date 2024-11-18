# New server: Uvicorn(ASGI server) + FastAPI(Web framework)
# [alic] Support socket IO on fast api
import socketio
# from xiaomusic.httpserver import app

clients_sid = {}
xiaomusic = None 
app = None 
log = None
sio = socketio.AsyncServer(async_mode='asgi', cors_allowed_origins='*')

def SocketInit(_xiaomusic, _app):
    global xiaomusic, app, log
    xiaomusic = _xiaomusic
    app = _app
    log = xiaomusic.log
    socket_app = socketio.ASGIApp(sio, app, socketio_path='/ws')
    app.mount('/ws', socket_app)
    log.debug('SocketIO initialized')

@sio.on('connect')
def handle_connect(sid, environ):
    clients_sid[sid] = sid
    log.debug(f'Client connected: {sid}')

@sio.on('disconnect')
def handle_disconnect(sid):
    del clients_sid[sid]
    log.debug(f'Client disconnected: {sid}')

@sio.on('message')
async def handle_message(sid, data):
    log.debug(f'Received message from {sid}: {data}')
    await sio.emit('response', data, room=sid)
    
async def emit_message(message, data):
    await sio.emit(message, data)
# [alic] end