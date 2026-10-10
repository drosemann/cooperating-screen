/// Screen-transfer model describing a completed remote-share session.
/// It captures who sent content, how long the transfer lasted, and the amount of
/// data moved so developers can reason about diagnostics and session history.
class ScreenTransfer {
  final String id;
  final String fromDeviceId;
  final String toDeviceId;
  final int durationSeconds;
  final double dataTransferredMb;
  final DateTime createdAt;

  ScreenTransfer({
    required this.id,
    required this.fromDeviceId,
    required this.toDeviceId,
    required this.durationSeconds,
    required this.dataTransferredMb,
    required this.createdAt,
  });

  factory ScreenTransfer.fromJson(Map<String, dynamic> json) {
    return ScreenTransfer(
      id: json['id'] as String,
      fromDeviceId: json['from_device_id'] as String,
      toDeviceId: json['to_device_id'] as String,
      durationSeconds: json['duration_seconds'] as int,
      dataTransferredMb: (json['data_transferred_mb'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_device_id': fromDeviceId,
      'to_device_id': toDeviceId,
      'duration_seconds': durationSeconds,
      'data_transferred_mb': dataTransferredMb,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
