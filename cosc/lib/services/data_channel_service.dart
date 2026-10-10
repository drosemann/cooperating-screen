/// Service that manages the WebRTC data channel used for lightweight signaling.
/// It provides a message abstraction for text and binary payloads exchanged along
/// the same connection used for media traffic and remote control events.
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:typed_data';
import 'dart:convert';

class DataChannelMessage {
  final String type; // 'file', 'clipboard', 'text', 'control'
  final Map<String, dynamic> data;
  final DateTime timestamp;

  DataChannelMessage({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DataChannelMessage.fromJson(Map<String, dynamic> json) {
    return DataChannelMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class DataChannelService {
  RTCDataChannel? _dataChannel;
  bool _isReady = false;

  // Callbacks
  Function(DataChannelMessage)? onMessageReceived;
  Function()? onChannelOpen;
  Function()? onChannelClosed;
  Function(String)? onError;

  /// Initialize data channel (called by WebRTC service)
  Future<void> initializeDataChannel(RTCDataChannel dataChannel) async {
    _dataChannel = dataChannel;
    _setupHandlers();
  }

  /// Setup event handlers for data channel
  void _setupHandlers() {
    if (_dataChannel == null) return;

    _dataChannel!.onDataChannelState = (RTCDataChannelState state) {
      print('Data channel state: $state');
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _isReady = true;
        onChannelOpen?.call();
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        _isReady = false;
        onChannelClosed?.call();
      }
    };

    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      _handleIncomingMessage(message);
    };

    _dataChannel!.onBufferedAmountLow = () {
      print('Data channel buffer level low');
    };
  }

  /// Handle incoming data channel messages
  void _handleIncomingMessage(RTCDataChannelMessage message) {
    try {
      if (message.isBinary) {
        print('Received binary data: ${message.binary?.length} bytes');
      } else {
        final json = jsonDecode(message.text);
        final msg = DataChannelMessage.fromJson(json);
        onMessageReceived?.call(msg);
      }
    } catch (e) {
      print('Error handling data channel message: $e');
      onError?.call('Failed to parse message: $e');
    }
  }

  /// Send text message
  Future<bool> sendTextMessage(String text) async {
    if (!_isReady || _dataChannel == null) {
      onError?.call('Data channel not ready');
      return false;
    }

    try {
      final message = DataChannelMessage(
        type: 'text',
        data: {'content': text},
      );
      _dataChannel!.send(RTCDataChannelMessage.fromText(
        jsonEncode(message.toJson()),
      ));
      return true;
    } catch (e) {
      print('Error sending text message: $e');
      onError?.call('Failed to send message: $e');
      return false;
    }
  }

  /// Send clipboard content
  Future<bool> sendClipboard(String content) async {
    if (!_isReady || _dataChannel == null) {
      onError?.call('Data channel not ready');
      return false;
    }

    try {
      final message = DataChannelMessage(
        type: 'clipboard',
        data: {
          'content': content,
          'contentType': 'text/plain',
        },
      );
      _dataChannel!.send(RTCDataChannelMessage.fromText(
        jsonEncode(message.toJson()),
      ));
      return true;
    } catch (e) {
      print('Error sending clipboard: $e');
      onError?.call('Failed to send clipboard: $e');
      return false;
    }
  }

  /// Send file metadata for chunked transfer
  Future<bool> sendFileMetadata({
    required String fileName,
    required int fileSize,
    required String mimeType,
    required String transferId,
  }) async {
    if (!_isReady || _dataChannel == null) {
      onError?.call('Data channel not ready');
      return false;
    }

    try {
      final message = DataChannelMessage(
        type: 'file_start',
        data: {
          'fileName': fileName,
          'fileSize': fileSize,
          'mimeType': mimeType,
          'transferId': transferId,
          'chunkSize': 16384, // 16KB chunks
        },
      );
      _dataChannel!.send(RTCDataChannelMessage.fromText(
        jsonEncode(message.toJson()),
      ));
      return true;
    } catch (e) {
      print('Error sending file metadata: $e');
      onError?.call('Failed to send file metadata: $e');
      return false;
    }
  }

  /// Send file chunk (binary data)
  Future<bool> sendFileChunk({
    required String transferId,
    required Uint8List chunkData,
    required int chunkIndex,
    required int totalChunks,
  }) async {
    if (!_isReady || _dataChannel == null) {
      onError?.call('Data channel not ready');
      return false;
    }

    try {
      // Create a message with metadata before binary data
      final metadata = jsonEncode({
        'type': 'file_chunk',
        'transferId': transferId,
        'chunkIndex': chunkIndex,
        'totalChunks': totalChunks,
      });

      // Send as text message with base64 encoded data
      final base64Data = base64Encode(chunkData);
      final message = DataChannelMessage(
        type: 'file_chunk',
        data: {
          'transferId': transferId,
          'chunkIndex': chunkIndex,
          'totalChunks': totalChunks,
          'data': base64Data,
        },
      );

      _dataChannel!.send(RTCDataChannelMessage.fromText(
        jsonEncode(message.toJson()),
      ));
      return true;
    } catch (e) {
      print('Error sending file chunk: $e');
      onError?.call('Failed to send chunk: $e');
      return false;
    }
  }

  /// Acknowledge file chunk received
  Future<bool> acknowledgeChunk({
    required String transferId,
    required int chunkIndex,
  }) async {
    if (!_isReady || _dataChannel == null) {
      onError?.call('Data channel not ready');
      return false;
    }

    try {
      final message = DataChannelMessage(
        type: 'file_ack',
        data: {
          'transferId': transferId,
          'chunkIndex': chunkIndex,
        },
      );
      _dataChannel!.send(RTCDataChannelMessage.fromText(
        jsonEncode(message.toJson()),
      ));
      return true;
    } catch (e) {
      print('Error acknowledging chunk: $e');
      onError?.call('Failed to acknowledge chunk: $e');
      return false;
    }
  }

  /// Signal file transfer completion
  Future<bool> completeFileTransfer({
    required String transferId,
    required String checksum,
  }) async {
    if (!_isReady || _dataChannel == null) {
      onError?.call('Data channel not ready');
      return false;
    }

    try {
      final message = DataChannelMessage(
        type: 'file_complete',
        data: {
          'transferId': transferId,
          'checksum': checksum,
        },
      );
      _dataChannel!.send(RTCDataChannelMessage.fromText(
        jsonEncode(message.toJson()),
      ));
      return true;
    } catch (e) {
      print('Error completing file transfer: $e');
      onError?.call('Failed to complete transfer: $e');
      return false;
    }
  }

  /// Check if data channel is ready
  bool get isReady => _isReady;

  /// Get current buffered amount
  int? getBufferedAmount() => _dataChannel?.bufferedAmount;

  /// Dispose resources
  Future<void> dispose() async {
    _dataChannel = null;
    _isReady = false;
  }
}
