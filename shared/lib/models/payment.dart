// shared/lib/models/payment.dart

class Payment {
  final String id;
  final double amount;
  final String method; // PaymentMethod (Cash, Card, Transfer, etc.)
  final String status; // PaymentStatus (Pending, Paid, Failed)
  final bool isArchived;
  final DateTime? archivedAt;

  Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    this.isArchived = false,
    this.archivedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'method': method,
        'status': status,
        'isArchived': isArchived,
        'archivedAt': archivedAt?.toIso8601String(),
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        method: json['method'] as String,
        status: json['status'] as String,
        isArchived: json['isArchived'] as bool? ?? false,
        archivedAt: json['archivedAt'] != null ? DateTime.parse(json['archivedAt'] as String) : null,
      );
}
