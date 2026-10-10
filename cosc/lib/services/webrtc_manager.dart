/// Manager for active WebRTC peer connections and associated negotiation state.
/// It coordinates stream setup, remote endpoints, and connection cleanup so a
/// session can be created and torn down predictably.
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'webrtc_service.dart';
import 'signaling_service.dart';

class WebRTCManager {
  final WebRTCService webRtcService;
  final SignalingService signalingService;
  
  String? _remoteDeviceSerial;
  bool _isInitialized = false;

  WebRTCManager({
    required this.webRtcService,
    required this.signalingService,
  });

  /// Initialize and start WebRTC connection with a remote device
  Future<bool> startConnection({
    required String remoteDeviceSerial,
    bool initiateOffer = true,
    bool useAudio = true,
    bool useVideo = true,
  }) async {
    try {
      _remoteDeviceSerial = remoteDeviceSerial;
      
      // Initialize WebRTC
      final initialized = await webRtcService.initialize(
        useAudio: useAudio,
        useVideo: useVideo,
      );

      if (!initialized) {
        return false;
      }

      _isInitialized = true;

      // Setup signaling handlers
      _setupSignalingHandlers();

      // Create offer if this is the initiating device
      if (initiateOffer) {
        return await webRtcService.createOffer(remoteDeviceSerial);
      }

      return true;
    } catch (e) {
      print('Error starting connection: $e');
      return false;
    }
  }

  /// Setup handlers for incoming signaling messages
  void _setupSignalingHandlers() {
    // These would be implemented in SignalingService to handle incoming messages
    // and call the appropriate WebRTC methods
  }

  /// Handle incoming WebRTC offer
  Future<bool> handleIncomingOffer(String offerSdp) async {
    try {
      if (!_isInitialized) {
        print('WebRTC not initialized');
        return false;
      }

      // Handle the offer
      final handled = await webRtcService.handleOffer(offerSdp);
      if (!handled) return false;

      // Create and send answer
      if (_remoteDeviceSerial != null) {
        return await webRtcService.createAnswer(_remoteDeviceSerial!);
      }

      return false;
    } catch (e) {
      print('Error handling offer: $e');
      return false;
    }
  }

  /// Handle incoming WebRTC answer
  Future<bool> handleIncomingAnswer(String answerSdp) async {
    try {
      if (!_isInitialized) {
        print('WebRTC not initialized');
        return false;
      }

      return await webRtcService.handleAnswer(answerSdp);
    } catch (e) {
      print('Error handling answer: $e');
      return false;
    }
  }

  /// Handle incoming ICE candidate
  Future<bool> handleIncomingCandidate({
    required String candidate,
    required int? sdpMLineIndex,
    required String? sdpMid,
  }) async {
    try {
      if (!_isInitialized) {
        print('WebRTC not initialized');
        return false;
      }

      return await webRtcService.addIceCandidate(
        candidate,
        sdpMLineIndex,
        sdpMid,
      );
    } catch (e) {
      print('Error adding ICE candidate: $e');
      return false;
    }
  }

  /// End the connection
  Future<void> endConnection() async {
    try {
      await webRtcService.dispose();
      _isInitialized = false;
      _remoteDeviceSerial = null;
    } catch (e) {
      print('Error ending connection: $e');
    }
  }

  /// Check if connection is established
  bool isConnected() {
    return _isInitialized &&
        webRtcService.getConnectionState() ==
            RTCPeerConnectionState.RTCPeerConnectionStateConnected;
  }

  /// Get connection statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      // This would require implementing stats collection
      return {
        'connectionState': webRtcService.getConnectionState()?.toString(),
        'iceConnectionState':
            webRtcService.getIceConnectionState()?.toString(),
        'isConnected': isConnected(),
      };
    } catch (e) {
      print('Error getting stats: $e');
      return {};
    }
  }
}
