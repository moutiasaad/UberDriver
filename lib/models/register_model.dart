class RegisterModel {
  String? email;
  String? fullName;
  String? phone;
  String? otp;
  String? token;
  int? userId;

  // Additional driver fields from API response
  String? profileImage;
  String? vehicleType;
  String? vehicleModel;
  String? vehicleColor;
  String? plateNumber;
  String? licenseNumber;
  String? licenseExpiry;
  bool? isOnline;
  bool? isAvailable;
  bool? isApproved;
  String? status;
  double? ratingAverage;
  int? totalTrips;
  double? walletBalance;
  String? language;
  double? todayEarnings;
  double? weekEarnings;
  double? monthEarnings;

  RegisterModel({
    this.email,
    this.fullName,
    this.phone,
    this.otp,
    this.token,
    this.userId,
    this.profileImage,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleColor,
    this.plateNumber,
    this.licenseNumber,
    this.licenseExpiry,
    this.isOnline,
    this.isAvailable,
    this.isApproved,
    this.status,
    this.ratingAverage,
    this.totalTrips,
    this.walletBalance,
    this.language,
    this.todayEarnings,
    this.weekEarnings,
    this.monthEarnings,
  });

  // Factory constructor to create from API response
  factory RegisterModel.fromDriverResponse(Map<String, dynamic> json) {
    return RegisterModel(
      userId: json['id'],
      fullName: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      vehicleType: json['vehicle_type'],
      vehicleModel: json['vehicle_model'],
      vehicleColor: json['vehicle_color'],
      plateNumber: json['plate_number'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'],
      isOnline: json['is_online'],
      isAvailable: json['is_available'],
      isApproved: json['is_approved'],
      status: json['status'],
      ratingAverage: json['rating_average']?.toDouble(),
      totalTrips: json['total_trips'],
      walletBalance: json['wallet_balance']?.toDouble(),
      language: json['language'],
      todayEarnings: json['today_earnings']?.toDouble(),
      weekEarnings: json['week_earnings']?.toDouble(),
      monthEarnings: json['month_earnings']?.toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'name': fullName,
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
      'today_earnings': todayEarnings,
      'week_earnings': weekEarnings,
      'month_earnings': monthEarnings,
    };
  }

  @override
  String toString() {
    return 'RegisterModel(email: $email, fullName: $fullName, phone: $phone, userId: $userId, status: $status)';
  }
}