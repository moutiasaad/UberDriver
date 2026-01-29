import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../shared/remote/dio_helper.dart';

class DriverProvider extends ChangeNotifier {
  bool _isOnline = false;
  bool _goingOnlineLoading = false;
  String? _goOnlineError;

  // Getters
  bool get isOnline => _isOnline;
  bool get goingOnlineLoading => _goingOnlineLoading;
  String? get goOnlineError => _goOnlineError;

  /// Set Driver as Online
  /// POST /driver/go-online
  /// Automatically sends the token via DioHelper
  Future<void> goOnline() async {
    _goingOnlineLoading = true;
    _goOnlineError = null;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
        url: 'driver/go-online',
      );

      _goingOnlineLoading = false;

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          _isOnline = true;
          print('Driver successfully went online');
        } else {
          _goOnlineError = responseData['message'] ?? 'Failed to go online';
          print('Failed to go online: $_goOnlineError');
        }
      } else {
        _goOnlineError = 'Failed to go online';
        print('Failed to go online with status: ${response.statusCode}');
      }

      notifyListeners();
    } on DioException catch (error) {
      _goingOnlineLoading = false;

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        _goOnlineError = 'Connection timeout';
      } else if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        _goOnlineError =
            error.response!.data['message'] ?? 'Failed to go online';
      } else {
        _goOnlineError = 'Connection error';
      }

      print('Go online error: $_goOnlineError');
      notifyListeners();
    } catch (error) {
      _goingOnlineLoading = false;
      _goOnlineError = 'Unexpected error';
      print('Go online unexpected error: $error');
      notifyListeners();
    }
  }

  /// Reset online status
  void resetOnlineStatus() {
    _isOnline = false;
    _goOnlineError = null;
    notifyListeners();
  }
}
