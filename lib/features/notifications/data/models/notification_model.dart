/// Notification model matching the notifications table schema.
///
/// Table schema:
/// id, user_id, title, message, type(general/winning/match/bonus), is_read, data(jsonb)
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = NotificationType.general,
    this.isRead = false,
    this.data,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String? ?? 'general'),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.value,
      'is_read': isRead,
      if (data != null) 'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Time ago string.
  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  String toString() =>
      'NotificationModel(title: $title, type: ${type.value}, read: $isRead)';
}

/// Notification type enum.
enum NotificationType {
  general('general'),
  winning('winning'),
  match('match'),
  bonus('bonus');

  final String value;
  const NotificationType(this.value);

  factory NotificationType.fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.general,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.winning:
        return 'Winning';
      case NotificationType.match:
        return 'Match';
      case NotificationType.bonus:
        return 'Bonus';
    }
  }
}
