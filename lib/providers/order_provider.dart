import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uber_driver/models/order_status_model.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../models/order_model.dart';
import '../models/ride_model.dart';
import '../shared/local/cash_helper.dart';
import '../shared/remote/dio_helper.dart';
import '../shared/snack_bar/snack_bar.dart';

class OrderProvider extends ChangeNotifier {
  /// API Endpoints
  static const String _pendingRidesEndpoint = 'driver/rides/pending';
  static const String _activeRideEndpoint = 'driver/rides/active';

  // ============== PENDING RIDES STATE ==============
  bool _isLoading = false;
  List<RideModel> _pendingRides = [];
  String? _errorMessage;

  // ============== ACTIVE RIDE STATE ==============
  bool _acceptRideLoading = false;
  bool _activeRideLoading = false;
  RideModel? _activeRide;
  String? _activeRideError;

  // ============== RIDE HISTORY STATE ==============
  bool _historyLoading = false;
  List<RideModel> _historyRides = [];
  String? _historyError;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalRides = 0;
  bool _loadingMore = false;

  // ============== ORDERS STATE ==============
  final List<OrderModel> _order = [];
  late OrderModel _orderData;
  bool assignLoading = false;
  bool updateLoading = false;
  bool updateStatus = false;
  bool unAssignLoading = false;
  int? userId = CashHelper.getUserId();

  // ============== GETTERS ==============

  // Pending Rides Getters
  bool get isLoading => _isLoading;
  List<RideModel> get pendingRides => _pendingRides;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasRides => _pendingRides.isNotEmpty;

  // Active Ride Getters
  bool get acceptRideLoading => _acceptRideLoading;
  bool get activeRideLoading => _activeRideLoading;
  RideModel? get activeRide => _activeRide;
  String? get activeRideError => _activeRideError;
  bool get hasActiveRide => _activeRide != null;

  // Ride History Getters
  bool get historyLoading => _historyLoading;
  List<RideModel> get historyRides => _historyRides;
  String? get historyError => _historyError;
  bool get hasHistoryError => _historyError != null;
  bool get hasHistory => _historyRides.isNotEmpty;
  bool get hasMoreHistory => _currentPage < _lastPage;
  bool get loadingMore => _loadingMore;
  int get totalRides => _totalRides;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;

  // Orders Getters
  List<OrderModel> get order => _order;
  OrderModel get orderData => _orderData;

  // ============== PENDING RIDES METHODS ==============

