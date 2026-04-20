import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';

class TicketService extends GetxService {
  final GetStorage _box = GetStorage();
  static const String _ticketsKey = 'tickets_data';
  static const String _commentsKey = 'ticket_comments_data';

  final List<TicketModel> _tickets = [
    TicketModel(
      id: 'TKT-001',
      title: 'Komputer tidak bisa menyala',
      description:
          'Komputer di ruang lab 3 tidak bisa dinyalakan sejak pagi. Sudah dicoba ganti kabel power tapi tetap tidak bisa.',
      status: 'open',
      priority: 'high',
      category: 'Hardware',
      createdBy: '3',
      createdByName: 'Andi User',
      attachments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      commentCount: 2,
    ),
    TicketModel(
      id: 'TKT-002',
      title: 'Tidak bisa akses WiFi kampus',
      description:
          'Tidak dapat terkoneksi ke WiFi kampus sejak kemarin sore. Perangkat lain juga mengalami masalah yang sama.',
      status: 'in_progress',
      priority: 'medium',
      category: 'Network',
      createdBy: '3',
      createdByName: 'Andi User',
      assignedTo: '4',
      assignedToName: 'Rizky Technical Support',
      attachments: [],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      commentCount: 4,
    ),
    TicketModel(
      id: 'TKT-003',
      title: 'Software akuntansi error',
      description:
          'Aplikasi akuntansi menampilkan error saat login dengan kode ERR_DB_CONN. Sudah dicoba restart tapi tidak membantu.',
      status: 'closed',
      priority: 'high',
      category: 'Software',
      createdBy: '3',
      createdByName: 'Andi User',
      assignedTo: '5',
      assignedToName: 'Nina Technical Support',
      attachments: [],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      commentCount: 6,
    ),
    TicketModel(
      id: 'TKT-004',
      title: 'Printer tidak terdeteksi',
      description:
          'Printer di ruang TU tidak terdeteksi oleh komputer setelah update Windows terbaru.',
      status: 'open',
      priority: 'low',
      category: 'Hardware',
      createdBy: '3',
      createdByName: 'Andi User',
      attachments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      commentCount: 0,
    ),
  ];

