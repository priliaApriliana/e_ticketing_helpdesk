import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/core/services/ticket_service.dart';

class DashboardRepository {
  final TicketService _ticketService = Get.find<TicketService>();

  Map<String, int> getStatistics(String? userId) {
    return _ticketService.getStatistics(userId);
  }

  Future<List<TicketModel>> getTickets({String? userId}) {
    return _ticketService.getTickets(userId: userId);
  }
}