  /// Get Pending Rides
  /// GET /rides/pending
  /// Response: {"success": true, "data": [...]}
  Future<void> getPendingRides() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: _pendingRidesEndpoint,
      );

      _isLoading = false;

      final responseData = response.data;

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> ridesJson = responseData['data'] as List<dynamic>;

        _pendingRides = ridesJson
            .map((json) => RideModel.fromJson(json as Map<String, dynamic>))
            .toList();

        notifyListeners();
      } else {
        _errorMessage = responseData['message'] ?? 'Failed to load rides';
        _pendingRides = [];
        notifyListeners();
      }
    } on DioException catch (error) {
      _isLoading = false;
      _pendingRides = [];

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        _errorMessage = 'connection_timeout';
      } else if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        _errorMessage =
            error.response!.data['message'] ?? 'Failed to load rides';
      } else {
        _errorMessage = 'connection_error';
      }

      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _pendingRides = [];
      _errorMessage = 'unexpected_error';
      print('Get pending rides error: $error');
      notifyListeners();
    }
  }

  /// Refresh pending rides
  Future<void> refreshPendingRides() async {
    await getPendingRides();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear rides
  void clearRides() {
    _pendingRides = [];
    _errorMessage = null;
    notifyListeners();
  }

  // ============== ACTIVE RIDE METHODS ==============

  /// Accept Ride
  /// POST /driver/rides/{id}/accept
  /// Response: {"success": true, "message": "Ride accepted", "data": {...}}
  Future<RideModel?> acceptRide({
    required BuildContext context,
    required int rideId,
  }) async {
    _acceptRideLoading = true;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
        url: 'driver/rides/$rideId/accept',
        data: {},
      );

      _acceptRideLoading = false;
      final responseData = response.data;

      if (responseData['success'] == true && responseData['data'] != null) {
        final rideData = responseData['data'] as Map<String, dynamic>;
        _activeRide = RideModel.fromJson(rideData);

        ShowSuccesSnackBar(
          context,
          _safeTranslate(context, 'successMessage.acceptRide', 'تم قبول الرحلة بنجاح'),
        );

        notifyListeners();
        return _activeRide;
      } else {
        ShowErrorSnackBar(
          context,
          responseData['message'] ?? _safeTranslate(context, 'errorsMessage.acceptRide', 'حدث خطأ أثناء قبول الرحلة'),
        );
        notifyListeners();
        return null;
      }
    } on DioException catch (error) {
      _acceptRideLoading = false;

      String errorMessage;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        errorMessage = _safeTranslate(context, 'errorsMessage.connection', 'مشكلة في الاتصال');
      } else if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        errorMessage = error.response!.data['message'] ??
            _safeTranslate(context, 'errorsMessage.acceptRide', 'حدث خطأ أثناء قبول الرحلة');
      } else {
        errorMessage = _safeTranslate(context, 'errorsMessage.acceptRide', 'حدث خطأ أثناء قبول الرحلة');
      }

      ShowErrorSnackBar(context, errorMessage);
      notifyListeners();
      return null;
    } catch (error) {
      _acceptRideLoading = false;
      print('Accept ride error: $error');
      ShowErrorSnackBar(
        context,
        _safeTranslate(context, 'errorsMessage.acceptRide', 'حدث خطأ أثناء قبول الرحلة'),
      );
      notifyListeners();
      return null;
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

  /// Get Active Ride
  /// GET /driver/rides/active
  /// Response: {"success": true, "data": {...}}
  Future<void> getActiveRide() async {
    _activeRideLoading = true;
    _activeRideError = null;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: _activeRideEndpoint,
      );

      _activeRideLoading = false;
      final responseData = response.data;

      if (responseData['success'] == true && responseData['data'] != null) {
        final rideData = responseData['data'] as Map<String, dynamic>;
        _activeRide = RideModel.fromJson(rideData);
        notifyListeners();
      } else {
        _activeRide = null;
        _activeRideError = responseData['message'] ?? 'No active ride';
        notifyListeners();
      }
    } on DioException catch (error) {
      _activeRideLoading = false;
      _activeRide = null;

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        _activeRideError = 'connection_timeout';
      } else if (error.response?.statusCode == 404) {
        // No active ride - this is not an error
        _activeRideError = null;
      } else if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        _activeRideError = error.response!.data['message'] ?? 'Failed to load active ride';
      } else {
        _activeRideError = 'connection_error';
      }

      notifyListeners();
    } catch (error) {
      _activeRideLoading = false;
      _activeRide = null;
      _activeRideError = 'unexpected_error';
      print('Get active ride error: $error');
      notifyListeners();
    }
  }

  /// Clear active ride
  void clearActiveRide() {
    _activeRide = null;
    _activeRideError = null;
    notifyListeners();
  }

  // ============== RIDE HISTORY METHODS ==============

  /// Get Ride History
  /// GET /driver/rides/history?page=1&per_page=20
  /// Response: {"success": true, "data": [...], "pagination": {...}}
  Future<void> getRideHistory({int page = 1, int perPage = 20}) async {
    if (page == 1) {
      _historyLoading = true;
      _historyError = null;
      _historyRides = [];
    } else {
      _loadingMore = true;
    }
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: 'driver/rides/history',
        query: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (page == 1) {
        _historyLoading = false;
      } else {
        _loadingMore = false;
      }

      final responseData = response.data;

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> ridesJson = responseData['data'] as List<dynamic>;
        final newRides = ridesJson
            .map((json) => RideModel.fromJson(json as Map<String, dynamic>))
            .toList();

        if (page == 1) {
          _historyRides = newRides;
        } else {
          _historyRides.addAll(newRides);
        }

        // Parse pagination info
        if (responseData['pagination'] != null) {
          final pagination = responseData['pagination'] as Map<String, dynamic>;
          _currentPage = pagination['current_page'] ?? page;
          _lastPage = pagination['last_page'] ?? 1;
          _totalRides = pagination['total'] ?? _historyRides.length;
        } else {
          _currentPage = page;
          _lastPage = page;
          _totalRides = _historyRides.length;
        }

        notifyListeners();
      } else {
        _historyError = responseData['message'] ?? 'Failed to load ride history';
        notifyListeners();
      }
    } on DioException catch (error) {
      if (page == 1) {
        _historyLoading = false;
      } else {
        _loadingMore = false;
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        _historyError = 'connection_timeout';
      } else if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        _historyError =
            error.response!.data['message'] ?? 'Failed to load ride history';
      } else {
        _historyError = 'connection_error';
      }

      notifyListeners();
    } catch (error) {
      if (page == 1) {
        _historyLoading = false;
      } else {
        _loadingMore = false;
      }
      _historyError = 'unexpected_error';
      print('Get ride history error: $error');
      notifyListeners();
    }
  }

  /// Load more ride history (pagination)
  Future<void> loadMoreHistory({int perPage = 20}) async {
    if (!hasMoreHistory || _loadingMore) return;
    await getRideHistory(page: _currentPage + 1, perPage: perPage);
  }

  /// Refresh ride history
  Future<void> refreshHistory({int perPage = 20}) async {
    await getRideHistory(page: 1, perPage: perPage);
  }

  /// Clear ride history
  void clearHistory() {
    _historyRides = [];
    _historyError = null;
    _currentPage = 1;
    _lastPage = 1;
    _totalRides = 0;
    notifyListeners();
  }

  // ============== ORDERS METHODS ==============

  Future<void> getOrder({
    required String filter,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: 'drivers/',
        urlParam: filter,
      );

      print(response.data);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            filter == 'my-orders' ? response.data['orders'] : response.data;
        print(data);
        List<OrderModel> result =
            data.map((item) => OrderModel.fromJson(item)).toList();
        if (data.isEmpty) {
          return Future.error('Failed to load data');
        }
        _order.clear();
        _order.addAll(result);
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

  Future<void> getOrderById({
    required int id,
  }) async {
    try {
      final response = await DioHelper.getData(url: 'orders', urlParam: '/$id');

      print(response.data);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        _orderData = OrderModel.fromJson(data);
      } else {
        return Future.error('Failed to load data');
      }
    } catch (error) {
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

  Future<void> assignOrder({
    required BuildContext context,
    required int orderId,
  }) async {
    assignLoading = true;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
          url: 'drivers/driver-orders/assign', data: {"order_id": orderId});

      print(response.data);
      ShowSuccesSnackBar(
          context, context.translate('successMessage.assignOrder'));
      assignLoading = false;
      notifyListeners();
      Navigator.pop(context);
    } catch (error) {
      print('zqs');
      print(error);
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        assignLoading = false;
        notifyListeners();

        ShowErrorSnackBar(
            context, context.translate('errorsMessage.connection'));
        return Future.error('connection timeout');
      } else if (error is DioException) {
        assignLoading = false;
        notifyListeners();
        ShowErrorSnackBar(
            context, context.translate('errorsMessage.assignOrder'));
        return Future.error('connection $error');
      } else {
        assignLoading = false;
        notifyListeners();
        return Future.error('connection other');
      }
    }
  }

  Future<void> unAssignOrder({
    required BuildContext context,
    required int orderId,
  }) async {
    unAssignLoading = true;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
          url: 'drivers/order/unassign', data: {"order_id": orderId});

      print(response.data);
      ShowSuccesSnackBar(
          context, context.translate('successMessage.unAssignOrder'));
      unAssignLoading = false;
      notifyListeners();
      Navigator.pop(context);
    } catch (error) {
      print(error);
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        unAssignLoading = false;
        notifyListeners();

        ShowErrorSnackBar(
            context, context.translate('errorsMessage.connection'));
        return Future.error('connection timeout');
      } else if (error is DioException) {
        unAssignLoading = false;
        notifyListeners();
        ShowErrorSnackBar(
            context, context.translate('errorsMessage.unAssignOrder'));
        return Future.error('connection $error');
      } else {
        unAssignLoading = false;
        notifyListeners();
        return Future.error('connection other');
      }
    }
  }

  Future<void> updateOrderStatus({
    required BuildContext context,
    required int orderId,
    required int status,
  }) async {
    updateStatus = true;
    notifyListeners();

    try {
      final response = await DioHelper.putData(
          url: 'drivers/driver-orders/$orderId/update-status',
          data: {"order_id": orderId, "status_id": status});
      print(response.data);
      ShowSuccesSnackBar(
          context, context.translate('successMessage.updateOrderStatus'));
      updateStatus = false;
      notifyListeners();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      print('zqs');
      print(error);
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        updateStatus = false;
        notifyListeners();

        ShowErrorSnackBar(
            context, context.translate('errorsMessage.connection'));
        return Future.error('connection timeout');
      } else if (error is DioException) {
        updateStatus = false;
        notifyListeners();
        ShowErrorSnackBar(
            context, context.translate('errorsMessage.updateOrderStatus'));
        return Future.error('connection $error');
      } else {
        updateStatus = false;
        notifyListeners();
        return Future.error('connection other');
      }
    }
  }

  Future<List<OrderStatusModel>>? getOrderStatus() async {
    try {
      final response = await DioHelper.getData(
        url: 'statuses',
      );

      print(response.data);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print(data);
        List<OrderStatusModel> result =
            data.map((item) => OrderStatusModel.fromJson(item)).toList();
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
}