  final Map<String, List<CommentModel>> _comments = {
    'TKT-001': [
      CommentModel(
        id: 'c1',
        ticketId: 'TKT-001',
        userId: '2',
        userName: 'Siti Helpdesk',
        userRole: 'helpdesk',
        content: 'Terima kasih laporan Anda. Teknisi akan segera dikirim.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      CommentModel(
        id: 'c2',
        ticketId: 'TKT-001',
        userId: '3',
        userName: 'Andi User',
        userRole: 'user',
        content: 'Baik, ditunggu ya. Terima kasih.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
  };

  @override
  void onInit() {
    super.onInit();
    _loadPersistedData();
  }

  void _loadPersistedData() {
    final storedTickets = _box.read(_ticketsKey);
    final storedComments = _box.read(_commentsKey);

    if (storedTickets is List && storedTickets.isNotEmpty) {
      _tickets
        ..clear()
        ..addAll(
          storedTickets.map(
            (item) => TicketModel.fromJson(Map<String, dynamic>.from(item)),
          ),
        );
    }

    if (storedComments is Map && storedComments.isNotEmpty) {
      _comments.clear();
      storedComments.forEach((key, value) {
        if (value is List) {
          _comments[key.toString()] = value
              .map(
                (item) =>
                    CommentModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      });
    }

    _savePersistedData();
  }

  void _savePersistedData() {
    _box.write(_ticketsKey, _tickets.map((ticket) => ticket.toJson()).toList());
    final encodedComments = <String, dynamic>{};
    _comments.forEach((ticketId, values) {
      encodedComments[ticketId] = values
          .map((comment) => comment.toJson())
          .toList();
    });
    _box.write(_commentsKey, encodedComments);
  }

  Future<List<TicketModel>> getTickets({String? userId, String? status}) async {
    var tickets = List<TicketModel>.from(_tickets);
    if (userId != null) {
      tickets = tickets.where((ticket) => ticket.createdBy == userId).toList();
    }
    if (status != null) {
      tickets = tickets.where((ticket) => ticket.status == status).toList();
    }
    tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tickets;
  }

  Future<TicketModel?> getTicketById(String id) async {
    return _tickets.firstWhereOrNull((ticket) => ticket.id == id);
  }

  Future<List<CommentModel>> getComments(String ticketId) async {
    return _comments[ticketId] ?? [];
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String priority,
    required String category,
    required String createdBy,
    required String createdByName,
    List<String> attachments = const [],
  }) async {
    final ticket = TicketModel(
      id: 'LOCAL-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      status: 'open',
      priority: priority,
      category: category,
      createdBy: createdBy,
      createdByName: createdByName,
      attachments: attachments,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _tickets.insert(0, ticket);
    _savePersistedData();
    return ticket;
  }

  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String userRole,
    required String content,
  }) async {
    final comment = CommentModel(
      id: 'LOCAL-C-${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      content: content,
      createdAt: DateTime.now(),
    );
    _comments[ticketId] = [...(_comments[ticketId] ?? []), comment];
    final ticket = _tickets.firstWhereOrNull((item) => item.id == ticketId);
    if (ticket != null) {
      final index = _tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        _tickets[index] = TicketModel(
          id: ticket.id,
          title: ticket.title,
          description: ticket.description,
          status: ticket.status,
          priority: ticket.priority,
          category: ticket.category,
          createdBy: ticket.createdBy,
          createdByName: ticket.createdByName,
          assignedTo: ticket.assignedTo,
          assignedToName: ticket.assignedToName,
          attachments: ticket.attachments,
          createdAt: ticket.createdAt,
          updatedAt: DateTime.now(),
          commentCount: _comments[ticketId]!.length,
        );
      }
    }
    _savePersistedData();
    return comment;
  }

  Future<bool> assignTicket({
    required String ticketId,
    required String assignedTo,
    required String assignedToName,
  }) async {
    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final old = _tickets[index];
    _tickets[index] = TicketModel(
      id: old.id,
      title: old.title,
      description: old.description,
      status: 'in_progress',
      priority: old.priority,
      category: old.category,
      createdBy: old.createdBy,
      createdByName: old.createdByName,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      attachments: old.attachments,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
      commentCount: old.commentCount,
    );
    _savePersistedData();
    return true;
  }

  Future<bool> unassignTicket(String ticketId) async {
    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final old = _tickets[index];
    _tickets[index] = TicketModel(
      id: old.id,
      title: old.title,
      description: old.description,
      status: 'open',
      priority: old.priority,
      category: old.category,
      createdBy: old.createdBy,
      createdByName: old.createdByName,
      assignedTo: null,
      assignedToName: null,
      attachments: old.attachments,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
      commentCount: old.commentCount,
    );
    _savePersistedData();
    return true;
  }

  Future<bool> updateTicketStatus(
    String ticketId,
    String status, {
    String? assignedTo,
    String? assignedToName,
  }) async {
    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final old = _tickets[index];
    _tickets[index] = TicketModel(
      id: old.id,
      title: old.title,
      description: old.description,
      status: status,
      priority: old.priority,
      category: old.category,
      createdBy: old.createdBy,
      createdByName: old.createdByName,
      assignedTo: assignedTo ?? old.assignedTo,
      assignedToName: assignedToName ?? old.assignedToName,
      attachments: old.attachments,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
      commentCount: old.commentCount,
    );
    _savePersistedData();
    return true;
  }

  Map<String, int> getStatistics(String? userId) {
    final tickets = userId != null
        ? _tickets.where((ticket) => ticket.createdBy == userId).toList()
        : _tickets;
    return {
      'total': tickets.length,
      'open': tickets.where((ticket) => ticket.status == 'open').length,
      'in_progress': tickets
          .where((ticket) => ticket.status == 'in_progress')
          .length,
      'resolved': tickets.where((ticket) => ticket.status == 'resolved').length,
      'closed': tickets.where((ticket) => ticket.status == 'closed').length,
    };
  }
}

