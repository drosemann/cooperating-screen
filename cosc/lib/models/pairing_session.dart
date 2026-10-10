/// Pairing session data model for temporary device-linking handshakes.
/// The session stores the two parties involved, the generated pairing code, and
/// the expiry window used to reject stale or unauthorized attempts.
class PairingSession {
  final String id;
  final String device1Id;
  final String device2Id;
  final String pairingCode;
  final String passwordHash;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;

  PairingSession({
    required this.id,
    required this.device1Id,
    required this.device2Id,
    required this.pairingCode,
    required this.passwordHash,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  factory PairingSession.fromJson(Map<String, dynamic> json) {
    return PairingSession(
      id: json['id'] as String,
      device1Id: json['device_1_id'] as String,
      device2Id: json['device_2_id'] as String,
      pairingCode: json['pairing_code'] as String,
      passwordHash: json['password_hash'] as String,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_1_id': device1Id,
      'device_2_id': device2Id,
      'pairing_code': pairingCode,
      'password_hash': passwordHash,
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == 'active' && !isExpired;
}
