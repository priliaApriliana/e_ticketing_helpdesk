class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  
  // Tickets
  static const String tickets = '$baseUrl/tickets';
  static String ticketDetail(String id) => '$baseUrl/tickets/$id';
  static String ticketLogs(String id) => '$baseUrl/tickets/$id/logs';
  static String ticketsByUser(String userId) => '$baseUrl/tickets?userId=$userId';
  static String ticketsByStatus(String status) => '$baseUrl/tickets?status=$status';
  static String ticketUpdateStatus(String id) => '$baseUrl/tickets/$id/status';
  static String ticketUnassign(String id) => '$baseUrl/tickets/$id/unassign';
  static String ticketComments(String id) => '$baseUrl/tickets/$id/comments';

  // Notifications
  static const String notifications = '$baseUrl/notifications';
  static String notificationsByUser(String userId) => '$baseUrl/notifications?id_user=$userId';
  static String markNotificationRead(String id) => '$baseUrl/notifications/$id/read';
  static const String markAllNotificationsRead = '$baseUrl/notifications/read-all';

  // Dashboard
  static const String dashboardMetrics = '$baseUrl/dashboard/metrics';
  static String dashboardMetricsByUser(String userId) => '$baseUrl/dashboard/metrics?userId=$userId';

  // Users
  static const String users = '$baseUrl/users';
  static String usersByRole(String role) => '$baseUrl/users?role=$role';
}