// shared/lib/models/order_status_history.dart

class OrderStatusHistory {
  final String id;
  final String status; // OrderStatus
  final DateTime changedAt;
  final String? changedBy;

  OrderStatusHistory({
    required this.id,
    required this.status,
    required this.changedAt,
    this.changedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'changedAt': changedAt.toIso8601String(),
        'changedBy': changedBy,
      };

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) => OrderStatusHistory(
        id: json['id'] as String,
        status: json['status'] as String,
        changedAt: DateTime.parse(json['changedAt'] as String),
        changedBy: json['changedBy'] as String?,
      );
}
