// shared/lib/models/price_negotiation.dart

class PriceNegotiation {
  final String id;
  final double proposedByCourier;
  final bool confirmedByClient;
  final String status; // NegotiationStatus (Pending, Accepted, Rejected)
  final String? paymentMethod;
  final bool adminOverride;
  final String? updatedBy;

  PriceNegotiation({
    required this.id,
    required this.proposedByCourier,
    this.confirmedByClient = false,
    required this.status,
    this.paymentMethod,
    this.adminOverride = false,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'proposedByCourier': proposedByCourier,
        'confirmedByClient': confirmedByClient,
        'status': status,
        'paymentMethod': paymentMethod,
        'adminOverride': adminOverride,
        'updatedBy': updatedBy,
      };

  factory PriceNegotiation.fromJson(Map<String, dynamic> json) => PriceNegotiation(
        id: json['id'] as String,
        proposedByCourier: (json['proposedByCourier'] as num).toDouble(),
        confirmedByClient: json['confirmedByClient'] as bool? ?? false,
        status: json['status'] as String,
        paymentMethod: json['paymentMethod'] as String?,
        adminOverride: json['adminOverride'] as bool? ?? false,
        updatedBy: json['updatedBy'] as String?,
      );
}
