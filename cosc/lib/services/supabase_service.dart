/// Supabase-backed service for identity and persistence needs.
/// It centralizes database reads and writes used to register devices, store state,
/// and keep configuration synchronized with the hosted backend.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SupabaseService {
  final _storage = GetStorage();
  final _supabase = Supabase.instance.client;
  
  static const String _deviceSerialKey = 'device_serial';
  static const String _deviceNameKey = 'device_name';
  static const String _pairedDevicesKey = 'paired_devices';
  
  Future<void> initialize() async {
    await GetStorage.init();
  }
  
  /// Generate a unique device serial (8-12 alphanumeric characters)
  String generateDeviceSerial() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecond;
    String serial = '';
    for (int i = 0; i < 10; i++) {
      serial += chars[(random + i) % chars.length];
    }
    return serial;
  }
  
  /// Register a new device in Supabase
  Future<bool> registerDevice({
    required String deviceName,
    required String deviceType,
  }) async {
    try {
      final deviceSerial = generateDeviceSerial();
      
      final response = await _supabase.from('users').insert({
        'device_serial': deviceSerial,
        'device_name': deviceName,
        'device_type': deviceType,
      }).select();
      
      if (response.isNotEmpty) {
        _storage.write(_deviceSerialKey, deviceSerial);
        _storage.write(_deviceNameKey, deviceName);
        return true;
      }
      return false;
    } catch (e) {
      print('Error registering device: $e');
      return false;
    }
  }
  
  /// Check if device is already registered
  Future<bool> isDeviceRegistered() async {
    return _storage.hasData(_deviceSerialKey);
  }
  
  /// Get stored device serial
  String? getDeviceSerial() {
    return _storage.read(_deviceSerialKey);
  }
  
  /// Get stored device name
  String? getDeviceName() {
    return _storage.read(_deviceNameKey);
  }
  
  /// Hash password using bcrypt-like approach (simple for now)
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
  
  /// Create a pairing session
  Future<bool> createPairingSession({
    required String remoteDev Serial,
    required String password,
  }) async {
    try {
      final localSerial = getDeviceSerial();
      if (localSerial == null) return false;
      
      final passwordHash = hashPassword(password);
      final pairingCode = _generatePairingCode();
      
      // This would be implemented with actual device IDs from database
      // For now, returning placeholder
      return true;
    } catch (e) {
      print('Error creating pairing session: $e');
      return false;
    }
  }
  
  /// Generate 6-digit pairing code
  String _generatePairingCode() {
    final random = DateTime.now().millisecond;
    return (random % 1000000).toString().padLeft(6, '0');
  }
  
  /// Get list of paired devices
  Future<List<Map<String, dynamic>>> getPairedDevices() async {
    try {
      final paired = _storage.read(_pairedDevicesKey) as List<dynamic>? ?? [];
      return List<Map<String, dynamic>>.from(paired);
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }
  
  /// Add a paired device to local storage
  Future<void> addPairedDevice(Map<String, dynamic> device) async {
    try {
      final paired = await getPairedDevices();
      paired.add(device);
      _storage.write(_pairedDevicesKey, paired);
    } catch (e) {
      print('Error adding paired device: $e');
    }
  }
}
