import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../models/location_model.dart'; // <-- create/point to your model
import '../shared/remote/dio_helper.dart';
import '../shared/snack_bar/snack_bar.dart';

class LocationProvider extends ChangeNotifier {
  final List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  LocationModel? _latest;
  LocationModel? get latest => _latest;

  LocationModel? _current;
  LocationModel? get current => _current;

  // Loading flags
  bool listLoading = false;
  bool addLoading = false;
  bool latestLoading = false;
  bool deleteLoading = false;

  Timer? _timer;
  bool _tracking = false;
  int? _trackDriverId;
  int? _trackDriverOrderId;

  bool get isTracking => _tracking;

  // Driver location state
  double? _driverLatitude;
  double? _driverLongitude;
  bool _driverLocationLoading = false;

  double? get driverLatitude => _driverLatitude;
  double? get driverLongitude => _driverLongitude;
  bool get driverLocationLoading => _driverLocationLoading;
  bool get hasDriverLocation => _driverLatitude != null && _driverLongitude != null;

  Future<Position> _getCurrentPosition() async {
    final svc = await Geolocator.isLocationServiceEnabled();
    if (!svc) throw 'location-services-disabled';

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      throw 'location-permission-denied';
    }
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future<void> _sendOnce({BuildContext? context}) async {
    try {
      final pos = await _getCurrentPosition();
      await DioHelper.postData(
        url: 'drivers/locations',
        data: {
          if (_trackDriverId != null) 'driver_id': _trackDriverId,
          if (_trackDriverOrderId != null) 'driver_order_id': _trackDriverOrderId,
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'accuracy': pos.accuracy,
        },
      );
    } catch (_) {
      // swallow periodic errors; you can log if needed
    }
  }

  /// Start sending GPS immediately, then every [interval] (default 30s)
  Future<void> startPeriodicTracking({
    BuildContext? context,
    int? driverId,
    int? driverOrderId,
    Duration interval = const Duration(seconds: 30),
  }) async {
    _trackDriverId = driverId;
    _trackDriverOrderId = driverOrderId;

    _timer?.cancel();
    _tracking = true;
    notifyListeners();

    await _sendOnce(context: context);
    _timer = Timer.periodic(interval, (_) => _sendOnce(context: context));
  }

  void stopPeriodicTracking() {
    _timer?.cancel();
    _timer = null;
    _tracking = false;
    notifyListeners();
  }

  /* --------------------------------------------------------------------------
   * Update Driver Location
   * PUT /driver/location
   * Body: {"latitude": 24.7136, "longitude": 46.6753}
   * Response: {"success": true, "message": "Location updated"}
   * ------------------------------------------------------------------------*/
  Future<bool> updateDriverLocation() async {
    _driverLocationLoading = true;
    notifyListeners();

    try {
      final pos = await _getCurrentPosition();

      _driverLatitude = pos.latitude;
      _driverLongitude = pos.longitude;

      final response = await DioHelper.putData(
        url: 'driver/location',
        data: {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
        },
      );

      _driverLocationLoading = false;
      notifyListeners();

      final responseData = response.data;
      return responseData['success'] == true;
    } on DioException catch (error) {
      _driverLocationLoading = false;
      notifyListeners();
      print('Update driver location error: $error');
      return false;
    } catch (error) {
      _driverLocationLoading = false;
      notifyListeners();
      print('Update driver location error: $error');
      return false;
    }
  }

  /// Start periodic driver location updates for active ride
  /// Updates location immediately, then every [interval] (default 10s)
  Future<void> startDriverLocationTracking({
    Duration interval = const Duration(seconds: 10),
  }) async {
    _timer?.cancel();
    _tracking = true;
    notifyListeners();

    // Send immediately
    await updateDriverLocation();

    // Then periodically
    _timer = Timer.periodic(interval, (_) => updateDriverLocation());
  }

