class DashboardMetricsModel {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const DashboardMetricsModel({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  factory DashboardMetricsModel.fromMap(Map<String, int> source) {
    return DashboardMetricsModel(
      total: source['total'] ?? 0,
      open: source['open'] ?? 0,
      inProgress: source['in_progress'] ?? 0,
      resolved: source['resolved'] ?? 0,
      closed: source['closed'] ?? 0,
    );
  }

  Map<String, int> toMap() {
    return {
      'total': total,
      'open': open,
      'in_progress': inProgress,
      'resolved': resolved,
      'closed': closed,
    };
  }
}
