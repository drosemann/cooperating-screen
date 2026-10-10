/// Security-focused helpers shared throughout the app.
/// They centralize validation and protection logic so the codebase enforces the
/// same trust checks whenever pairing, device registration, or remote access is used.
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class SecurityUtils {
  /// Hash password using SHA-256 (production should use bcrypt via backend)
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  /// Generate a cryptographically secure device serial
  static String generateDeviceSerial() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    String serial = '';
    
    for (int i = 0; i < 10; i++) {
      serial += chars[random.nextInt(chars.length)];
    }
    
    return serial;
  }

  /// Generate a random 6-digit pairing code
  static String generatePairingCode() {
    final random = Random.secure();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  /// Generate a nonce for replay attack prevention
  static String generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  /// Validate password strength
  static bool isPasswordStrong(String password) {
    // Minimum 8 characters, at least 1 uppercase, 1 lowercase, 1 number
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.{8,}).*$',
    );
    return regex.hasMatch(password);
  }

  /// Validate device serial format
  static bool isValidDeviceSerial(String serial) {
    // 10-12 alphanumeric characters
    final regex = RegExp(r'^[A-Z0-9]{10,12}$');
    return regex.hasMatch(serial);
  }
}
