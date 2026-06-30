class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String category;
  final String createdBy;
  final String createdByName;
  final String? assignedTo;
  final String? assignedToName;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  int commentCount;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdBy,
    required this.createdByName,
    this.assignedTo,
    this.assignedToName,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.commentCount = 0,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      try {
        return DateTime.parse(date.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    List<String> parseAttachments(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String) {
        if (val.startsWith('{') && val.endsWith('}')) {
          final content = val.substring(1, val.length - 1);
          if (content.isEmpty) return [];
          return content.split(',').map((e) => e.trim().replaceAll('"', '')).toList();
        }
        return [val];
      }
      return [];
    }

    return TicketModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Tanpa Judul',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'low',
      category: json['category'] ?? 'Lainnya',
      createdBy: json['created_by'] ?? '',
      createdByName: json['created_by_name'] ?? 'User',
      assignedTo: json['assigned_to'],
      assignedToName: json['assigned_to_name'],
      attachments: parseAttachments(json['attachments']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      commentCount: int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'category': category,
        'created_by': createdBy,
        'created_by_name': createdByName,
        'assigned_to': assignedTo,
        'assigned_to_name': assignedToName,
        'attachments': attachments,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'comment_count': commentCount,
      };
}

class CommentModel {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String userRole;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id']?.toString() ?? '',
        ticketId: json['ticket_id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        userName: json['user_name'] ?? 'User',
        userRole: json['user_role'] ?? 'user',
        content: json['content'] ?? '',
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticket_id': ticketId,
        'user_id': userId,
        'user_name': userName,
        'user_role': userRole,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}
