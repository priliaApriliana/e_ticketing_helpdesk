class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  
  static const String tickets = '$baseUrl/tickets';
  static String ticketDetail(String id) => '$baseUrl/tickets/$id';
  static String ticketComments(String id) => '$baseUrl/tickets/$id/comments';

  // Notification Endpoints
  static const String notifications = '$baseUrl/notifications';
  static String markNotificationRead(String id) => '$baseUrl/notifications/$id/read';
}
