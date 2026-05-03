// shared/lib/models/courier_review.dart

class CourierReview {
  final String id;
  final String orderId;
  final String clientId;
  final String courierId;
  final int rating; // 0 to 10
  final String? comment;
  final DateTime createdAt;

  CourierReview({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.courierId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'clientId': clientId,
        'courierId': courierId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CourierReview.fromJson(Map<String, dynamic> json) => CourierReview(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        clientId: json['clientId'] as String,
        courierId: json['courierId'] as String,
        rating: (json['rating'] as num).toInt(),
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
