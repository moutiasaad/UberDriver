class RideModel {
  final int id;
  final PickupLocation pickup;
  final DropoffLocation dropoff;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final int? actualDurationMinutes;
  final FareModel fare;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String statusText;
  final String statusColor;
  final bool isCancellable;
  final String? cancelledBy;
  final String? cancellationReason;
  final TimestampsModel timestamps;
  final CustomerModel customer;

  RideModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    this.actualDurationMinutes,
    required this.fare,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.statusText,
    required this.statusColor,
    required this.isCancellable,
    this.cancelledBy,
    this.cancellationReason,
    required this.timestamps,
    required this.customer,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as int,
      pickup: PickupLocation.fromJson(json['pickup'] as Map<String, dynamic>),
      dropoff: DropoffLocation.fromJson(json['dropoff'] as Map<String, dynamic>),
      distanceKm: _parseDouble(json['distance_km']),
      estimatedDurationMinutes: _parseInt(json['estimated_duration_minutes']),
      actualDurationMinutes: json['actual_duration_minutes'] as int?,
      fare: FareModel.fromJson(json['fare'] as Map<String, dynamic>),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      status: json['status'] as String? ?? 'pending',
      statusText: json['status_text'] as String? ?? 'Pending',
      statusColor: json['status_color'] as String? ?? 'warning',
      isCancellable: json['is_cancellable'] == true,
      cancelledBy: json['cancelled_by'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      timestamps: TimestampsModel.fromJson(json['timestamps'] as Map<String, dynamic>),
      customer: CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup': pickup.toJson(),
      'dropoff': dropoff.toJson(),
      'distance_km': distanceKm,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'actual_duration_minutes': actualDurationMinutes,
      'fare': fare.toJson(),
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'status': status,
      'status_text': statusText,
      'status_color': statusColor,
      'is_cancellable': isCancellable,
      'cancelled_by': cancelledBy,
      'cancellation_reason': cancellationReason,
      'timestamps': timestamps.toJson(),
      'customer': customer.toJson(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class PickupLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? time;

  PickupLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.time,
  });

  factory PickupLocation.fromJson(Map<String, dynamic> json) {
    return PickupLocation(
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      address: json['address'] as String? ?? '',
      time: json['time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'time': time,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class DropoffLocation {
  final double latitude;
  final double longitude;
  final String address;

  DropoffLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory DropoffLocation.fromJson(Map<String, dynamic> json) {
    return DropoffLocation(
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class FareModel {
  final double baseFare;
  final double distanceFare;
  final double totalFare;
  final double discountAmount;
  final double finalAmount;
  final int pointsUsed;
  final double pointsDiscount;

  FareModel({
    required this.baseFare,
    required this.distanceFare,
    required this.totalFare,
    required this.discountAmount,
    required this.finalAmount,
    required this.pointsUsed,
    required this.pointsDiscount,
  });

  factory FareModel.fromJson(Map<String, dynamic> json) {
    return FareModel(
      baseFare: _parseDouble(json['base_fare']),
      distanceFare: _parseDouble(json['distance_fare']),
      totalFare: _parseDouble(json['total_fare']),
      discountAmount: _parseDouble(json['discount_amount']),
      finalAmount: _parseDouble(json['final_amount']),
      pointsUsed: _parseInt(json['points_used']),
      pointsDiscount: _parseDouble(json['points_discount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'total_fare': totalFare,
      'discount_amount': discountAmount,
      'final_amount': finalAmount,
      'points_used': pointsUsed,
      'points_discount': pointsDiscount,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class TimestampsModel {
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  TimestampsModel({
    this.createdAt,
    this.acceptedAt,
    this.driverArrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory TimestampsModel.fromJson(Map<String, dynamic> json) {
    return TimestampsModel(
      createdAt: _parseDateTime(json['created_at']),
      acceptedAt: _parseDateTime(json['accepted_at']),
      driverArrivedAt: _parseDateTime(json['driver_arrived_at']),
      startedAt: _parseDateTime(json['started_at']),
      completedAt: _parseDateTime(json['completed_at']),
      cancelledAt: _parseDateTime(json['cancelled_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'driver_arrived_at': driverArrivedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? profileImage;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.profileImage,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'profile_image': profileImage,
    };
  }
}
