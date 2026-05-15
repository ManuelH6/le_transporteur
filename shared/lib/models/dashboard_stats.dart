// shared/lib/models/dashboard_stats.dart

class DashboardStats {
  final double totalRevenue;
  final int activeOrders;
  final int pendingLivreurs;
  final int totalClients;
  final int totalLivreurs;
  final List<RevenueDataPoint> revenueChart;

  DashboardStats({
    required this.totalRevenue,
    required this.activeOrders,
    required this.pendingLivreurs,
    required this.totalClients,
    required this.totalLivreurs,
    required this.revenueChart,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
        activeOrders: json['activeOrders'] as int? ?? 0,
        pendingLivreurs: json['pendingLivreurs'] as int? ?? 0,
        totalClients: json['totalClients'] as int? ?? 0,
        totalLivreurs: json['totalLivreurs'] as int? ?? 0,
        revenueChart: (json['revenueChart'] as List? ?? [])
            .map((e) => RevenueDataPoint.fromJson(e))
            .toList(),
      );
}

class RevenueDataPoint {
  final String date;
  final double amount;

  RevenueDataPoint({required this.date, required this.amount});

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) => RevenueDataPoint(
        date: json['date'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      );
}
