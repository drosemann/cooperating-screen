/// Device model used across the app to describe a peer endpoint.
/// It stores the serial number, display metadata, and activity timestamps that
/// are used when searching for devices, pairing them, and rendering the UI.
class Device {
  final String id;
  final String deviceSerial;
  final String deviceName;
  final String deviceType;
  final DateTime createdAt;
  final DateTime? lastSeen;

  Device({
    required this.id,
    required this.deviceSerial,
    required this.deviceName,
    required this.deviceType,
    required this.createdAt,
    this.lastSeen,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      deviceSerial: json['device_serial'] as String,
      deviceName: json['device_name'] as String,
      deviceType: json['device_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_serial': deviceSerial,
      'device_name': deviceName,
      'device_type': deviceType,
      'created_at': createdAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  Device copyWith({
    String? id,
    String? deviceSerial,
    String? deviceName,
    String? deviceType,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return Device(
      id: id ?? this.id,
      deviceSerial: deviceSerial ?? this.deviceSerial,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
