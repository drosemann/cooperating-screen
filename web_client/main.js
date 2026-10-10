/*
 * Browser-side control panel for the cooperating-screen prototype.
 * This script keeps the WebSocket connection alive, logs the traffic flowing
 * between the frontend and the signaling server, and translates UI actions into
 * room and device messages.
 */

// The active socket instance is stored in one variable so the page can reuse a
// single connection while the user is interacting with rooms and peers.
let socket;

const el = {
  wsUrl: document.getElementById('wsUrl'),
  deviceSerial: document.getElementById('deviceSerial'),
  roomName: document.getElementById('roomName'),
  maxParticipants: document.getElementById('maxParticipants'),
  roomCode: document.getElementById('roomCode'),
  connectBtn: document.getElementById('connectBtn'),
  disconnectBtn: document.getElementById('disconnectBtn'),
  createRoomBtn: document.getElementById('createRoomBtn'),
  listRoomsBtn: document.getElementById('listRoomsBtn'),
  joinRoomBtn: document.getElementById('joinRoomBtn'),
  leaveRoomBtn: document.getElementById('leaveRoomBtn'),
  status: document.getElementById('status'),
  log: document.getElementById('log'),
};

// Writes a timestamped message to the debug console and keeps the newest entry at
// the top of the log to make the last event easy to follow during a call setup.
function log(message, data) {
  const line = `[${new Date().toISOString()}] ${message}`;
  el.log.textContent = `${line}${data ? `\n${JSON.stringify(data, null, 2)}` : ''}\n\n${el.log.textContent}`;
}

// Updates the global status text so the user always knows whether the page is
// connected, disconnected, or still waiting for a server response.
function setStatus(status) {
  el.status.textContent = `Status: ${status}`;
}

// Serializes a signaling message and sends it to the server only when a live
// WebSocket connection exists. This keeps all UI actions consistent and centralizes
// the traffic format used by the device registry and room logic.
function send(type, data = {}) {
  if (!socket || socket.readyState !== WebSocket.OPEN) {
    log('Socket ist nicht verbunden');
    return;
  }

  const payload = { type, data, timestamp: new Date().toISOString() };
  socket.send(JSON.stringify(payload));
  log(`Gesendet: ${type}`, payload);
}

// Establishes the socket connection after the user has entered the signaling URL
// and a local device identifier. The event handler performs validation before
// creating the connection and registering the device with the server.
el.connectBtn.addEventListener('click', () => {
  const url = el.wsUrl.value.trim();
  const deviceSerial = el.deviceSerial.value.trim();

  if (!url || !deviceSerial) {
    log('Bitte WebSocket URL und Device Serial eingeben.');
    return;
  }

  socket = new WebSocket(url);
  setStatus('verbinde...');

  socket.addEventListener('open', () => {
    setStatus('verbunden');
    send('device_registration', { device_serial: deviceSerial });
  });

  socket.addEventListener('message', (event) => {
    try {
      const data = JSON.parse(event.data);
      log(`Empfangen: ${data.type}`, data.data || data);
    } catch {
      log('Empfangen (raw)', { value: event.data });
    }
  });

  socket.addEventListener('close', () => setStatus('getrennt'));
  socket.addEventListener('error', (event) => log('Socket Fehler', event));
});

// Closes the current connection and resets the status label when the user wants
// to stop interacting with the signaling server manually.
el.disconnectBtn.addEventListener('click', () => {
  if (socket) {
    socket.close();
    setStatus('getrennt');
  }
});

// Creates a new public room and publishes the required metadata so peers can join
// the session by room code.
el.createRoomBtn.addEventListener('click', () => {
  send('room_create', {
    device_serial: el.deviceSerial.value.trim(),
    room_name: el.roomName.value.trim(),
    max_participants: Number(el.maxParticipants.value || 2),
    is_public: true,
  });
});

// Requests the list of currently available public rooms from the server so the
// user can quickly choose a session without manually knowing every room code.
el.listRoomsBtn.addEventListener('click', () => send('room_list', {}));

// Joins the room identified by the code entered in the form and registers the
// current device as an active participant for that session.
el.joinRoomBtn.addEventListener('click', () => {
  send('room_join', {
    room_code: el.roomCode.value.trim(),
    device_serial: el.deviceSerial.value.trim(),
  });
});

// Leaves a room cleanly and notifies the server to remove the device from the
// active participants list for that session.
el.leaveRoomBtn.addEventListener('click', () => {
  send('room_leave', {
    room_code: el.roomCode.value.trim(),
    device_serial: el.deviceSerial.value.trim(),
  });
});
