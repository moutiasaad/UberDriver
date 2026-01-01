import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:uber_driver/models/notification_model.dart';

import '../shared/remote/dio_helper.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  PaginationModel? _pagination;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  PaginationModel? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch notifications from API
  Future<void> fetchNotifications({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: 'driver/notifications',
        query: {'page': page.toString()},
      );

      print('Notifications Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final notificationResponse = NotificationResponse.fromJson(response.data);

        if (page == 1) {
          _notifications = notificationResponse.notifications;
        } else {
          _notifications.addAll(notificationResponse.notifications);
        }

        _unreadCount = notificationResponse.unreadCount;
        _pagination = notificationResponse.pagination;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to load notifications';
        _isLoading = false;
        notifyListeners();
      }
    } catch (error) {
      print('Notification Error: $error');
      if (error is DioException &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError)) {
        _error = 'connection timeout';
      } else if (error is DioException) {
        _error = error.response?.data['message'] ?? 'connection error';
      } else {
        _error = 'An unexpected error occurred';
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (_pagination != null && _pagination!.currentPage < _pagination!.lastPage) {
      await fetchNotifications(page: _pagination!.currentPage + 1);
    }
  }

  /// Check if there are more pages to load
  bool get hasMore {
    if (_pagination == null) return false;
    return _pagination!.currentPage < _pagination!.lastPage;
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await DioHelper.postData(
        url: 'driver/notifications/read/$notificationId',
        data: {},
      );

      print('Mark as read response: ${response.data}');

      if (response.data['success'] == true) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notification = _notifications[index];
          _notifications[index] = NotificationModel(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            type: notification.type,
            isRead: true,
            readAt: DateTime.now().toIso8601String(),
            data: notification.data,
            date: notification.date,
          );
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (error) {
      print('Error marking notification as read: $error');
      return false;
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await fetchNotifications(page: 1);
  }

  /// Clear all notifications
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _pagination = null;
    _error = null;
    notifyListeners();
  }
}
