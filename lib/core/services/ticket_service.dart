import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_log_model.dart';
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

  Future<List<TicketLogModel>> getTicketLogs(String ticketId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.ticketLogs(ticketId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          List data = body['data'];
          return data.map((item) => TicketLogModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print('Error getting ticket logs: $e');
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
    // Menggunakan MultipartRequest untuk upload file fisik
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.tickets));
    
    request.headers.addAll({
      'Authorization': 'Bearer ${_box.read('token')}',
    });

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['priority'] = priority;
    request.fields['category'] = category;
    request.fields['created_by'] = createdBy;

    for (var path in attachments) {
      if (path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('attachments', path));
      }
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

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
    required String changedBy,
    required String changedByName,
  }) async {
    return updateTicketStatus(
      ticketId: ticketId, 
      status: 'in_progress', 
      assignedTo: assignedTo, 
      assignedToName: assignedToName,
      changedBy: changedBy,
      changedByName: changedByName,
      note: 'Ticket assigned to $assignedToName',
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

  Future<bool> updateTicketStatus({
    required String ticketId,
    required String status,
    String? assignedTo,
    String? assignedToName,
    String? changedBy,
    String? changedByName,
    String? note,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.ticketDetail(ticketId) + '/status'),
        headers: _headers,
        body: jsonEncode({
          'status': status,
          'assigned_to': assignedTo,
          'assigned_to_name': assignedToName,
          'changed_by': changedBy,
          'changed_by_name': changedByName,
          'note': note,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  Future<bool> deleteTicket(String ticketId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.ticketDetail(ticketId)),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting ticket: $e');
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
