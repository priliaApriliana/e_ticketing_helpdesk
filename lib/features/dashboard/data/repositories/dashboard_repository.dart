import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/core/services/ticket_service.dart';

class DashboardRepository {
  final TicketService _ticketService = Get.find<TicketService>();

  Future<Map<String, int>> getStatistics({
    String? userId,
    String? createdBy,
    String? assignedTo,
  }) {
    // Note: We might need to update ticket_service.getStatistics to support these specific filters 
    // if we want strict dashboard counts. For now we use the general userId.
    return _ticketService.getStatistics(userId);
  }

  Future<List<TicketModel>> getTickets({
    String? userId,
    String? createdBy,
    String? assignedTo,
  }) {
    return _ticketService.getTickets(
      userId: userId,
      createdBy: createdBy,
      assignedTo: assignedTo,
    );
  }
}
