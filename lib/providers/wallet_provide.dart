import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../shared/remote/dio_helper.dart';
import '../shared/snack_bar/snack_bar.dart';

class WalletProvider extends ChangeNotifier {
  bool loading = false;

  // Wallet State
  bool _walletLoading = false;
  WalletModel? _wallet;
  String? _walletError;

  // Getters
  bool get walletLoading => _walletLoading;
  WalletModel? get wallet => _wallet;
  String? get walletError => _walletError;
  bool get hasWallet => _wallet != null;

  /// Get Wallet
  /// GET /driver/wallet
  /// Response: {"success": true, "data": {...}}
  Future<void> getWallet() async {
    _walletLoading = true;
    _walletError = null;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: 'driver/wallet',
      );

      _walletLoading = false;
      final responseData = response.data;

      if (responseData['success'] == true && responseData['data'] != null) {
        final walletData = responseData['data'] as Map<String, dynamic>;
        _wallet = WalletModel.fromJson(walletData);
        notifyListeners();
      } else {
        _walletError = responseData['message'] ?? 'Failed to load wallet';
        notifyListeners();
      }
    } on DioException catch (error) {
      _walletLoading = false;

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        _walletError = 'connection_timeout';
      } else if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        _walletError =
            error.response!.data['message'] ?? 'Failed to load wallet';
      } else {
        _walletError = 'connection_error';
      }

      notifyListeners();
    } catch (error) {
      _walletLoading = false;
      _walletError = 'unexpected_error';
      print('Get wallet error: $error');
      notifyListeners();
    }
  }

  /// Refresh wallet
  Future<void> refreshWallet() async {
    await getWallet();
  }

  /// Clear wallet
  void clearWallet() {
    _wallet = null;
    _walletError = null;
    notifyListeners();
  }

  Future<TransactionModel> getTransactions() async {
    try {
      final response = await DioHelper.getData(url: 'drivers/transactions');

      print(response.data);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = response.data;
        print(data);
        TransactionModel result = TransactionModel.fromJson(data);

        if (data.isEmpty) {
          return Future.error('Failed to load data');
        }
        return result;
      } else {
        return Future.error('Failed to load data');
      }
    } catch (error) {
      print(error);
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        return await Future.error('connection timeout');
      } else if (error is DioException) {
        return await Future.error('connection other');
      } else {
        return await Future.error('connection other');
      }
    }
  }

  /// Withdraw from wallet
  /// POST /driver/wallet/withdraw
  /// Body: {"amount": 50, "bank_name": "...", "bank_account": "...", "bank_iban": "..."}
  /// Response: {"success": true, "message": "Withdrawal request submitted", "data": {...}}
  Future<bool> withdraw({
    required BuildContext context,
    required double amount,
    required String bankName,
    required String bankAccount,
    required String bankIban,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
        url: 'driver/wallet/withdraw',
        data: {
          "amount": amount,
          "bank_name": bankName,
          "bank_account": bankAccount,
          "bank_iban": bankIban,
        },
      );

      loading = false;
      notifyListeners();

      final responseData = response.data;

      if (responseData['success'] == true) {
        Navigator.pop(context);
        ShowSuccesSnackBar(
          context,
          _safeTranslate(context, 'successMessage.withdraw', 'تم إرسال طلب السحب بنجاح'),
        );
        // Refresh wallet to get updated balance
        await refreshWallet();
        return true;
      } else {
        Navigator.pop(context);
        ShowErrorSnackBar(
          context,
          responseData['message'] ?? _safeTranslate(context, 'errorsMessage.withdraw', 'حدث خطأ أثناء السحب'),
        );
        return false;
      }
    } on DioException catch (error) {
      loading = false;
      notifyListeners();
      Navigator.pop(context);

      String errorMessage;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        errorMessage = _safeTranslate(context, 'errorsMessage.connection', 'مشكلة في الاتصال');
      } else if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        errorMessage = error.response!.data['message'] ??
            _safeTranslate(context, 'errorsMessage.withdraw', 'حدث خطأ أثناء السحب');
      } else {
        errorMessage = _safeTranslate(context, 'errorsMessage.withdraw', 'حدث خطأ أثناء السحب');
      }

      ShowErrorSnackBar(context, errorMessage);
      return false;
    } catch (error) {
      loading = false;
      notifyListeners();
      Navigator.pop(context);
      print('Withdraw error: $error');
      ShowErrorSnackBar(
        context,
        _safeTranslate(context, 'errorsMessage.withdraw', 'حدث خطأ أثناء السحب'),
      );
      return false;
    }
  }

  /// Safe translate helper that returns fallback if translation not found
  String _safeTranslate(BuildContext context, String key, String fallback) {
    try {
      return context.translate(key);
    } catch (e) {
      return fallback;
    }
  }
}
