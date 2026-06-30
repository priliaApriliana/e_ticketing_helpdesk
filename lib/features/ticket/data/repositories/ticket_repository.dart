import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_log_model.dart';
import 'package:e_ticketing_helpdesk/core/services/ticket_service.dart';

class TicketRepository {
  final TicketService _ticketService = Get.find<TicketService>();

  Future<List<TicketModel>> getTickets({
    String? userId,
    String? createdBy,
    String? assignedTo,
    String? status,
  }) {
    return _ticketService.getTickets(
      userId: userId,
      createdBy: createdBy,
      assignedTo: assignedTo,
      status: status,
    );
  }

  Future<TicketModel?> getTicketById(String id) {
    return _ticketService.getTicketById(id);
  }

  Future<List<CommentModel>> getComments(String ticketId) {
    return _ticketService.getComments(ticketId);
  }

  Future<List<TicketLogModel>> getTicketLogs(String ticketId) {
    return _ticketService.getTicketLogs(ticketId);
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String priority,
    required String category,
    required String createdBy,
    required String createdByName,
    List<String> attachments = const [],
  }) {
    return _ticketService.createTicket(
      title: title,
      description: description,
      priority: priority,
      category: category,
      createdBy: createdBy,
      createdByName: createdByName,
      attachments: attachments,
    );
  }

  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String userRole,
    required String content,
  }) {
    return _ticketService.addComment(
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      content: content,
    );
  }

  Future<bool> assignTicket({
    required String ticketId,
    required String assignedTo,
    required String assignedToName,
    required String changedBy,
    required String changedByName,
  }) {
    return _ticketService.assignTicket(
      ticketId: ticketId,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      changedBy: changedBy,
      changedByName: changedByName,
    );
  }

  Future<bool> unassignTicket(String ticketId) {
    return _ticketService.unassignTicket(ticketId);
  }

  Future<bool> updateTicketStatus({
    required String ticketId,
    required String status,
    required String changedBy,
    required String changedByName,
    String? note,
  }) {
    return _ticketService.updateTicketStatus(
      ticketId: ticketId,
      status: status,
      changedBy: changedBy,
      changedByName: changedByName,
      note: note,
    );
  }

  Future<bool> deleteTicket(String ticketId) {
    return _ticketService.deleteTicket(ticketId);
  }
}
