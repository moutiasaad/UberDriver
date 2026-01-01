import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../models/driver_profile_model.dart';
import '../shared/local/cash_helper.dart';
import '../shared/local/secure_cash_helper.dart';
import '../shared/remote/dio_helper.dart';
import '../shared/snack_bar/snack_bar.dart';
import '../view/login/login_layout.dart';

class ProfileProvider extends ChangeNotifier {
  bool loading = false;

  // Driver Profile State
  bool _profileLoading = false;
  DriverProfileModel? _driverProfile;
  String? _profileError;

  // Getters
  bool get profileLoading => _profileLoading;
  DriverProfileModel? get driverProfile => _driverProfile;
  String? get profileError => _profileError;
  bool get hasProfile => _driverProfile != null;

  /// Get Driver Profile
  /// GET /driver/profile
  /// Response: {"success": true, "data": {...}}
  Future<void> getDriverProfile() async {
    _profileLoading = true;
    _profileError = null;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: 'driver/profile',
      );

      _profileLoading = false;
      final responseData = response.data;

      if (responseData['success'] == true && responseData['data'] != null) {
        final profileData = responseData['data'] as Map<String, dynamic>;
        _driverProfile = DriverProfileModel.fromJson(profileData);
        notifyListeners();
      } else {
        _profileError = responseData['message'] ?? 'Failed to load profile';
        notifyListeners();
      }
    } on DioException catch (error) {
      _profileLoading = false;

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        _profileError = 'connection_timeout';
      } else if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        _profileError =
            error.response!.data['message'] ?? 'Failed to load profile';
      } else {
        _profileError = 'connection_error';
      }

      notifyListeners();
    } catch (error) {
      _profileLoading = false;
      _profileError = 'unexpected_error';
      print('Get driver profile error: $error');
      notifyListeners();
    }
  }

  /// Refresh driver profile
  Future<void> refreshProfile() async {
    await getDriverProfile();
  }

  /// Clear profile
  void clearProfile() {
    _driverProfile = null;
    _profileError = null;
    notifyListeners();
  }


  Future<void> deleteAccount(BuildContext context) async {
    loading = true;
    notifyListeners();

    try {
      final response =  await DioHelper.postData(
        url: 'destroy-account',
      );
  if(response.statusCode == 200){
    await CashHelper.clearData();
    await SecureCashHelper.clear();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginLayout(),
        ));
  }
      loading = false;
      notifyListeners();
    } catch (error) {
      print('zqs');
      print(error);
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        loading = false;
        notifyListeners();

        ShowErrorSnackBar(
            context, context.translate('errorsMessage.connection'));
        return Future.error('connection timeout');
      } else if (error is DioException) {
        loading = false;
        notifyListeners();
        ShowErrorSnackBar(
            context, context.translate('errorsMessage.deleteAccount'));
        return Future.error('connection $error');
      } else {
        loading = false;
        notifyListeners();
        return Future.error('connection other');
      }
    }
  }

}
