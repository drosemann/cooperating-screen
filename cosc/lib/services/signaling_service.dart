/// Signaling service for WebSocket communication with the backend server.
/// It handles connection lifecycle, message dispatch, and event conversion so the
/// rest of the app can work with a clean application-level API.
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class SignalingService {
  late WebSocketChannel _channel;
  final String _serverUrl;
  bool _isConnected = false;
  
  SignalingService({
    required String serverUrl,
  }) : _serverUrl = serverUrl;
  
  /// Opens the WebSocket connection to the signaling server and immediately sends
  /// the device registration payload so the backend can map this client to a
  /// reachable peer identity.
  Future<bool> connect(String deviceSerial) async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(_serverUrl),
      );
      
      // Send device registration message
      sendMessage('device_registration', {
        'device_serial': deviceSerial,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _isConnected = true;
      _listenToMessages();
      return true;
    } catch (e) {
      print('Error connecting to signaling server: $e');
      return false;
    }
  }
  
  /// Encodes a protocol message and forwards it through the active socket. The
  /// payload consistently wraps each action in a `type`, `data`, and timestamp
  /// envelope so the server can parse and route it reliably.
  void sendMessage(String messageType, Map<String, dynamic> data) {
    if (!_isConnected) {
      print('Error: Not connected to signaling server');
      return;
    }
    
    final message = {
      'type': messageType,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _channel.sink.add(jsonEncode(message));
  }
  
  /// Subscribes to the socket stream and dispatches each incoming payload to the
  /// protocol-specific handler. Errors and disconnects are also logged to allow the
  /// app to recover gracefully when the backend becomes unavailable.
  void _listenToMessages() {
    _channel.stream.listen(
      (message) {
        try {
          final decoded = jsonDecode(message);
          _handleMessage(decoded);
        } catch (e) {
          print('Error parsing message: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _isConnected = false;
      },
      onDone: () {
        print('WebSocket connection closed');
        _isConnected = false;
      },
    );
  }
  
  /// Parses the server event and routes it to the matching WebRTC or room state
  /// handler. This keeps the rest of the app decoupled from the raw socket format.
  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final data = message['data'];
    
    switch (type) {
      case 'offer':
        _onOfferReceived(data);
        break;
      case 'answer':
        _onAnswerReceived(data);
        break;
      case 'ice_candidate':
        _onIceCandidateReceived(data);
        break;
      case 'connection_state':
        _onConnectionStateChange(data);
        break;
      case 'room_created':
      case 'room_joined':
      case 'room_left':
      case 'participant_joined':
      case 'participant_left':
      case 'host_changed':
      case 'room_list':
        print('Room message: $type');
        break;
      default:
        print('Unknown message type: $type');
    }
  }
  
  void _onOfferReceived(Map<String, dynamic> data) {
    // Handle WebRTC offer - will be implemented with flutter_webrtc
    print('Offer received: $data');
  }
  
  void _onAnswerReceived(Map<String, dynamic> data) {
    // Handle WebRTC answer
    print('Answer received: $data');
  }
  
  void _onIceCandidateReceived(Map<String, dynamic> data) {
    // Handle ICE candidate
    print('ICE candidate received: $data');
  }
  
  void _onConnectionStateChange(Map<String, dynamic> data) {
    // Handle connection state updates
    print('Connection state: ${data['state']}');
  }
  
  /// Sends a pairing challenge to the intended peer. The password is forwarded in
  /// a transport-safe format so the backend can relay the request and the remote
  /// device can confirm the intended match.
  void sendPairingRequest(String targetDeviceSerial, String password) {
    sendMessage('pairing_request', {
      'target_device': targetDeviceSerial,
      'password_hash': password, // Should be hashed on client
    });
  }
  
  /// Transmits a WebRTC offer to a target device so the negotiation can continue
  /// without coupling the UI directly to the underlying signaling protocol.
  void sendOffer(String targetDevice, Map<String, dynamic> sdp) {
    sendMessage('offer', {
      'target_device': targetDevice,
      'sdp': sdp,
    });
  }
  
  /// Send WebRTC answer
  void sendAnswer(String targetDevice, Map<String, dynamic> sdp) {
    sendMessage('answer', {
      'target_device': targetDevice,
      'sdp': sdp,
    });
  }
  
  /// Send ICE candidate
  void sendIceCandidate(String targetDevice, Map<String, dynamic> candidate) {
    sendMessage('ice_candidate', {
      'target_device': targetDevice,
      'candidate': candidate,
    });
  }
  
  /// Check if connected
  bool get isConnected => _isConnected;
  
  /// Disconnect from server
  void disconnect() {
    if (_isConnected) {
      _channel.sink.close();
      _isConnected = false;
    }
  }
}
