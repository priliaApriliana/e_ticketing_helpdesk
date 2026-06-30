class NotificationModel {
  final String id;
  final String recipientUserId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? ticketId;
  final String? type;

  const NotificationModel({
    required this.id,
    required this.recipientUserId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.ticketId,
    this.type,
  });

  NotificationModel copyWith({
    String? id,
    String? recipientUserId,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? ticketId,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      ticketId: ticketId ?? this.ticketId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_user_id': recipientUserId,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'ticket_id': ticketId,
      'type': type,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      recipientUserId: (json['recipient_user_id'] ?? json['recipientUserId'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['is_read'] == true || json['isRead'] == true,
      ticketId: (json['ticket_id'] ?? json['ticketId'])?.toString(),
      type: json['type']?.toString(),
    );
  }
}
