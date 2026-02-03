class DriverProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? plateNumber;
  final String? licenseNumber;
  final String? licenseExpiry;
  final bool isOnline;
  final bool isAvailable;
  final bool isApproved;
  final String status;
  final double ratingAverage;
  final int totalTrips;
  final double walletBalance;
  final String? language;
  final double? currentLatitude;
  final double? currentLongitude;
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final DateTime? createdAt;

  DriverProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleColor,
    this.plateNumber,
    this.licenseNumber,
    this.licenseExpiry,
    required this.isOnline,
    required this.isAvailable,
    required this.isApproved,
    required this.status,
    required this.ratingAverage,
    required this.totalTrips,
    required this.walletBalance,
    this.language,
    this.currentLatitude,
    this.currentLongitude,
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    this.createdAt,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'],
      vehicleType: json['vehicle_type'],
      vehicleModel: json['vehicle_model'],
      vehicleColor: json['vehicle_color'],
      plateNumber: json['plate_number'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'],
      isOnline: json['is_online'] ?? false,
      isAvailable: json['is_available'] ?? false,
      isApproved: json['is_approved'] ?? false,
      status: json['status'] ?? '',
      ratingAverage: (json['rating_average'] ?? 0).toDouble(),
      totalTrips: json['total_trips'] ?? 0,
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      language: json['language'],
      currentLatitude: json['current_latitude'] != null
          ? double.tryParse(json['current_latitude'].toString())
          : null,
      currentLongitude: json['current_longitude'] != null
          ? double.tryParse(json['current_longitude'].toString())
          : null,
      todayEarnings: (json['today_earnings'] ?? 0).toDouble(),
      weekEarnings: (json['week_earnings'] ?? 0).toDouble(),
      monthEarnings: (json['month_earnings'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'vehicle_color': vehicleColor,
      'plate_number': plateNumber,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'is_online': isOnline,
      'is_available': isAvailable,
      'is_approved': isApproved,
      'status': status,
      'rating_average': ratingAverage,
      'total_trips': totalTrips,
      'wallet_balance': walletBalance,
      'language': language,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'today_earnings': todayEarnings,
      'week_earnings': weekEarnings,
      'month_earnings': monthEarnings,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get status translation key
  String get statusTranslationKey {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'driverStatus.approved';
      case 'pending':
        return 'driverStatus.pending';
      case 'rejected':
        return 'driverStatus.rejected';
      case 'suspended':
        return 'driverStatus.suspended';
      default:
        return status;
    }
  }

  /// Get vehicle type translation key
  String get vehicleTypeTranslationKey {
    switch (vehicleType?.toLowerCase()) {
      case 'sedan':
        return 'vehicleType.sedan';
      case 'suv':
        return 'vehicleType.suv';
      case 'van':
        return 'vehicleType.van';
      case 'motorcycle':
        return 'vehicleType.motorcycle';
      default:
        return vehicleType ?? '';
    }
  }
}
