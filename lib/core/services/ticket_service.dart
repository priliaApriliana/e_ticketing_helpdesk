import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/core/constants/api_constants.dart';

class TicketService extends GetxService {
  final GetStorage _box = GetStorage();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_box.read('token')}',
      };

  Future<List<TicketModel>> getTickets({
    String? userId,
    String? createdBy,
    String? assignedTo,
    String? status,
  }) async {
    try {
      String url = ApiConstants.tickets;
      Map<String, String> queryParams = {};
      
      if (userId != null) queryParams['user_id'] = userId;
      if (createdBy != null) queryParams['created_by'] = createdBy;
      if (assignedTo != null) queryParams['assigned_to'] = assignedTo;
      if (status != null) queryParams['status'] = status;

      if (queryParams.isNotEmpty) {
        url += '?' + Uri(queryParameters: queryParams).query;
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => TicketModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error getting tickets: $e');
    }
    return [];
  }

  Future<TicketModel?> getTicketById(String id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.ticketDetail(id)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return TicketModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error getting ticket detail: $e');
    }
    return null;
  }

  Future<List<CommentModel>> getComments(String ticketId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.ticketComments(ticketId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => CommentModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error getting comments: $e');
    }
    return [];
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
    final response = await http.post(
      Uri.parse(ApiConstants.tickets),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'priority': priority,
        'category': category,
        'created_by': createdBy,
        'attachments': attachments,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return TicketModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal membuat tiket: ${response.body}');
    }
  }

  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String userRole,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.ticketComments(ticketId)),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'content': content,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return CommentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah komentar: ${response.body}');
    }
  }

  Future<bool> assignTicket({
    required String ticketId,
    required String assignedTo,
    required String assignedToName,
  }) async {
    return updateTicketStatus(
      ticketId, 
      'in_progress', 
      assignedTo: assignedTo, 
      assignedToName: assignedToName
    );
  }

  Future<bool> unassignTicket(String ticketId) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.ticketDetail(ticketId) + '/unassign'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTicketStatus(
    String ticketId,
    String status, {
    String? assignedTo,
    String? assignedToName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.ticketDetail(ticketId) + '/status'),
        headers: _headers,
        body: jsonEncode({
          'status': status,
          'assigned_to': assignedTo,
          'assigned_to_name': assignedToName,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  Future<Map<String, int>> getStatistics(String? userId) async {
    try {
      String url = '${ApiConstants.baseUrl}/dashboard/metrics';
      if (userId != null) url += '?user_id=$userId';

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        return Map<String, int>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error getting statistics: $e');
    }
    return {
      'total': 0, 'open': 0, 'in_progress': 0, 'resolved': 0, 'closed': 0,
    };
  }
}
