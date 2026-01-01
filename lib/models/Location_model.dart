class LocationModel {
  final int id;
  final int? driverId;
  final int? driverOrderId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime? createdAt;

  LocationModel({
    required this.id,
    this.driverId,
    this.driverOrderId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.createdAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      driverId: json['driver_id'],
      driverOrderId: json['driver_order_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: json['accuracy'] == null ? null : (json['accuracy'] as num).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'driver_id': driverId,
    'driver_order_id': driverOrderId,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'created_at': createdAt?.toIso8601String(),
  };
}
