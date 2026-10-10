/// Local persistence layer for device metadata and small application state.
/// The service stores paired devices and runtime preferences in a lightweight
/// on-device database so the app can restore known peers between launches.
import 'package:hive_flutter/hive_flutter.dart';

class PairedDevice {
  final String id;
  final String deviceSerial;
  final String deviceName;
  final String deviceType;
  final DateTime pairedAt;
  final bool isConnected;

  PairedDevice({
    required this.id,
    required this.deviceSerial,
    required this.deviceName,
    required this.deviceType,
    required this.pairedAt,
    this.isConnected = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_serial': deviceSerial,
      'device_name': deviceName,
      'device_type': deviceType,
      'paired_at': pairedAt.toIso8601String(),
      'is_connected': isConnected,
    };
  }

  static PairedDevice fromMap(Map<String, dynamic> map) {
    return PairedDevice(
      id: map['id'] as String,
      deviceSerial: map['device_serial'] as String,
      deviceName: map['device_name'] as String,
      deviceType: map['device_type'] as String,
      pairedAt: DateTime.parse(map['paired_at'] as String),
      isConnected: map['is_connected'] as bool? ?? false,
    );
  }

  PairedDevice copyWith({
    String? id,
    String? deviceSerial,
    String? deviceName,
    String? deviceType,
    DateTime? pairedAt,
    bool? isConnected,
  }) {
    return PairedDevice(
      id: id ?? this.id,
      deviceSerial: deviceSerial ?? this.deviceSerial,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      pairedAt: pairedAt ?? this.pairedAt,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class LocalStorageService {
  static const String _pairedDevicesBox = 'paired_devices';
  static const String _pairingSessionsBox = 'pairing_sessions';
  static const String _appSettingsBox = 'app_settings';

  /// Initialize Hive and open all boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters if using custom types
    // Hive.registerAdapter(PairedDeviceAdapter());
    
    // Open boxes
    await Hive.openBox(_pairedDevicesBox);
    await Hive.openBox(_pairingSessionsBox);
    await Hive.openBox(_appSettingsBox);
  }

  /// Get paired devices
  static Future<List<PairedDevice>> getPairedDevices() async {
    try {
      final box = Hive.box(_pairedDevicesBox);
      final devices = <PairedDevice>[];
      
      for (final key in box.keys) {
        final data = box.get(key);
        if (data is Map) {
          devices.add(PairedDevice.fromMap(Map<String, dynamic>.from(data)));
        }
      }
      
      return devices;
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }

  /// Add a paired device
  static Future<void> addPairedDevice(PairedDevice device) async {
    try {
      final box = Hive.box(_pairedDevicesBox);
      await box.put(device.id, device.toMap());
    } catch (e) {
      print('Error adding paired device: $e');
    }
  }

  /// Remove a paired device
  static Future<void> removePairedDevice(String deviceId) async {
    try {
      final box = Hive.box(_pairedDevicesBox);
      await box.delete(deviceId);
    } catch (e) {
      print('Error removing paired device: $e');
    }
  }

  /// Get a specific paired device
  static Future<PairedDevice?> getPairedDevice(String deviceId) async {
    try {
      final box = Hive.box(_pairedDevicesBox);
      final data = box.get(deviceId);
      
      if (data is Map) {
        return PairedDevice.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      print('Error getting paired device: $e');
      return null;
    }
  }

  /// Save pairing session temporarily
  static Future<void> savePairingSession(String sessionId, Map<String, dynamic> data) async {
    try {
      final box = Hive.box(_pairingSessionsBox);
      await box.put(sessionId, data);
    } catch (e) {
      print('Error saving pairing session: $e');
    }
  }

  /// Get pairing session
  static Future<Map<String, dynamic>?> getPairingSession(String sessionId) async {
    try {
      final box = Hive.box(_pairingSessionsBox);
      final data = box.get(sessionId);
      
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      print('Error getting pairing session: $e');
      return null;
    }
  }

  /// Clear pairing session
  static Future<void> clearPairingSession(String sessionId) async {
    try {
      final box = Hive.box(_pairingSessionsBox);
      await box.delete(sessionId);
    } catch (e) {
      print('Error clearing pairing session: $e');
    }
  }

  /// Save app setting
  static Future<void> saveSetting(String key, dynamic value) async {
    try {
      final box = Hive.box(_appSettingsBox);
      await box.put(key, value);
    } catch (e) {
      print('Error saving setting: $e');
    }
  }

  /// Get app setting
  static Future<dynamic> getSetting(String key) async {
    try {
      final box = Hive.box(_appSettingsBox);
      return box.get(key);
    } catch (e) {
      print('Error getting setting: $e');
      return null;
    }
  }
}
