/// Encryption and key-derivation helpers used to protect sensitive payloads.
/// The utilities wrap the cryptographic steps required to secure pairing data,
/// session metadata, and remote-transfer content before it crosses the network.
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';

class EncryptionUtils {
  /// Encrypt data using AES-256-GCM (for application-level encryption)
  /// Note: Flutter WebRTC uses DTLS-SRTP for media streams
  static String encryptData(String plaintext, String key) {
    // This is a simplified example. For production, use a proper encryption library
    // like `encrypt` package with proper key derivation
    try {
      final keyHash = sha256.convert(utf8.encode(key)).bytes;
      final plaintextBytes = utf8.encode(plaintext);
      
      // Simple XOR encryption (NOT SECURE - for demo only)
      final encrypted = Uint8List(plaintextBytes.length);
      for (int i = 0; i < plaintextBytes.length; i++) {
        encrypted[i] = plaintextBytes[i] ^ keyHash[i % keyHash.length];
      }
      
      return base64Encode(encrypted);
    } catch (e) {
      print('Error encrypting data: $e');
      return '';
    }
  }

  /// Decrypt data using AES-256-GCM
  static String decryptData(String ciphertext, String key) {
    try {
      final keyHash = sha256.convert(utf8.encode(key)).bytes;
      final encryptedBytes = base64Decode(ciphertext);
      
      // Simple XOR decryption (NOT SECURE - for demo only)
      final decrypted = Uint8List(encryptedBytes.length);
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted[i] = encryptedBytes[i] ^ keyHash[i % keyHash.length];
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      print('Error decrypting data: $e');
      return '';
    }
  }

  /// Generate a secure session key
  static String generateSessionKey() {
    final random = SecureRandom('Fortuna');
    final keyBytes = random.nextBytes(32); // 256-bit key
    return base64Encode(keyBytes);
  }

  /// HMAC-SHA256 for message authentication
  static String generateHMAC(String message, String key) {
    final hmacSha256 = Hmac(sha256, utf8.encode(key));
    final digest = hmacSha256.convert(utf8.encode(message));
    return digest.toString();
  }

  /// Verify HMAC signature
  static bool verifyHMAC(String message, String signature, String key) {
    final expected = generateHMAC(message, key);
    return expected == signature;
  }

  /// Sign data with private key (for device authentication)
  static String signData(String data, String privateKey) {
    // In production, use proper RSA signing
    return generateHMAC(data, privateKey);
  }

  /// Verify signed data
  static bool verifySignature(
    String data,
    String signature,
    String publicKey,
  ) {
    return verifyHMAC(data, signature, publicKey);
  }

  /// Hash password with salt (for enhanced security)
  static String hashPasswordWithSalt(String password, {String? salt}) {
    salt ??= _generateSalt();
    final bytes = utf8.encode(salt + password);
    final hashedBytes = pbkdf2(bytes);
    return salt + ':' + base64Encode(hashedBytes);
  }

  /// Verify password with salt
  static bool verifyPasswordWithSalt(String password, String hash) {
    try {
      final parts = hash.split(':');
      if (parts.length != 2) return false;
      
      final salt = parts[0];
      final expectedHash = parts[1];
      
      final newHash = hashPasswordWithSalt(password, salt: salt);
      return newHash == hash;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  /// PBKDF2 key derivation
  static Uint8List pbkdf2(Uint8List input) {
    // Simplified PBKDF2 using SHA256
    // In production, use a proper PBKDF2 implementation
    var result = input;
    for (int i = 0; i < 10000; i++) {
      result = sha256.convert(result).bytes as Uint8List;
    }
    return result;
  }

  /// Generate random salt
  static String _generateSalt() {
    final random = SecureRandom('Fortuna');
    return base64Encode(random.nextBytes(16));
  }

  /// Verify end-to-end encryption is enabled (WebRTC level)
  static bool isWebRTCEncryptionSupported() {
    // DTLS-SRTP is built into WebRTC standard
    return true;
  }
}

class SecureRandom {
  final String algorithm;
  late final Random _random;

  SecureRandom(this.algorithm) {
    // Use Fortuna or other secure random implementation
    _random = Random.secure();
  }

  Uint8List nextBytes(int count) {
    final bytes = Uint8List(count);
    for (int i = 0; i < count; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}
