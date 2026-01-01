import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/register_model.dart';
import '../models/static_model/user_model.dart';
import '../shared/components/loading/icon_loader.dart';
import '../shared/local/cash_helper.dart';
import '../shared/local/secure_cash_helper.dart';
import '../shared/remote/dio_helper.dart';
import '../view/layout/driver_home_layout.dart';

class RegisterProvider extends ChangeNotifier {
  bool loading = false;
  bool otpError = false;
  String? errorMessage;
  Map<String, dynamic> errors = {};

  bool get isOtpError => otpError;

  // ==================== SEND OTP ====================
  Future<void> sendOtp(
      RegisterModel data, BuildContext context, Function onSuccess) async {
    // Clear previous errors
    errors = {};
    errorMessage = null;
    loading = true;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
        withToken: false,
        url: 'auth/driver/send-otp',
        data: {
          "email": data.email,
        },
      );

      print('Send OTP Response: ${response.data}');

      // Check if response is successful
      if (response.data['success'] == true) {
        // Store OTP for testing/development (remove in production)
        if (response.data['data'] != null &&
            response.data['data']['otp'] != null) {
          data.otp = response.data['data']['otp'];
          print('OTP received: ${data.otp}');
        }

        loading = false;
        notifyListeners();
        onSuccess();
      } else {
        // Handle API error response
        errorMessage = response.data['message'] ?? 'Failed to send OTP';
        loading = false;
        notifyListeners();
      }
    } catch (error) {
      if (error is DioException) {
        if (error.response?.data != null) {
          if (error.response?.data['errors'] != null) {
            errors = error.response?.data['errors'];
          }
          errorMessage = error.response?.data['message'] ?? 'An error occurred';
        } else {
          errorMessage = 'Network error. Please try again.';
        }
      } else {
        print("An unexpected error occurred: $error");
        errorMessage = 'An unexpected error occurred';
      }
      loading = false;
      notifyListeners();
    }
  }

  // ==================== VERIFY OTP ====================
  Future<void> verifyOtp(
      RegisterModel data, BuildContext context, String otp) async {
    otpError = false;
    errorMessage = null;
    notifyListeners();
    otpLoading(context);

    try {
      final response = await DioHelper.postData(
        withToken: false,
        url: 'auth/driver/verify-otp',
        data: {
          "email": data.email,
          "otp": otp,
        },
      );

      print('Verify OTP Response: ${response.data}');

      // Check if response is successful
      if (response.data['success'] == true) {
        final responseData = response.data['data'];

        // Store token securely
        await SecureCashHelper.setToken(responseData['token']);

        // Get driver data from response
        final driverData = responseData['driver'];

        // Store driver ID
        await CashHelper.setUserId(driverData['id']);

        // Store currency if available
        if (driverData['currency'] != null) {
          await CashHelper.setCurrency(driverData['currency']);
        }

        // Create and store user model
        UserModel user = UserModel(
          fullName: driverData['name'] ?? '',
          email: driverData['email'] ?? '',
          phone: driverData['phone'] ?? '',
          image: driverData['profile_image'] ?? '',
        );

        print('User created: $user');
        await CashHelper.setUserData(user);

        // Store additional driver info if needed
        await _storeDriverProfile(driverData);

        loading = false;
        notifyListeners();
        Navigator.pop(context); // Close loading dialog

        // Navigate to home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DriverHomeLayout(),
          ),
              (route) => false,
        );
      } else {
        // Handle API error response
        otpError = true;
        errorMessage = response.data['message'] ?? 'Invalid or expired OTP';
        Navigator.pop(context); // Close loading dialog
        notifyListeners();
      }
    } catch (error) {
      if (error is DioException) {
        otpError = true;
        if (error.response?.data != null) {
          errorMessage =
              error.response?.data['message'] ?? 'Invalid or expired OTP';
        } else {
          errorMessage = 'Network error. Please try again.';
        }
      } else {
        print("An unexpected error occurred: $error");
        errorMessage = 'An unexpected error occurred';
        otpError = true;
      }
      Navigator.pop(context); // Close loading dialog
      notifyListeners();
    }
  }

  // ==================== RESEND OTP ====================
  Future<void> resendOtp(RegisterModel data, BuildContext context) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
        withToken: false,
        url: 'auth/driver/send-otp',
        data: {
          "email": data.email,
        },
      );

      print('Resend OTP Response: ${response.data}');

      if (response.data['success'] == true) {
        // Store new OTP for testing/development (remove in production)
        if (response.data['data'] != null &&
            response.data['data']['otp'] != null) {
          data.otp = response.data['data']['otp'];
        }

        loading = false;
        notifyListeners();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'OTP sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        errorMessage = response.data['message'] ?? 'Failed to resend OTP';
        loading = false;
        notifyListeners();
      }
    } catch (error) {
      if (error is DioException) {
        errorMessage =
            error.response?.data['message'] ?? 'Failed to resend OTP';
      } else {
        errorMessage = 'An unexpected error occurred';
      }
      loading = false;
      notifyListeners();
    }
  }

  // ==================== STORE DRIVER PROFILE ====================
  Future<void> _storeDriverProfile(Map<String, dynamic> driverData) async {
    // Store extended driver profile data
    // You can create a DriverModel class for this or use shared preferences

    // Example: Store as JSON string
    // await CashHelper.setDriverProfile(jsonEncode(driverData));

    // Or store individual fields as needed
    print('Driver Profile Stored:');
    print('  - ID: ${driverData['id']}');
    print('  - Name: ${driverData['name']}');
    print('  - Email: ${driverData['email']}');
    print('  - Phone: ${driverData['phone']}');
    print('  - Vehicle Type: ${driverData['vehicle_type']}');
    print('  - Status: ${driverData['status']}');
    print('  - Is Online: ${driverData['is_online']}');
    print('  - Rating: ${driverData['rating_average']}');
    print('  - Total Trips: ${driverData['total_trips']}');
    print('  - Wallet Balance: ${driverData['wallet_balance']}');
  }

  // ==================== UPDATE FULL NAME ====================
  Future<void> updateFullName({
    required BuildContext context,
    required String fullName,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
          url: 'drivers/update-fullname', data: {"fullname": fullName});
      print(response.data['driver']);
      print('user name : ${response.data}');

      UserModel user = UserModel(
        fullName: response.data['driver']['name'],
        phone: response.data['driver']['phone'],
      );
      await CashHelper.setUserData(user);

      loading = false;
      notifyListeners();
      Navigator.pop(context);
    } catch (error) {
      print(error);
      if (error is DioException) {
        errors = error.response?.data['errors'] ?? {};
      } else {
        print("An unexpected error occurred: $error");
      }
      loading = false;
      notifyListeners();
    }
  }

  // ==================== UPDATE PHONE NUMBER ====================
  Future<void> updatePhoneNumber({
    required BuildContext context,
    required String phone,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
          url: 'drivers/update-phone', data: {'phone': phone});
      print(response.data['driver']);
      UserModel userData = await CashHelper.getUserData();

      UserModel user = UserModel(
        email: userData.email,
        image: userData.image,
        fullName: response.data['driver']['name'],
        phone: response.data['driver']['phone'],
      );
      await CashHelper.setUserData(user);
      loading = false;
      notifyListeners();
      Navigator.pop(context);
    } catch (error) {
      print(error);
      if (error is DioException) {
        errors = error.response?.data['errors'] ?? {};
      } else {
        print("An unexpected error occurred: $error");
      }
      loading = false;
      notifyListeners();
    }
  }

  // ==================== OTP LOADING DIALOG ====================
  void otpLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          content: Container(
              margin: EdgeInsets.symmetric(horizontal: 80, vertical: 80),
              color: Colors.transparent,
              child: IconLoader()),
        );
      },
    );
  }

  // ==================== CLEAR ERRORS ====================
  void clearErrors() {
    errors = {};
    errorMessage = null;
    otpError = false;
    notifyListeners();
  }
}