  /// Stop driver location tracking
  void stopDriverLocationTracking() {
    _timer?.cancel();
    _timer = null;
    _tracking = false;
    _driverLatitude = null;
    _driverLongitude = null;
    notifyListeners();
  }

  /// Get current driver position without sending to server
  Future<void> getCurrentDriverPosition() async {
    try {
      final pos = await _getCurrentPosition();
      _driverLatitude = pos.latitude;
      _driverLongitude = pos.longitude;
      notifyListeners();
    } catch (e) {
      print('Get current position error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  /* --------------------------------------------------------------------------
   * Helpers
   * ------------------------------------------------------------------------*/
  String _fmtDate(DateTime d) => d.toIso8601String();

  Map<String, dynamic> _cleanQuery(Map<String, dynamic?> raw) {
    final q = <String, dynamic>{};
    raw.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      q[k] = v;
    });
    return q;
  }

  /* --------------------------------------------------------------------------
   * List / Filter
   * GET /api/drivers/locations?driver_id=&driver_order_id=&from=&to=
   * ------------------------------------------------------------------------*/
  Future<void> fetchLocations({
    int? driverId,
    int? driverOrderId,
    DateTime? from,
    DateTime? to,
  }) async {
    listLoading = true;
    notifyListeners();
    try {
      final query = _cleanQuery({
        'driver_id': driverId,
        'driver_order_id': driverOrderId,
        if (from != null) 'from': _fmtDate(from),
        if (to != null) 'to': _fmtDate(to),
      });

      final resp = await DioHelper.getData(
        url: 'drivers/locations',
        query: query,
      );

      if (resp.statusCode == 200) {
        final data = resp.data as List<dynamic>;
        final items = data.map((e) => LocationModel.fromJson(e)).toList();
        _locations
          ..clear()
          ..addAll(items);
      } else {
        return Future.error('Failed to load data');
      }
    } catch (error) {
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        return Future.error('connection timeout');
      }
      return Future.error('connection other');
    } finally {
      listLoading = false;
      notifyListeners();
    }
  }

