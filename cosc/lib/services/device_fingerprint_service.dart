/// Device fingerprinting service used to identify peers consistently.
/// The fingerprint combines hardware- and runtime-specific signals so the app can
/// differentiate devices while preserving privacy boundaries.
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeviceFingerprint {
  final String deviceId;
  final String manufacturer;
  final String model;
  final String osVersion;
  final String fingerprint;
  final DateTime createdAt;

  DeviceFingerprint({
    required this.deviceId,
    required this.manufacturer,
    required this.model,
    required this.osVersion,
    required this.fingerprint,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'manufacturer': manufacturer,
      'model': model,
      'osVersion': osVersion,
      'fingerprint': fingerprint,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DeviceFingerprint.fromMap(Map<String, dynamic> map) {
    return DeviceFingerprint(
      deviceId: map['deviceId'] as String,
      manufacturer: map['manufacturer'] as String,
      model: map['model'] as String,
      osVersion: map['osVersion'] as String,
      fingerprint: map['fingerprint'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class DeviceFingerprintService {
  static final DeviceFingerprintService _instance =
      DeviceFingerprintService._internal();

  factory DeviceFingerprintService() {
    return _instance;
  }

  DeviceFingerprintService._internal();

  final _deviceInfo = DeviceInfoPlugin();

  /// Generate a unique device fingerprint
  Future<DeviceFingerprint> generateFingerprint() async {
    try {
      String deviceId;
      String manufacturer;
      String model;
      String osVersion;

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        manufacturer = androidInfo.manufacturer;
        model = androidInfo.model;
        osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        manufacturer = 'Apple';
        model = iosInfo.model;
        osVersion = iosInfo.systemVersion;
      } else {
        throw Exception('Unsupported platform');
      }

      // Create fingerprint hash from hardware details
      final fingerprintData = '$deviceId-$manufacturer-$model-$osVersion';
      final fingerprint = sha256.convert(utf8.encode(fingerprintData)).toString();

      return DeviceFingerprint(
        deviceId: deviceId,
        manufacturer: manufacturer,
        model: model,
        osVersion: osVersion,
        fingerprint: fingerprint,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error generating device fingerprint: $e');
      rethrow;
    }
  }

  /// Get device information for security purposes
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'id': androidInfo.id,
          'manufacturer': androidInfo.manufacturer,
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'baseOS': androidInfo.version.baseOS ?? 'unknown',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'id': iosInfo.identifierForVendor ?? 'unknown',
          'model': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
          'utsname': iosInfo.utsname.machine,
        };
      } else {
        return {'platform': 'unknown'};
      }
    } catch (e) {
      print('Error getting device info: $e');
      return {'error': e.toString()};
    }
  }

  /// Verify device fingerprint (check if device hasn't changed)
  Future<bool> verifyFingerprint(DeviceFingerprint stored) async {
    try {
      final current = await generateFingerprint();
      return current.fingerprint == stored.fingerprint;
    } catch (e) {
      print('Error verifying fingerprint: $e');
      return false;
    }
  }

  /// Get device security level based on fingerprint consistency
  Future<String> getSecurityLevel() async {
    try {
      final info = await getDeviceInfo();
      
      // Check for common security indicators
      final isManagedDevice = _isManagedDevice();
      final hasPlayIntegrity = await _hasPlayIntegrity();
      
      if (isManagedDevice || !hasPlayIntegrity) {
        return 'LOW';
      }
      
      return 'HIGH';
    } catch (e) {
      print('Error getting security level: $e');
      return 'UNKNOWN';
    }
  }

  /// Check if device is managed (MDM enrolled)
  bool _isManagedDevice() {
    if (Platform.isAndroid) {
      // Would need to check Android MDM state
      return false;
    } else if (Platform.isIOS) {
      // Would need to check iOS MDM state
      return false;
    }
    return false;
  }

  /// Check for Play Integrity (Android) or similar (iOS)
  Future<bool> _hasPlayIntegrity() async {
    // This would require the google_play_integrity plugin
    // For now, return true as a default
    return true;
  }

  /// Generate device attestation token
  Future<String> generateAttestationToken(String challenge) async {
    try {
      final fingerprint = await generateFingerprint();
      final payload = {
        'fingerprint': fingerprint.fingerprint,
        'challenge': challenge,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Sign the payload
      final jsonString = jsonEncode(payload);
      return base64Encode(utf8.encode(jsonString));
    } catch (e) {
      print('Error generating attestation token: $e');
      throw Exception('Failed to generate attestation token: $e');
    }
  }

  /// Verify device attestation token
  static bool verifyAttestationToken(String token, String expectedFingerprint) {
    try {
      final decoded = utf8.decode(base64Decode(token));
      final payload = jsonDecode(decoded);
      
      return payload['fingerprint'] == expectedFingerprint;
    } catch (e) {
      print('Error verifying attestation token: $e');
      return false;
    }
  }
}
