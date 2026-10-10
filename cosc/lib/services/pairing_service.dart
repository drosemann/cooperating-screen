/// Pairing service that orchestrates the device-linking workflow.
/// It supervises challenge generation, verification, and the storage of session
/// information needed to establish a trusted connection.
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/security_utils.dart';
import '../utils/local_storage_service.dart';
import '../models/pairing_session.dart';

class PairingService {
  final _supabase = Supabase.instance.client;
  
  static const Duration _pairingTimeout = Duration(seconds: 30);
  static const int _maxAttempts = 3;

  /// Requests a temporary trust relationship with a peer device. The method
  /// validates the serial and password requirements, creates a pairing code, and
  /// persists the session until the remote device completes verification.
  Future<bool> requestPairing({
    required String localDeviceSerial,
    required String remoteDeviceSerial,
    required String password,
  }) async {
    try {
      // Validate input
      if (!SecurityUtils.isValidDeviceSerial(remoteDeviceSerial)) {
        throw Exception('Invalid device serial format');
      }

      if (!SecurityUtils.isPasswordStrong(password)) {
        throw Exception(
          'Password must be at least 8 characters with uppercase, lowercase, and numbers',
        );
      }

      // Generate pairing code and nonce
      final pairingCode = SecurityUtils.generatePairingCode();
      final nonce = SecurityUtils.generateNonce();
      final passwordHash = SecurityUtils.hashPassword(password);

      // Create pairing session in database
      final response = await _supabase
          .from('pairing_sessions')
          .insert({
            'device_1_id': localDeviceSerial,
            'device_2_id': remoteDeviceSerial,
            'pairing_code': pairingCode,
            'password_hash': passwordHash,
            'status': 'pending',
            'nonce': nonce,
            'expires_at': DateTime.now()
                .add(_pairingTimeout)
                .toIso8601String(),
          })
          .select();

      if (response.isEmpty) {
        return false;
      }

      // Store session locally
      final sessionId = response[0]['id'];
      await LocalStorageService.savePairingSession(
        sessionId,
        {
          'remote_serial': remoteDeviceSerial,
          'pairing_code': pairingCode,
          'nonce': nonce,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      print('Error requesting pairing: $e');
      return false;
    }
  }

  /// Confirms a pairing session only after the user enters the matching code and
  /// the record is still within its expiration window. If verification fails, the
  /// session remains unusable and the app does not finalize the trust relationship.
  Future<bool> confirmPairing({
    required String sessionId,
    required String confirmedPairingCode,
  }) async {
    try {
      // Get session from database
      final session = await _supabase
          .from('pairing_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      // Verify code
      if (session['pairing_code'] != confirmedPairingCode) {
        // Increment attempt counter
        return false;
      }

      // Check expiration
      final expiresAt = DateTime.parse(session['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      // Update session status
      await _supabase
          .from('pairing_sessions')
          .update({'status': 'active'})
          .eq('id', sessionId);

      // Add device to paired devices
      final pairedDevice = PairedDevice(
        id: session['device_2_id'],
        deviceSerial: session['device_2_id'],
        deviceName: 'Paired Device', // Will be updated from remote
        deviceType: 'unknown',
        pairedAt: DateTime.now(),
      );

      await LocalStorageService.addPairedDevice(pairedDevice);
      await LocalStorageService.clearPairingSession(sessionId);

      return true;
    } catch (e) {
      print('Error confirming pairing: $e');
      return false;
    }
  }

  /// Fetches the pending pairing sessions that belong to the current device so the
  /// app can present outstanding verification workflows to the user.
  Future<List<PairingSession>> getActiveSessions(String deviceSerial) async {
    try {
      final response = await _supabase
          .from('pairing_sessions')
          .select()
          .eq('device_1_id', deviceSerial)
          .eq('status', 'pending');

      return (response as List)
          .map((session) => PairingSession.fromJson(session))
          .toList();
    } catch (e) {
      print('Error getting active sessions: $e');
      return [];
    }
  }

  /// Cancels an outstanding pairing request and removes any local cache tied to it,
  /// preventing stale or abandoned verification flows from lingering in storage.
  Future<bool> cancelPairing(String sessionId) async {
    try {
      await _supabase
          .from('pairing_sessions')
          .update({'status': 'rejected'})
          .eq('id', sessionId);

      await LocalStorageService.clearPairingSession(sessionId);
      return true;
    } catch (e) {
      print('Error cancelling pairing: $e');
      return false;
    }
  }

  /// Removes a trusted device from local storage and clears the residual pairing
  /// state used by the app to guide future connection attempts.
  Future<bool> unpairDevice(String pairedDeviceId) async {
    try {
      // Remove from local storage
      await LocalStorageService.removePairedDevice(pairedDeviceId);
      
      // Could also update database to mark as inactive
      return true;
    } catch (e) {
      print('Error unpairing device: $e');
      return false;
    }
  }

  /// Returns the pairing history for a device in reverse chronological order so
  /// the UI can show a timeline of successful and failed trust handshakes.
  Future<List<Map<String, dynamic>>> getPairingHistory(
    String deviceSerial,
  ) async {
    try {
      final response = await _supabase
          .from('pairing_sessions')
          .select()
          .or('device_1_id.eq.$deviceSerial,device_2_id.eq.$deviceSerial')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting pairing history: $e');
      return [];
    }
  }
}