  /* --------------------------------------------------------------------------
   * GET /api/drivers/locations/driver/{id}
   * ------------------------------------------------------------------------*/
  Future<void> fetchByDriver(int driverId) async {
    listLoading = true;
    notifyListeners();
    try {
      final resp = await DioHelper.getData(
        url: 'drivers/locations/driver',
        urlParam: '/$driverId',
      );

      if (resp.statusCode == 200) {
        final data = resp.data;
        List<dynamic> arr;
        if (data is Map<String, dynamic> && data['data'] is List) {
          // If paginated from Laravel
          arr = data['data'] as List;
        } else {
          arr = data as List<dynamic>;
        }
        final items = arr.map((e) => LocationModel.fromJson(e)).toList();
        _locations
          ..clear()
          ..addAll(items);
      } else {
        return Future.error('Failed to load data');
      }
    } catch (error) {
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        return Future.error('connection timeout');
      }
      return Future.error('connection other');
    } finally {
      listLoading = false;
      notifyListeners();
    }
  }

  /* --------------------------------------------------------------------------
   * GET /api/drivers/locations/order/{id}
   * ------------------------------------------------------------------------*/
  Future<void> fetchByOrder(int orderId) async {
    listLoading = true;
    notifyListeners();
    try {
      final resp = await DioHelper.getData(
        url: 'drivers/locations/order',
        urlParam: '/$orderId',
      );

      if (resp.statusCode == 200) {
        final data = resp.data;
        List<dynamic> arr;
        if (data is Map<String, dynamic> && data['data'] is List) {
          arr = data['data'] as List;
        } else {
          arr = data as List<dynamic>;
        }
        final items = arr.map((e) => LocationModel.fromJson(e)).toList();
        _locations
          ..clear()
          ..addAll(items);
      } else {
        return Future.error('Failed to load data');
      }
    } catch (error) {
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        return Future.error('connection timeout');
      }
      return Future.error('connection other');
    } finally {
      listLoading = false;
      notifyListeners();
    }
  }

  /* --------------------------------------------------------------------------
   * GET /api/drivers/locations/driver/{id}/latest
   * ------------------------------------------------------------------------*/
  Future<void> fetchLatestForDriver(int driverId) async {
    latestLoading = true;
    notifyListeners();
    try {
      final resp = await DioHelper.getData(
        url: 'drivers/locations/driver',
        urlParam: '/$driverId/latest',
      );

      if (resp.statusCode == 200 && resp.data != null) {
        _latest = LocationModel.fromJson(resp.data);
      } else {
        _latest = null;
      }
    } catch (error) {
      _latest = null;
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        return Future.error('connection timeout');
      }
      return Future.error('connection other');
    } finally {
      latestLoading = false;
      notifyListeners();
    }
  }

  /* --------------------------------------------------------------------------
   * GET /api/drivers/locations/{id}
   * ------------------------------------------------------------------------*/
  Future<void> fetchOne(int id) async {
    try {
      final resp = await DioHelper.getData(
        url: 'drivers/locations',
        urlParam: '/$id',
      );

      if (resp.statusCode == 200 && resp.data != null) {
        _current = LocationModel.fromJson(resp.data);
        notifyListeners();
      } else {
        return Future.error('Failed to load data');
      }
    } catch (error) {
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        return Future.error('connection timeout');
      }
      return Future.error('connection other');
    }
  }

  /* --------------------------------------------------------------------------
   * POST /api/drivers/locations   (upsert if both driver_id & driver_order_id)
   * body: { driver_id?, driver_order_id?, latitude, longitude, accuracy? }
   * ------------------------------------------------------------------------*/
  Future<void> addLocation({
    required BuildContext context,
    int? driverId,
    int? driverOrderId,
    required double latitude,
    required double longitude,
    double? accuracy,
    VoidCallback? onSuccess,
  }) async {
    addLoading = true;
    notifyListeners();
    try {
      final payload = <String, dynamic>{
        if (driverId != null) 'driver_id': driverId,
        if (driverOrderId != null) 'driver_order_id': driverOrderId,
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
      };

      final resp = await DioHelper.postData(
        url: 'drivers/locations',
        data: payload,
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final item = LocationModel.fromJson(resp.data);
        // update local lists sensibly
        _current = item;
        _latest = item;
        _locations.insert(0, item);
        ShowSuccesSnackBar(context, context.translate('successMessage.update'));
        onSuccess?.call();
      } else {
        ShowErrorSnackBar(context, context.translate('errorsMessage.connection'));
        return Future.error('Failed to save');
      }
    } catch (error) {
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        ShowErrorSnackBar(context, context.translate('errorsMessage.connection'));
        return Future.error('connection timeout');
      }
      ShowErrorSnackBar(context, context.translate('errorsMessage.connection'));
      return Future.error('connection other');
    } finally {
      addLoading = false;
      notifyListeners();
    }
  }

  /* --------------------------------------------------------------------------
   * DELETE /api/drivers/locations/{id}
   * ------------------------------------------------------------------------*/
  Future<void> deleteLocation({
    required BuildContext context,
    required int id,
  }) async {
    deleteLoading = true;
    notifyListeners();
    try {
      final resp = await DioHelper.deleteData(
        url: 'drivers/locations',
        urlParam: '/$id',
      );

      if (resp.statusCode == 200) {
        _locations.removeWhere((e) => e.id == id);
        if (_current?.id == id) _current = null;
        ShowSuccesSnackBar(context, context.translate('successMessage.delete'));
      } else {
        ShowErrorSnackBar(context, context.translate('errorsMessage.connection'));
        return Future.error('Failed to delete');
      }
    } catch (error) {
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        ShowErrorSnackBar(context, context.translate('errorsMessage.connection'));
        return Future.error('connection timeout');
      }
      ShowErrorSnackBar(context, context.translate('errorsMessage.connection'));
      return Future.error('connection other');
    } finally {
      deleteLoading = false;
      notifyListeners();
    }
  }
}
