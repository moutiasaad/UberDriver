class NotificationModel {
  NotificationModel({
    this.id,
    this.title,
    this.body,
    this.type,
    this.isRead,
    this.readAt,
    this.data,
    this.date,
  });

  final String? id;
  final String? title;
  final String? body;
  final String? type;
  final bool? isRead;
  final String? readAt;
  final Map<String, dynamic>? data;
  final String? date;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      data: json['data'],
      date: json['created_at'] ?? '',
    );
  }
}

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final PaginationModel? pagination;

  NotificationResponse({
    required this.notifications,
    required this.unreadCount,
    this.pagination,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return NotificationResponse(
      notifications: (data['notifications'] as List<dynamic>?)
              ?.map((item) => NotificationModel.fromJson(item))
              .toList() ??
          [],
      unreadCount: data['unread_count'] ?? 0,
      pagination: data['pagination'] != null
          ? PaginationModel.fromJson(data['pagination'])
          : null,
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
