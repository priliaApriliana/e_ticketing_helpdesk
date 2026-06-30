class TicketLogModel {
  final String id;
  final String ticketId;
  final String? changedBy;
  final String changedByName;
  final String oldStatus;
  final String newStatus;
  final String? note;
  final DateTime createdAt;

  TicketLogModel({
    required this.id,
    required this.ticketId,
    this.changedBy,
    required this.changedByName,
    required this.oldStatus,
    required this.newStatus,
    this.note,
    required this.createdAt,
  });

  factory TicketLogModel.fromJson(Map<String, dynamic> json) {
    return TicketLogModel(
      id: json['id'],
      ticketId: json['ticket_id'],
      changedBy: json['changed_by'],
      changedByName: json['changed_by_name'] ?? 'System',
      oldStatus: json['old_status'],
      newStatus: json['new_status'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
