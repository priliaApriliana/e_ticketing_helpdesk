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

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        status: json['status'],
        priority: json['priority'],
        category: json['category'],
        createdBy: json['created_by'],
        createdByName: json['created_by_name'],
        assignedTo: json['assigned_to'],
        assignedToName: json['assigned_to_name'],
        attachments: List<String>.from(json['attachments'] ?? []),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        commentCount: json['comment_count'] ?? 0,
      );

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
        id: json['id'],
        ticketId: json['ticket_id'],
        userId: json['user_id'],
        userName: json['user_name'],
        userRole: json['user_role'],
        content: json['content'],
        createdAt: DateTime.parse(json['created_at']),
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
